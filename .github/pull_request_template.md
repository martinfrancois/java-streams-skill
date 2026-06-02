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
- [ ] `python3 scripts/validate_eval_criteria.py evals evals-reference`
- [ ] `python3 -m py_compile scripts/validate_skill.py scripts/validate_eval_criteria.py`
- [ ] `bash -n scripts/check_publish_dry_run.sh`
- [ ] `tessl plugin lint .`
- [ ] Manual rendered-doc or example review, if docs or examples changed

Tessl-authenticated checks:

- [ ] `bash scripts/check_publish_dry_run.sh .`
- [ ] `tessl plugin publish --dry-run --bump patch .`
- [ ] `tessl skill review --threshold 100 skills/java-streams/SKILL.md`, if skill text or references changed
- [ ] `tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context .`, if skill behavior, evals, or benchmark claims changed

Details:

```text

```

## Review Checklist

- [ ] Docs updated, or N/A
- [ ] Evals updated, or N/A
- [ ] Scenario directories include `task.md`, `criteria.json`, and `capability.txt`, or N/A
- [ ] Scenario invocation style is classified as natural or explicit, or N/A
- [ ] Natural activation prompts don't explicitly invoke the skill, or N/A
- [ ] Explicit invocation prompts are labeled as explicit, or N/A
- [ ] Headline criteria include compile/artifact checks, or N/A
- [ ] Headline criteria include behavior correctness checks, or N/A
- [ ] Runtime references contain no eval answer keys, scenario inventory, hosted run IDs, or fixed score claims
- [ ] Java baseline compatibility has been considered, or N/A
- [ ] Stream/collector ordering, null handling, and parallelism have been considered, or N/A
- [ ] Full/reference eval reporting is not hidden or cherry-picked
- [ ] Tessl checks were run, or unavailability is documented
- [ ] PR title or squash title uses Conventional Commits
- [ ] Redaction checked: no Tessl tokens, GitHub tokens, package manager tokens, private repository links, private eval artifacts, private registry/workspace links, local host paths, or proprietary Java source

## AI Assistance (if used)

- [ ] AI-assisted PR
- [ ] I confirm I understand and reviewed the change
