#!/usr/bin/env python3
"""Validate local Tessl scenario evals.

This is a repository guardrail, not a replacement for official Tessl lint or hosted evals.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


ANSWER_KEY_MARKERS = (
    "Eval Cases",
    "Eval Scoring Rubric",
    "Scoring Rubric",
    "Expected:",
    "Rejected:",
    "hosted run",
    "run id",
    "scenario inventory",
    "baseline score",
    "uplift",
    "answer key",
)
COMPILE_WORDS = ("compile", "compiles", "coherent", "artifact", "creates")
BEHAVIOR_WORDS = (
    "behavior",
    "preserve",
    "exact",
    "return",
    "returns",
    "exception",
    "prompt",
    "output",
    "order",
    "lazy",
    "laziness",
    "side effect",
    "fallback",
    "parse",
    "redact",
)
CRITERION_CATEGORIES = {"safety", "optional_quality", "maintainability"}
EXPLICIT_INVOCATION_PATTERNS = (
    r"\$java-optionals\b",
    r"\buse\s+java-optionals\b",
    r"\buse\s+the\s+java-optionals\s+skill\b",
    r"\bjava-optionals\s+skill\b",
)


def error(message: str) -> int:
    print(f"error: {message}", file=sys.stderr)
    return 1


def scenario_dirs(paths: list[Path]) -> list[Path]:
    dirs: list[Path] = []
    for path in paths:
        if path.is_file() and path.name == "criteria.json":
            dirs.append(path.parent)
        elif path.is_dir():
            if (path / "criteria.json").is_file():
                dirs.append(path)
            else:
                children = sorted(child for child in path.iterdir() if child.is_dir())
                dirs.extend(children)
        else:
            raise FileNotFoundError(path)
    return sorted(dict.fromkeys(dirs))


def load_json(path: Path) -> tuple[dict[str, Any] | None, list[str]]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return None, [f"{path}: invalid JSON: {exc}"]
    if not isinstance(data, dict):
        return None, [f"{path}: criteria root must be an object"]
    return data, []


def invocation_from_task(task_text: str) -> bool:
    return any(re.search(pattern, task_text, re.IGNORECASE) for pattern in EXPLICIT_INVOCATION_PATTERNS)


def text_of(item: dict[str, Any]) -> str:
    return f"{item.get('name', '')} {item.get('description', '')}".lower()


def validate_scenario(scenario: Path, headline_root: Path | None) -> list[str]:
    failures: list[str] = []
    task_file = scenario / "task.md"
    criteria_file = scenario / "criteria.json"
    capability_file = scenario / "capability.txt"

    if not task_file.is_file():
        failures.append(f"{scenario}: missing task.md")
    if not criteria_file.is_file():
        failures.append(f"{scenario}: missing criteria.json")
    if not capability_file.is_file():
        failures.append(f"{scenario}: missing capability.txt")
    elif not capability_file.read_text(encoding="utf-8").strip():
        failures.append(f"{capability_file}: capability must be non-empty")

    if not criteria_file.is_file():
        return failures

    data, json_failures = load_json(criteria_file)
    failures.extend(json_failures)
    if data is None:
        return failures

    if data.get("type") != "weighted_checklist":
        failures.append(f"{criteria_file}: type must be weighted_checklist")

    checklist = data.get("checklist")
    if not isinstance(checklist, list) or not checklist:
        failures.append(f"{criteria_file}: checklist must be a non-empty array")
        checklist = []

    is_headline = headline_root is not None and scenario.parent.resolve() == headline_root.resolve()
    names: set[str] = set()
    total_score = 0
    compile_score = 0
    behavior_score = 0
    category_scores = {category: 0 for category in CRITERION_CATEGORIES}
    for index, item in enumerate(checklist, start=1):
        if not isinstance(item, dict):
            failures.append(f"{criteria_file}: checklist item {index} must be an object")
            continue
        name = item.get("name")
        description = item.get("description")
        max_score = item.get("max_score")
        if not isinstance(name, str) or not name.strip():
            failures.append(f"{criteria_file}: checklist item {index} needs a non-empty name")
            name = f"<item {index}>"
        if name in names:
            failures.append(f"{criteria_file}: duplicate criterion name: {name}")
        names.add(str(name))
        if not isinstance(description, str) or not description.strip():
            failures.append(f"{criteria_file}: checklist item {index} needs a non-empty description")
        if not isinstance(max_score, int) or max_score <= 0:
            failures.append(f"{criteria_file}: checklist item {index} needs a positive integer max_score")
            max_score = 0
        category = item.get("category")
        if category is not None and category not in CRITERION_CATEGORIES:
            failures.append(
                f"{criteria_file}: checklist item {index} has unsupported category {category!r}; "
                f"use one of {sorted(CRITERION_CATEGORIES)}"
            )
        if is_headline and category not in CRITERION_CATEGORIES:
            failures.append(
                f"{criteria_file}: headline checklist item {index} needs category "
                f"safety, optional_quality, or maintainability"
            )
        total_score += max_score
        if category in category_scores:
            category_scores[category] += max_score
        haystack = text_of(item)
        if any(word in haystack for word in COMPILE_WORDS):
            compile_score += max_score
        if any(word in haystack for word in BEHAVIOR_WORDS):
            behavior_score += max_score

    metadata = data.get("metadata")
    if not isinstance(metadata, dict):
        failures.append(f"{criteria_file}: missing metadata object")
        metadata = {}
    invocation = metadata.get("invocation")
    task_type = metadata.get("task_type")
    if invocation not in {"natural", "explicit"}:
        failures.append(f"{criteria_file}: metadata.invocation must be natural or explicit")
    if task_type not in {"implementation", "cleanup", "review"}:
        failures.append(f"{criteria_file}: metadata.task_type must be implementation, cleanup, or review")

    task_text = task_file.read_text(encoding="utf-8") if task_file.is_file() else ""
    if task_text and not re.search(r"\bAssume Java\s+\d+\b", task_text):
        failures.append(f"{task_file}: task must state the Java version to assume, e.g. 'Assume Java 17.'")
    has_explicit_invocation = invocation_from_task(task_text)
    if invocation == "natural" and has_explicit_invocation:
        failures.append(f"{task_file}: natural scenario explicitly invokes the skill")
    if invocation == "explicit" and not has_explicit_invocation:
        failures.append(f"{criteria_file}: explicit scenario task does not invoke the skill")

    if is_headline and task_type == "implementation":
        if compile_score <= 0:
            failures.append(f"{criteria_file}: headline implementation scenario needs compile/artifact criteria")
        if behavior_score <= 0:
            failures.append(f"{criteria_file}: headline implementation scenario needs behavior criteria")
        if category_scores["optional_quality"] <= 0:
            failures.append(f"{criteria_file}: headline implementation scenario needs optional_quality criteria")
    elif is_headline and task_type == "cleanup" and category_scores["optional_quality"] <= 0:
        failures.append(f"{criteria_file}: headline cleanup scenario needs optional_quality criteria")

    if "optionalint" in task_text.lower() or "optionalint" in str(data).lower():
        primitive_text = (task_text + json.dumps(data)).lower()
        if "getasint" not in primitive_text and "ifpresent" not in primitive_text:
            failures.append(f"{criteria_file}: OptionalInt scenario should mention primitive accessors or terminals")

    return failures


def validate_runtime_references() -> list[str]:
    failures: list[str] = []
    root = Path("skills/java-optionals/references")
    if not root.exists():
        return failures
    for path in sorted(root.glob("*.md")):
        text = path.read_text(encoding="utf-8")
        for marker in ANSWER_KEY_MARKERS:
            if marker.lower() in text.lower():
                failures.append(f"{path}: runtime reference contains answer-key marker {marker!r}")
    if Path("skills/java-optionals/evals/evals.json").exists():
        failures.append("skills/java-optionals/evals/evals.json: stale runtime-adjacent legacy eval file")
    return failures


def validate_numbering(root: Path) -> list[str]:
    failures: list[str] = []
    if not root.exists():
        return failures
    numbers: dict[int, str] = {}
    documented_gap = root / "NUMBERING.md"
    for scenario in sorted(child for child in root.iterdir() if child.is_dir()):
        match = re.match(r"^(\d+)-", scenario.name)
        if not match:
            continue
        number = int(match.group(1))
        if number in numbers:
            failures.append(f"{root}: duplicate scenario number {number:02d}: {numbers[number]}, {scenario.name}")
        numbers[number] = scenario.name
    if numbers and not documented_gap.exists():
        all_numbers = sorted(numbers)
        expected = set(range(all_numbers[0], all_numbers[-1] + 1))
        missing = sorted(expected - set(all_numbers))
        if missing:
            failures.append(f"{root}: numbering gap(s) {missing}; add NUMBERING.md if intentional")
    return failures


def main() -> int:
    if len(sys.argv) < 2:
        return error("usage: validate_eval_criteria.py <eval-directory-or-criteria.json> [...]")

    paths = [Path(arg) for arg in sys.argv[1:]]
    try:
        dirs = scenario_dirs(paths)
    except FileNotFoundError as exc:
        return error(f"path not found: {exc.filename}")
    if not dirs:
        return error("no scenario directories found")

    headline_root = Path("evals") if Path("evals").exists() else None
    failures: list[str] = []
    invocations: dict[str, int] = {"natural": 0, "explicit": 0}
    for scenario in dirs:
        failures.extend(validate_scenario(scenario, headline_root))
        criteria = scenario / "criteria.json"
        if criteria.exists():
            data, _ = load_json(criteria)
            if data and isinstance(data.get("metadata"), dict):
                invocation = data["metadata"].get("invocation")
                if invocation in invocations:
                    invocations[invocation] += 1

    if headline_root and any(path.resolve() == headline_root.resolve() for path in paths if path.exists()):
        headline_dirs = [d for d in dirs if d.parent.resolve() == headline_root.resolve()]
        headline_invocations = {"natural": 0, "explicit": 0}
        headline_category_scores = {category: 0 for category in CRITERION_CATEGORIES}
        for scenario in headline_dirs:
            data, _ = load_json(scenario / "criteria.json")
            if data and isinstance(data.get("metadata"), dict):
                invocation = data["metadata"].get("invocation")
                if invocation in headline_invocations:
                    headline_invocations[invocation] += 1
            if data and isinstance(data.get("checklist"), list):
                for item in data["checklist"]:
                    if not isinstance(item, dict):
                        continue
                    category = item.get("category")
                    max_score = item.get("max_score")
                    if category in headline_category_scores and isinstance(max_score, int):
                        headline_category_scores[category] += max_score
        if headline_dirs and not all(headline_invocations.values()):
            failures.append(
                "evals: headline suite must include both natural and explicit invocation scenarios"
            )
        headline_total = sum(headline_category_scores.values())
        if headline_total:
            optional_quality = headline_category_scores["optional_quality"]
            safety = headline_category_scores["safety"]
            maintainability = headline_category_scores["maintainability"]
            if optional_quality < headline_total * 0.8:
                failures.append(
                    "evals: headline suite should be primarily Optional-quality scoring "
                    f"({optional_quality}/{headline_total})"
                )
            if safety < headline_total * 0.05:
                failures.append(
                    "evals: headline suite needs enough safety-check scoring for compile/behavior "
                    f"({safety}/{headline_total})"
                )
            if maintainability < headline_total * 0.05:
                failures.append(
                    "evals: headline suite needs enough maintainability scoring "
                    f"({maintainability}/{headline_total})"
                )
            if maintainability > headline_total * 0.15:
                failures.append(
                    "evals: headline maintainability scoring should not obscure skill behavior "
                    f"({maintainability}/{headline_total})"
                )

    for path in paths:
        if path.is_dir():
            failures.extend(validate_numbering(path))
    failures.extend(validate_runtime_references())

    if failures:
        for failure in failures:
            print(f"error: {failure}", file=sys.stderr)
        return 1

    print(
        f"Validated {len(dirs)} scenario(s): "
        f"{invocations['natural']} natural, {invocations['explicit']} explicit."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
