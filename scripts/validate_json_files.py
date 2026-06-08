#!/usr/bin/env python3
"""Parse every JSON file in the repository."""

from __future__ import annotations

import json
from pathlib import Path


def main() -> int:
    for path in Path(".").rglob("*.json"):
        with path.open(encoding="utf-8") as file:
            json.load(file)
    print("JSON ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
