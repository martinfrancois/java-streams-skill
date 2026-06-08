#!/usr/bin/env python3
"""Validate the supported subset of OpenAI agent YAML metadata."""

from __future__ import annotations

from pathlib import Path

from validate_skill import parse_openai_agent_metadata


def main() -> int:
    failures: list[str] = []
    for path in Path("skills").glob("*/agents/openai.yaml"):
        _, metadata_failures = parse_openai_agent_metadata(path.read_text(encoding="utf-8"))
        failures.extend(f"{path}: {failure}" for failure in metadata_failures)
    if failures:
        for failure in failures:
            print(failure)
        return 1
    print("YAML metadata ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
