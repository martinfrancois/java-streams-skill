#!/usr/bin/env python3
"""Track hosted eval scenarios already proven clean for a skill bundle fingerprint."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from assert_eval_with_context import get_scenarios, parse_json_payload, with_context_score


SUITE_DIRS = {
    "main": "evals",
    "reference": "evals-reference",
    "regression": "evals-regression",
}


def scenario_names(repo_root: Path, suite: str) -> list[str]:
    suite_dir = repo_root / SUITE_DIRS[suite]
    if not suite_dir.is_dir():
        raise SystemExit(f"Missing suite directory: {suite_dir}")
    return sorted(path.name for path in suite_dir.iterdir() if path.is_dir())


def fingerprint_scenario(repo_root: Path, suite: str, scenario: str) -> str | None:
    scenario_dir = repo_root / SUITE_DIRS[suite] / scenario
    if not scenario_dir.is_dir():
        return None

    digest = hashlib.sha256()
    for path in sorted(scenario_dir.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(scenario_dir).as_posix()
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def scenario_fingerprints(repo_root: Path, suite: str, scenarios: list[str]) -> dict[str, str]:
    result: dict[str, str] = {}
    for scenario in normalize(scenarios):
        fingerprint = fingerprint_scenario(repo_root, suite, scenario)
        if fingerprint:
            result[scenario] = fingerprint
    return result


def scenario_task_map(repo_root: Path, suite: str) -> dict[str, str]:
    mapping: dict[str, str] = {}
    suite_dir = repo_root / SUITE_DIRS[suite]
    if not suite_dir.is_dir():
        raise SystemExit(f"Missing suite directory: {suite_dir}")

    for scenario_dir in sorted(path for path in suite_dir.iterdir() if path.is_dir()):
        task_path = scenario_dir / "task.md"
        if task_path.is_file():
            mapping[hashlib.sha256(task_path.read_text(encoding="utf-8").encode("utf-8")).hexdigest()] = (
                scenario_dir.name
            )
    return mapping


def fingerprint_skill(skill_dir: Path) -> str:
    if not skill_dir.is_dir():
        raise SystemExit(f"Missing skill directory: {skill_dir}")

    digest = hashlib.sha256()
    for path in sorted(skill_dir.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(skill_dir).as_posix()
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def load_state(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return raw if isinstance(raw, dict) else {}


def empty_state(fingerprint: str) -> dict[str, Any]:
    return {
        "fingerprint": fingerprint,
        "validated": {suite: [] for suite in SUITE_DIRS},
        "scenario_fingerprints": {suite: {} for suite in SUITE_DIRS},
        "updated_at": None,
    }


def state_for(path: Path, fingerprint: str) -> dict[str, Any]:
    state = load_state(path)
    if state.get("fingerprint") != fingerprint:
        return empty_state(fingerprint)

    validated = state.setdefault("validated", {})
    fingerprints = state.setdefault("scenario_fingerprints", {})
    for suite in SUITE_DIRS:
        values = validated.get(suite)
        if not isinstance(values, list):
            validated[suite] = []
        current = fingerprints.get(suite)
        if not isinstance(current, dict):
            fingerprints[suite] = {}
    return state


def save_state(path: Path, state: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def normalize(values: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            result.append(value)
    return result


def cmd_fingerprint(args: argparse.Namespace) -> int:
    print(fingerprint_skill(args.skill_dir))
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    for scenario in scenario_names(args.repo_root, args.suite):
        print(scenario)
    return 0


def cmd_remaining(args: argparse.Namespace) -> int:
    state = state_for(args.file, args.fingerprint)
    universe = normalize(args.scenarios or scenario_names(args.repo_root, args.suite))
    validated = set(state["validated"].get(args.suite, []))
    fingerprints = state.get("scenario_fingerprints", {}).get(args.suite, {})
    for scenario in universe:
        if scenario not in validated:
            print(scenario)
            continue

        current = fingerprint_scenario(args.repo_root, args.suite, scenario)
        recorded = fingerprints.get(scenario)
        if current and recorded and current == recorded:
            continue
        print(scenario)
    return 0


def cmd_mark(args: argparse.Namespace) -> int:
    state = state_for(args.file, args.fingerprint)
    validated = set(state["validated"].get(args.suite, []))
    scenarios = normalize(args.scenarios)
    validated.update(scenarios)
    state["validated"][args.suite] = sorted(validated)
    state.setdefault("scenario_fingerprints", {})[args.suite] = {
        **state.get("scenario_fingerprints", {}).get(args.suite, {}),
        **scenario_fingerprints(args.repo_root, args.suite, scenarios),
    }
    state["updated_at"] = datetime.now(timezone.utc).isoformat()
    save_state(args.file, state)
    return 0


def passing_scenarios(repo_root: Path, suite: str, run_json: Path) -> list[str]:
    payload = parse_json_payload(run_json.read_text(encoding="utf-8"))
    by_task_hash = scenario_task_map(repo_root, suite)
    passed: list[str] = []

    for scenario in get_scenarios(payload):
        if not isinstance(scenario, dict):
            continue
        task = scenario.get("task")
        if not isinstance(task, str):
            continue

        scenario_name = by_task_hash.get(hashlib.sha256(task.encode("utf-8")).hexdigest())
        if not scenario_name:
            continue

        scores = with_context_score(scenario)
        if scores is None:
            continue

        earned, maximum = scores
        if maximum > 0 and earned >= maximum:
            passed.append(scenario_name)
    return normalize(passed)


def cmd_passing(args: argparse.Namespace) -> int:
    for scenario in passing_scenarios(args.repo_root, args.suite, args.run_json):
        print(scenario)
    return 0


def cmd_ingest(args: argparse.Namespace) -> int:
    passed = passing_scenarios(args.repo_root, args.suite, args.run_json)
    if not passed:
        return 0

    state = state_for(args.file, args.fingerprint)
    validated = set(state["validated"].get(args.suite, []))
    validated.update(passed)
    state["validated"][args.suite] = sorted(validated)
    state.setdefault("scenario_fingerprints", {})[args.suite] = {
        **state.get("scenario_fingerprints", {}).get(args.suite, {}),
        **scenario_fingerprints(args.repo_root, args.suite, passed),
    }
    state["updated_at"] = datetime.now(timezone.utc).isoformat()
    save_state(args.file, state)

    for scenario in passed:
        print(scenario)
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    state = state_for(args.file, args.fingerprint)
    print(f"fingerprint: {args.fingerprint}")
    for suite in SUITE_DIRS:
        all_scenarios = set(scenario_names(args.repo_root, suite))
        validated = set(state["validated"].get(suite, []))
        fingerprints = state.get("scenario_fingerprints", {}).get(suite, {})
        current_validated = {
            scenario
            for scenario in all_scenarios & validated
            if fingerprints.get(scenario) == fingerprint_scenario(args.repo_root, suite, scenario)
        }
        valid_count = len(current_validated)
        missing = sorted(all_scenarios - current_validated)
        print(f"{suite}: {valid_count}/{len(all_scenarios)} validated")
        if missing:
            print("  missing: " + " ".join(missing))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    fingerprint = subparsers.add_parser("fingerprint")
    fingerprint.add_argument("--skill-dir", type=Path, required=True)
    fingerprint.set_defaults(func=cmd_fingerprint)

    list_cmd = subparsers.add_parser("list")
    list_cmd.add_argument("--repo-root", type=Path, default=Path("."))
    list_cmd.add_argument("--suite", choices=sorted(SUITE_DIRS), required=True)
    list_cmd.set_defaults(func=cmd_list)

    remaining = subparsers.add_parser("remaining")
    remaining.add_argument("--file", type=Path, required=True)
    remaining.add_argument("--fingerprint", required=True)
    remaining.add_argument("--repo-root", type=Path, default=Path("."))
    remaining.add_argument("--suite", choices=sorted(SUITE_DIRS), required=True)
    remaining.add_argument("scenarios", nargs="*")
    remaining.set_defaults(func=cmd_remaining)

    mark = subparsers.add_parser("mark")
    mark.add_argument("--file", type=Path, required=True)
    mark.add_argument("--fingerprint", required=True)
    mark.add_argument("--repo-root", type=Path, default=Path("."))
    mark.add_argument("--suite", choices=sorted(SUITE_DIRS), required=True)
    mark.add_argument("scenarios", nargs="+")
    mark.set_defaults(func=cmd_mark)

    passing = subparsers.add_parser("passing")
    passing.add_argument("--run-json", type=Path, required=True)
    passing.add_argument("--repo-root", type=Path, default=Path("."))
    passing.add_argument("--suite", choices=sorted(SUITE_DIRS), required=True)
    passing.set_defaults(func=cmd_passing)

    ingest = subparsers.add_parser("ingest")
    ingest.add_argument("--file", type=Path, required=True)
    ingest.add_argument("--fingerprint", required=True)
    ingest.add_argument("--run-json", type=Path, required=True)
    ingest.add_argument("--repo-root", type=Path, default=Path("."))
    ingest.add_argument("--suite", choices=sorted(SUITE_DIRS), required=True)
    ingest.set_defaults(func=cmd_ingest)

    status = subparsers.add_parser("status")
    status.add_argument("--file", type=Path, required=True)
    status.add_argument("--fingerprint", required=True)
    status.add_argument("--repo-root", type=Path, default=Path("."))
    status.set_defaults(func=cmd_status)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
