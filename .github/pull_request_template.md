## Summary

Describe the change in 2-5 bullet points.

- Problem:
- Why it matters:
- What changed:
- What did not change:

## Change Type

- [ ] Skill behavior
- [ ] Evals or scoring
- [ ] Documentation
- [ ] CI, release, or dependency automation
- [ ] Repository metadata or contribution process
- [ ] Other maintenance

## Linked Issue

- Fixes #
- Related #

## User-Visible Behavior

Describe what a user, contributor, or maintainer can observe after this PR. If there is no
user-visible change, write `None`.

## Validation

Checks most contributors can run:

- [ ] `python3 scripts/validate_skill.py skills/java-streams`
- [ ] `python3 scripts/validate_eval_criteria.py evals evals-reference evals-regression`
- [ ] `python3 -m py_compile scripts/*.py`
- [ ] `bash -n scripts/*.sh`
- [ ] `tessl plugin lint .`
- [ ] Manual rendered-doc or example review, if docs or examples changed

Tessl-authenticated checks:

- [ ] `bash scripts/check_publish_dry_run.sh .`
- [ ] `tessl plugin publish --dry-run --bump patch .`
- [ ] `tessl skill review --threshold 100 skills/java-streams/SKILL.md`, if skill text or references changed
- [ ] Targeted main/reference `scripts/run_eval_suite.sh <main|reference> <scenario-name>`, if skill behavior or those evals changed
- [ ] Targeted regression `scripts/run_eval_suite.sh regression <scenario-name>`, if regression evals changed
- [ ] Every changed eval scenario was rerun targeted and reached 100% with context, or the PR explains the Tessl blocker and remaining work
- [ ] `scripts/classify_eval_result.py <run-json> --scenario-dir <scenario-dir>`, if a scenario was added or moved between suites
- [ ] Full/main `scripts/run_eval_suite.sh main`, if benchmark claims changed or targeted with-context results are clean

Details:

```text

```

## Review Checklist

- [ ] The change is scoped to the sections, skill files, evals, or workflows described above.
- [ ] Validation that applies to this change is checked above, or any unavailable check is explained.
- [ ] If Java stream guidance changed, Java baseline compatibility plus ordering, null handling, and parallelism were considered.
- [ ] If evals or benchmark claims changed, the eval scenarios remain fair and do not leak answer keys, run IDs, or fixed score claims into runtime references.
- [ ] If runtime skill text or references changed, hosted checks were widened from targeted affected scenarios to main/reference/regression as described in `docs/agents/workflow.md`, or any Tessl blocker is documented.
- [ ] Main and reference evals were run with both variants when hosted evals were needed; regression evals were run with context only unless reclassification back to reference was being checked.
- [ ] New or moved eval scenarios follow the classifier recommendation, or the PR explains the maintainer-approved override.
- [ ] Every retained eval scenario has a 100% with-context result, or any below-100 result is documented as blocking follow-up rather than classified/reportable coverage.
- [ ] PR title or squash title uses Conventional Commits.
- [ ] Redaction checked: no tokens, private links, private eval artifacts, local host paths, or proprietary Java source.

## AI Assistance (if used)

- [ ] AI-assisted PR
- [ ] I confirm I understand and reviewed the change
