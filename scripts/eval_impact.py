#!/usr/bin/env python3
"""Suggest targeted eval scenarios affected by skill bundle changes."""

from __future__ import annotations

import argparse
import json
import math
import re
import subprocess
from collections import Counter
from dataclasses import dataclass
from pathlib import Path


SUITE_DIRS = {
    "main": "evals",
    "reference": "evals-reference",
    "regression": "evals-regression",
}

STOPWORDS = {
    "about",
    "after",
    "again",
    "against",
    "also",
    "and",
    "any",
    "are",
    "because",
    "before",
    "being",
    "between",
    "but",
    "can",
    "cannot",
    "code",
    "does",
    "each",
    "example",
    "file",
    "for",
    "from",
    "has",
    "have",
    "into",
    "its",
    "java",
    "keep",
    "make",
    "must",
    "not",
    "only",
    "or",
    "other",
    "over",
    "preserve",
    "provided",
    "requested",
    "result",
    "return",
    "same",
    "should",
    "than",
    "that",
    "the",
    "their",
    "then",
    "this",
    "use",
    "when",
    "where",
    "with",
    "without",
}


@dataclass
class Scenario:
    suite: str
    name: str
    path: Path
    tokens: Counter[str]


def run_git(args: list[str], repo_root: Path) -> str:
    completed = subprocess.run(
        ["git", *args],
        cwd=repo_root,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    return completed.stdout


def split_identifier(value: str) -> list[str]:
    parts = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", value)
    parts = re.sub(r"[^A-Za-z0-9]+", " ", parts)
    return parts.lower().split()


def tokenize(text: str) -> Counter[str]:
    tokens: Counter[str] = Counter()
    for raw in re.findall(r"[A-Za-z][A-Za-z0-9_]*", text):
        for token in split_identifier(raw):
            if len(token) < 3 or token in STOPWORDS:
                continue
            tokens[token] += 1
    return tokens


def changed_files(repo_root: Path, base_ref: str, head_ref: str, skill_dir: str) -> list[Path]:
    files = set()
    diff_output = run_git(["diff", "--name-only", f"{base_ref}...{head_ref}", "--", skill_dir], repo_root)
    for line in diff_output.splitlines():
        if line:
            files.add(Path(line))

    if head_ref == "HEAD":
        status_output = run_git(["status", "--short", "--", skill_dir], repo_root)
        for line in status_output.splitlines():
            if len(line) > 3:
                files.add(Path(line[3:]))

    return sorted(files)


def git_file_text(repo_root: Path, ref: str, path: Path) -> str:
    if ref == "HEAD":
        full_path = repo_root / path
        if full_path.exists():
            return full_path.read_text(encoding="utf-8")
    return run_git(["show", f"{ref}:{path.as_posix()}"], repo_root)


def changed_text(repo_root: Path, base_ref: str, head_ref: str, paths: list[Path]) -> str:
    chunks: list[str] = []
    for path in paths:
        diff = run_git(["diff", "--unified=0", f"{base_ref}...{head_ref}", "--", str(path)], repo_root)
        added_lines = []
        for line in diff.splitlines():
            if line.startswith("+++") or not line.startswith("+"):
                continue
            added_lines.append(line[1:])

        if added_lines:
            chunks.append(path.as_posix())
            chunks.extend(added_lines)
        else:
            chunks.append(path.as_posix())
            chunks.append(git_file_text(repo_root, head_ref, path))
    return "\n".join(chunks)


def scenario_text(path: Path) -> str:
    parts: list[str] = [path.name]
    for filename in ("task.md", "capability.txt", "criteria.json"):
        file_path = path / filename
        if not file_path.is_file():
            continue
        if filename.endswith(".json"):
            try:
                parts.append(json.dumps(json.loads(file_path.read_text(encoding="utf-8")), sort_keys=True))
            except json.JSONDecodeError:
                parts.append(file_path.read_text(encoding="utf-8"))
        else:
            parts.append(file_path.read_text(encoding="utf-8"))
    return "\n".join(parts)


def load_scenarios(repo_root: Path) -> list[Scenario]:
    scenarios: list[Scenario] = []
    for suite, directory in SUITE_DIRS.items():
        suite_dir = repo_root / directory
        if not suite_dir.is_dir():
            continue
        for scenario_dir in sorted(path for path in suite_dir.iterdir() if path.is_dir()):
            scenarios.append(
                Scenario(
                    suite=suite,
                    name=scenario_dir.name,
                    path=scenario_dir,
                    tokens=tokenize(scenario_text(scenario_dir)),
                )
            )
    return scenarios


def idf_by_token(scenarios: list[Scenario]) -> dict[str, float]:
    document_counts: Counter[str] = Counter()
    for scenario in scenarios:
        document_counts.update(scenario.tokens.keys())

    total = len(scenarios)
    return {
        token: math.log((1 + total) / (1 + count)) + 1
        for token, count in document_counts.items()
    }


def score_scenario(change_tokens: Counter[str], scenario: Scenario, idf: dict[str, float]) -> float:
    score = 0.0
    for token, count in change_tokens.items():
        if token not in scenario.tokens:
            continue
        score += (1 + math.log(count)) * idf.get(token, 1.0)
    return score


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    parser.add_argument("--base-ref", default="origin/main")
    parser.add_argument("--head-ref", default="HEAD")
    parser.add_argument("--skill-dir", default="skills/java-streams")
    parser.add_argument("--limit", type=int, default=4)
    parser.add_argument("--min-score", type=float, default=1.0)
    parser.add_argument("--explain", action="store_true")
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    files = changed_files(repo_root, args.base_ref, args.head_ref, args.skill_dir)
    if not files:
        return 0

    change_tokens = tokenize(changed_text(repo_root, args.base_ref, args.head_ref, files))
    if not change_tokens:
        return 0

    scenarios = load_scenarios(repo_root)
    idf = idf_by_token(scenarios)
    ranked = sorted(
        (
            (score_scenario(change_tokens, scenario, idf), scenario)
            for scenario in scenarios
        ),
        key=lambda item: (-item[0], item[1].suite, item[1].name),
    )

    emitted = 0
    for score, scenario in ranked:
        if emitted >= args.limit or score < args.min_score:
            break
        if args.explain:
            print(f"{scenario.suite}:{scenario.name}\t{score:.2f}\t{scenario.path.relative_to(repo_root)}")
        else:
            print(f"{scenario.suite}:{scenario.name}")
        emitted += 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
