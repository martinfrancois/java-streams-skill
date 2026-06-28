#!/usr/bin/env python3
"""Validate Tessl eval-run JSON and require with-context 100% across all scenarios."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


def parse_json_payload(raw: str) -> dict[str, Any]:
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        pass

    # Fallback for mixed stdout where JSON is appended after text logs.
    decoder = json.JSONDecoder()
    for index, char in enumerate(raw):
        if char != "{":
            continue
        try:
            value, _ = decoder.raw_decode(raw[index:])
        except json.JSONDecodeError:
            continue
        if isinstance(value, dict):
            return value

    raise ValueError("No valid JSON object found in Tessl output")


def get_scenarios(payload: dict[str, Any]) -> list[dict[str, Any]]:
    attrs = None
    data = payload.get("data")
    if isinstance(data, dict):
        attrs = data.get("attributes")
    if isinstance(attrs, dict):
        scenarios = attrs.get("scenarios")
        if isinstance(scenarios, list):
            return scenarios

    scenarios = payload.get("scenarios")
    if isinstance(scenarios, list):
        return scenarios

    raise ValueError("Could not locate eval scenarios in Tessl JSON")


def variant_solution(scenario: dict[str, Any], preferred: list[str]) -> dict[str, Any] | None:
    solutions = scenario.get("solutions")
    if not isinstance(solutions, list):
        return None

    by_variant = {solution.get("variant"): solution for solution in solutions if isinstance(solution, dict)}
    for variant in preferred:
        candidate = by_variant.get(variant)
        if candidate is not None:
            return candidate
    return None


def solved_with_context(solution: dict[str, Any]) -> tuple[float, float]:
    if "score" in solution or "max_score" in solution or "maxScore" in solution:
        score = solution.get("score", 0)
        max_score = solution.get("max_score", solution.get("maxScore", 0))
        return float(score or 0), float(max_score or 0)

    assessment_results = solution.get("assessmentResults")
    if isinstance(assessment_results, list):
        score = 0.0
        max_score = 0.0
        for result in assessment_results:
            if not isinstance(result, dict):
                continue
            score += float(result.get("score") or 0)
            max_score += float(result.get("max_score", result.get("maxScore", 0)) or 0)
        return score, max_score

    return 0.0, 0.0


def with_context_score(scenario: dict[str, Any]) -> tuple[float, float] | None:
    solution = variant_solution(scenario, ["usage-spec", "with-context"])
    if not solution:
        return None
    return solved_with_context(solution)


def scenario_name(scenario: dict[str, Any], index: int) -> str:
    return (
        scenario.get("shortDescription")
        or scenario.get("name")
        or scenario.get("scenarioId")
        or f"scenario-{index}"
    )


def format_pct(earned: float, maximum: float) -> str:
    if maximum <= 0:
        return "n/a"
    return f"{(earned / maximum * 100):.2f}%"


def evaluate(payload: dict[str, Any], *, suite: str | None = None) -> int:
    scenarios = get_scenarios(payload)
    missing: list[str] = []
    failing: list[str] = []

    for index, scenario in enumerate(scenarios, start=1):
        if not isinstance(scenario, dict):
            continue
        name = scenario_name(scenario, index)
        scores = with_context_score(scenario)
        if scores is None:
            missing.append(name)
            continue

        earned, maximum = scores
        if maximum <= 0:
            missing.append(name)
            continue
        if earned < maximum:
            failing.append(name)

    suite_label = f"{suite} " if suite else ""
    if not scenarios:
        print(f"FAIL: {suite_label}run payload contains no scenarios", file=sys.stderr)
        return 1
    if missing:
        print(f"FAIL: {suite_label}run is missing with-context scoring for {len(missing)} scenario(s):", file=sys.stderr)
        for name in missing:
            print(f"  - {name}", file=sys.stderr)
        return 1
    if failing:
        print(
            f"FAIL: {suite_label}with-context is below 100% for {len(failing)} scenario(s):",
            file=sys.stderr,
        )
        for name in failing:
            print(f"  - {name}", file=sys.stderr)
        return 1

    print(f"PASS: {suite_label}all with-context scores are 100% ({len(scenarios)} scenarios).")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run_json", type=Path, help="Path to `tessl eval run --json` output")
    parser.add_argument("--suite", help="Suite label for logging clarity", default=None)
    args = parser.parse_args()

    try:
        payload = parse_json_payload(args.run_json.read_text(encoding="utf-8"))
        return evaluate(payload, suite=args.suite)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FAIL: unable to read eval JSON '{args.run_json}': {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
