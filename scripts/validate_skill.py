#!/usr/bin/env python3
"""Validate a Codex/Tessl skill folder with only Python's standard library."""

from __future__ import annotations

import re
import sys
import json
from pathlib import Path


ALLOWED_FRONTMATTER_KEYS = {"name", "description", "license", "allowed-tools", "metadata"}
MAX_SKILL_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024
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
OPENAI_AGENT_INTERFACE_KEYS = {"display_name", "short_description", "default_prompt"}


def error(message: str) -> int:
    print(f"error: {message}", file=sys.stderr)
    return 1


def parse_frontmatter(text: str) -> dict[str, str]:
    match = re.match(r"^---\n(.*?)\n---(?:\n|$)", text, re.DOTALL)
    if not match:
        raise ValueError("SKILL.md must start with YAML frontmatter delimited by ---")

    frontmatter: dict[str, str] = {}
    for line_number, line in enumerate(match.group(1).splitlines(), start=2):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if line.startswith((" ", "-")):
            continue
        if "\t" in line:
            raise ValueError(f"frontmatter line {line_number} contains a tab")

        key_match = re.match(r"^([A-Za-z0-9_-]+):(?:\s*(.*))?$", line)
        if not key_match:
            raise ValueError(f"frontmatter line {line_number} is not a simple key/value pair")

        key, value = key_match.groups()
        frontmatter[key] = (value or "").strip().strip('"').strip("'")

    return frontmatter


def parse_openai_agent_metadata(text: str) -> tuple[dict[str, str] | None, list[str]]:
    failures: list[str] = []
    if "\t" in text:
        failures.append("contains tabs; use spaces")
    lines = [line for line in text.splitlines() if line.strip() and not line.lstrip().startswith("#")]
    if not lines:
        failures.append("metadata file is empty")
        return None, failures
    if lines[0] != "interface:":
        failures.append("first non-comment line must be exactly 'interface:'")
        return None, failures

    values: dict[str, str] = {}
    for line_number, line in enumerate(lines[1:], start=2):
        match = re.fullmatch(r"  ([A-Za-z0-9_-]+):\s*(.+)", line)
        if not match:
            failures.append(f"line {line_number} must be a two-space-indented key/value pair")
            continue
        key, value = match.groups()
        if key not in OPENAI_AGENT_INTERFACE_KEYS:
            failures.append(f"unsupported interface key {key!r}")
            continue
        value = value.strip()
        if (
            (value.startswith('"') and value.endswith('"'))
            or (value.startswith("'") and value.endswith("'"))
        ):
            value = value[1:-1]
        if not value:
            failures.append(f"{key} must be non-empty")
        values[key] = value

    missing = OPENAI_AGENT_INTERFACE_KEYS - set(values)
    if missing:
        failures.append(f"missing interface key(s): {', '.join(sorted(missing))}")
    return values, failures


def scan_answer_key_markers(path: Path, text: str) -> list[str]:
    failures: list[str] = []
    for marker in ANSWER_KEY_MARKERS:
        if marker.lower() in text.lower():
            failures.append(f"{path}: runtime file contains answer-key marker {marker!r}")
    return failures


def validate_skill(skill_path: Path) -> list[str]:
    failures: list[str] = []
    skill_md = skill_path / "SKILL.md"

    if not skill_md.is_file():
        return [f"{skill_md}: missing SKILL.md"]

    text = skill_md.read_text(encoding="utf-8")
    try:
        frontmatter = parse_frontmatter(text)
    except ValueError as exc:
        return [f"{skill_md}: {exc}"]

    unexpected_keys = set(frontmatter) - ALLOWED_FRONTMATTER_KEYS
    if unexpected_keys:
        allowed = ", ".join(sorted(ALLOWED_FRONTMATTER_KEYS))
        failures.append(
            f"{skill_md}: unexpected frontmatter key(s): {', '.join(sorted(unexpected_keys))}; "
            f"allowed keys: {allowed}"
        )

    name = frontmatter.get("name", "").strip()
    description = frontmatter.get("description", "").strip()

    if not name:
        failures.append(f"{skill_md}: missing required frontmatter key: name")
    elif not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
        failures.append(f"{skill_md}: name must be hyphen-case lowercase text")
    elif len(name) > MAX_SKILL_NAME_LENGTH:
        failures.append(
            f"{skill_md}: name is {len(name)} characters; max is {MAX_SKILL_NAME_LENGTH}"
        )

    if not description:
        failures.append(f"{skill_md}: missing required frontmatter key: description")
    elif "<" in description or ">" in description:
        failures.append(f"{skill_md}: description must not contain angle brackets")
    elif len(description) > MAX_DESCRIPTION_LENGTH:
        failures.append(
            f"{skill_md}: description is {len(description)} characters; "
            f"max is {MAX_DESCRIPTION_LENGTH}"
        )

    body = re.sub(r"^---\n.*?\n---\n?", "", text, count=1, flags=re.DOTALL).strip()
    if not body:
        failures.append(f"{skill_md}: missing body content after frontmatter")
    failures.extend(scan_answer_key_markers(skill_md, body))

    for link in re.findall(r"\]\((references/[^)]+)\)", text):
        target = skill_path / link
        if not target.is_file():
            failures.append(f"{skill_md}: missing referenced file {link}")

    license_value = frontmatter.get("license")
    if license_value and license_value != "MIT":
        failures.append(f"{skill_md}: license must be MIT for this repository")

    references_dir = skill_path / "references"
    if references_dir.is_dir():
        for reference in sorted(references_dir.glob("*.md")):
            reference_text = reference.read_text(encoding="utf-8")
            failures.extend(scan_answer_key_markers(reference, reference_text))

    stale_eval = skill_path / "evals" / "evals.json"
    if stale_eval.exists():
        failures.append(f"{stale_eval}: legacy eval file must not live inside runtime skill package")

    agent_metadata = skill_path / "agents" / "openai.yaml"
    if agent_metadata.exists():
        _, metadata_failures = parse_openai_agent_metadata(agent_metadata.read_text(encoding="utf-8"))
        failures.extend(f"{agent_metadata}: {failure}" for failure in metadata_failures)

    package_manifests = [Path(".tessl-plugin/plugin.json"), Path("tile.json")]
    existing_manifests = [path for path in package_manifests if path.exists()]
    if not existing_manifests:
        failures.append("missing Tessl package manifest: .tessl-plugin/plugin.json or tile.json")
    for manifest in existing_manifests:
        try:
            data = json.loads(manifest.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            failures.append(f"{manifest}: invalid JSON: {exc}")
            continue
        if not isinstance(data, dict):
            failures.append(f"{manifest}: manifest root must be an object")
            continue
        for key in ("name", "version"):
            if not isinstance(data.get(key), str) or not data[key].strip():
                failures.append(f"{manifest}: missing non-empty {key}")
        description = data.get("description") or data.get("summary")
        if not isinstance(description, str) or not description.strip():
            failures.append(f"{manifest}: missing non-empty description/summary")

    return failures


def main() -> int:
    if len(sys.argv) != 2:
        return error("usage: validate_skill.py <skill-directory>")

    failures = validate_skill(Path(sys.argv[1]))
    if failures:
        for failure in failures:
            print(f"error: {failure}", file=sys.stderr)
        return 1

    print("Skill is valid.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
