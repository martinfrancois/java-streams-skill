## Summary

Describe the change in 2-5 bullet points.

- Problem:
- Why it matters:
- What changed:
- What did not change:

## Change Type

Choose all that apply.

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

## Bug Fix Details

For bug fixes or regressions, explain why the issue happened and what now prevents it from coming
back. For other changes, write `N/A`.

- Root cause:
- Test, eval, or guardrail added:
- If no test or eval was added, why not:

## Validation

List the commands, manual checks, or hosted checks you ran. Include relevant failures that were fixed
during the PR.

Checks most contributors can run:

- [ ] `python3 scripts/validate_skill.py skills/java-optionals`
- [ ] `python3 scripts/validate_eval_criteria.py evals evals-reference`
- [ ] `python3 -m py_compile scripts/validate_skill.py scripts/validate_eval_criteria.py`
- [ ] `bash -n scripts/check_publish_dry_run.sh`
- [ ] `tessl plugin lint .`
- [ ] `markdownlint`, if Markdown changed
- [ ] Manual rendered-doc or example review, if docs or examples changed

Tessl-authenticated checks:

- [ ] `bash scripts/check_publish_dry_run.sh .`
- [ ] `tessl plugin publish --dry-run --bump patch .`
- [ ] `tessl skill review --threshold 90 skills/java-optionals/SKILL.md`, if skill text or references changed
- [ ] `tessl eval run --variant with-context --variant without-context .`, if skill behavior,
      evals, or benchmark claims changed

`bash scripts/check_publish_dry_run.sh .`, `tessl skill review`, and hosted Tessl evals require
Tessl authentication. Hosted evals also require a linked Tessl project. If you can't run one of
them, leave it unchecked and explain why in the details.

Details:

```text

```

## Human Verification

Describe what you tried manually and what result you saw. If the change cannot be tried manually,
explain why.

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
- [ ] Runtime references contain no eval answer keys, scenario inventory, hosted run IDs, or fixed
      score claims
- [ ] Java baseline compatibility has been considered, or N/A
- [ ] `OptionalInt`, `OptionalLong`, and `OptionalDouble` guidance has been considered, or N/A
- [ ] Optional-producing stream terminals and collectors are covered, or N/A
- [ ] Java 26 Javadocs were checked for Optional-family coverage, or N/A
- [ ] Valid README package-runner instructions were preserved, or N/A
- [ ] Tessl package commands match the verified plugin package format
- [ ] Full/reference eval reporting is not hidden or cherry-picked
- [ ] Tessl checks were run, or unavailability is documented
- [ ] PR title or squash title uses Conventional Commits
- [ ] Redaction checked: no Tessl tokens, GitHub tokens, package manager tokens, private repository
      links, private eval artifacts, private registry/workspace links, local host paths, or
      proprietary Java source

## AI Assistance (if used)

<!--
AI-assisted PRs are welcome. Mark this when an AI tool materially helped write, design, or edit the
change so reviewers know what to look for.
-->

- [ ] AI-assisted PR
- [ ] I confirm I understand and reviewed the change

<details>
<summary>AI prompts / session logs (optional)</summary>

```text

```

</details>
