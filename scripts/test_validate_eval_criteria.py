#!/usr/bin/env python3
"""Fixture tests for validate_eval_criteria.py."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = REPO_ROOT / "scripts" / "validate_eval_criteria.py"


def write_runtime_reference(root: Path) -> None:
    references = root / "skills" / "java-streams" / "references"
    references.mkdir(parents=True)
    (references / "stream-examples.md").write_text(
        """# Runtime examples

```java
List<ShipmentNotice> overdueNotices(List<Shipment> shipments, Clock clock) {
    LocalDate today = LocalDate.now(clock);
    return shipments.stream()
            .filter(shipment -> isOverdue(shipment, today))
            .map(shipment -> toNotice(shipment, today))
            .toList();
}

private static ShipmentNotice toNotice(Shipment shipment, LocalDate today) {
    long daysLate = ChronoUnit.DAYS.between(shipment.dueDate(), today);
    return new ShipmentNotice(shipment.id(), shipment.customerEmail(), daysLate,
            daysLate >= 14 ? "critical" : "late");
}
```

```java
Map<String, List<String>> emailsByTrack = conferences.stream()
        .flatMap(conference -> conference.sessions().stream())
        .collect(Collectors.groupingBy(
                Session::track,
                Collectors.flatMapping(SessionReports::optedInEmails, Collectors.toList())));

private static Stream<String> optedInEmails(Session session) {
    return session.registrations().stream()
            .filter(Registration::optedIn)
            .map(Registration::email);
}
```
""",
        encoding="utf-8",
    )


def write_scenario(
    root: Path,
    suite: str,
    name: str,
    task: str,
    *,
    invocation: str = "natural",
    task_type: str = "implementation",
    evidence_type: str | None = "ordinary_lift",
    rationale: str | None = None,
    extra_metadata: dict[str, object] | None = None,
    checklist: list[dict[str, object]] | None = None,
) -> Path:
    scenario = root / suite / name
    scenario.mkdir(parents=True)
    (scenario / "task.md").write_text(task, encoding="utf-8")
    (scenario / "capability.txt").write_text("java-streams\n", encoding="utf-8")
    metadata: dict[str, object] = {
        "invocation": invocation,
        "task_type": task_type,
    }
    if evidence_type is not None:
        metadata["evidence_type"] = evidence_type
    if rationale is not None:
        metadata["runtime_reference_overlap_rationale"] = rationale
    if extra_metadata:
        metadata.update(extra_metadata)
    criteria = {
        "context": "Fixture scenario.",
        "type": "weighted_checklist",
        "checklist": checklist
        or [
            {
                "name": "Creates artifact",
                "category": "safety",
                "max_score": 5,
                "description": "Creates Example.java.",
            },
            {
                "name": "Preserves behavior",
                "category": "safety",
                "max_score": 5,
                "description": "Returns the requested output.",
            },
            {
                "name": "Uses stream quality",
                "category": "stream_quality",
                "max_score": 90,
                "description": "Uses clear stream code.",
            },
        ],
        "metadata": metadata,
    }
    (scenario / "criteria.json").write_text(json.dumps(criteria, indent=2) + "\n", encoding="utf-8")
    return scenario


def shipment_task(prefix: str = "Create `OverdueShipmentNotices.java`.") -> str:
    return f"""# Implement overdue shipment notices

{prefix} Assume Java 17.

Implement:

```java
List<ShipmentNotice> overdueNotices(List<Shipment> shipments, Clock clock)
record Shipment(String id, String customerEmail, LocalDate dueDate, Optional<LocalDate> deliveredAt) {{}}
record ShipmentNotice(String id, String customerEmail, long daysLate, String severity) {{}}
```

Severity is `"critical"` when `daysLate` is at least 14, otherwise `"late"`.
"""


def session_task() -> str:
    return """# Implement session roster indexes

Create `SessionRosterIndexes.java`. Assume Java 17.

```java
Map<String, List<String>> optedInEmailsByTrack(List<Conference> conferences)
record Conference(List<Session> sessions) {}
record Session(String id, String room, String track, int minutes, List<Registration> registrations) {}
record Registration(String email, boolean optedIn, boolean waitlisted) {}
```
"""


class ValidateEvalCriteriaTests(unittest.TestCase):
    def run_validator(self, root: Path, *paths: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(VALIDATOR), *(str(path.relative_to(root)) for path in paths)],
            cwd=root,
            text=True,
            capture_output=True,
            check=False,
        )

    def with_repo(self):
        temp = tempfile.TemporaryDirectory()
        root = Path(temp.name)
        write_runtime_reference(root)
        return temp, root

    def test_main_ordinary_lift_overlap_fails(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(root, "evals", "01-overlap", shipment_task())
            result = self.run_validator(root, scenario)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("ordinary_lift is incompatible", result.stderr)

    def test_main_ordinary_lift_overlap_rationale_does_not_bypass(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(
                root,
                "evals",
                "01-overlap",
                shipment_task(),
                rationale="Focused coverage kept intentionally.",
            )
            result = self.run_validator(root, scenario)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("ordinary_lift is incompatible", result.stderr)

    def test_reference_ordinary_lift_overlap_fails(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(root, "evals-reference", "28-overdue", shipment_task())
            result = self.run_validator(root, scenario)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("ordinary_lift is incompatible", result.stderr)

    def test_reference_focused_overlap_passes_with_rationale(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(
                root,
                "evals-reference",
                "28-overdue",
                shipment_task(),
                evidence_type="focused_reference",
                rationale="Allowed only as focused reference coverage.",
            )
            result = self.run_validator(root, scenario)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_regression_overlap_passes_when_classified_as_regression(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(
                root,
                "evals-regression",
                "20-shipment-review",
                shipment_task(),
                evidence_type="solved_regression",
            )
            result = self.run_validator(root, scenario)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_task_names_skill_but_metadata_says_natural_fails(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(
                root,
                "evals-reference",
                "26-explicit",
                shipment_task("Use `$java-streams` to create `OverdueShipmentNotices.java`."),
                invocation="natural",
                evidence_type="focused_reference",
                rationale="Allowed only as focused reference coverage.",
            )
            result = self.run_validator(root, scenario)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("natural scenario explicitly invokes the skill", result.stderr)

    def test_task_names_skill_and_metadata_says_explicit_passes(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(
                root,
                "evals-reference",
                "26-explicit",
                shipment_task("Use `$java-streams` to create `OverdueShipmentNotices.java`."),
                invocation="explicit",
                evidence_type="focused_reference",
                rationale="Allowed only as focused reference coverage.",
            )
            result = self.run_validator(root, scenario)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_scenario_28_focused_overlap_keeps_80_point_lambda_criterion(self) -> None:
        temp, root = self.with_repo()
        checklist = [
            {
                "name": "Creates artifact",
                "category": "safety",
                "max_score": 5,
                "description": "Creates OverdueShipmentNotices.java.",
            },
            {
                "name": "Avoids multi-line stream lambdas",
                "category": "stream_quality",
                "max_score": 80,
                "description": "Extracts non-trivial stream lambda bodies into helpers.",
            },
        ]
        with temp:
            scenario = write_scenario(
                root,
                "evals-reference",
                "28-overdue-shipment-notices",
                shipment_task(),
                evidence_type="focused_reference",
                rationale="Allowed only as focused reference coverage.",
                checklist=checklist,
            )
            result = self.run_validator(root, scenario)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_scenario_15_session_overlap_passes_only_when_focused(self) -> None:
        temp, root = self.with_repo()
        with temp:
            scenario = write_scenario(
                root,
                "evals-reference",
                "15-session-roster-indexes",
                session_task(),
                evidence_type="focused_reference",
                rationale="Allowed only as focused reference coverage.",
            )
            result = self.run_validator(root, scenario)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    raise SystemExit(unittest.main())
