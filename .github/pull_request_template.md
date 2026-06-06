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
- [ ] `python3 -m py_compile scripts/validate_skill.py scripts/validate_eval_criteria.py`
- [ ] `bash -n scripts/check_publish_dry_run.sh`
- [ ] `tessl plugin lint .`
- [ ] Manual rendered-doc or example review, if docs or examples changed

Tessl-authenticated checks:

- [ ] `bash scripts/check_publish_dry_run.sh .`
- [ ] `tessl plugin publish --dry-run --bump patch .`
- [ ] `tessl skill review --threshold 100 skills/java-streams/SKILL.md`, if skill text or references changed
- [ ] Targeted `tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context <scenario-dir>`, if skill behavior or evals changed
- [ ] Full/main `tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context .`, if benchmark claims changed or targeted with-context results are clean

Details:

```text

```

## Review Checklist

- [ ] The change is scoped to the sections, skill files, evals, or workflows described above.
- [ ] Validation that applies to this change is checked above, or any unavailable check is explained.
- [ ] If Java stream guidance changed, Java baseline compatibility plus ordering, null handling, and parallelism were considered.
- [ ] If evals or benchmark claims changed, the eval scenarios remain fair and do not leak answer keys, run IDs, or fixed score claims into runtime references.
- [ ] If any with-context result was below 100%, targeted failing scenarios were fixed and rerun before broader eval suites.
- [ ] PR title or squash title uses Conventional Commits.
- [ ] Redaction checked: no tokens, private links, private eval artifacts, local host paths, or proprietary Java source.

## AI Assistance (if used)

- [ ] AI-assisted PR
- [ ] I confirm I understand and reviewed the change
