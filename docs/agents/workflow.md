# Workflow

## Scope

Use this for day-to-day work in this repository: auth checks, validation, commits, pushes, and
release-readiness.

## Rules

- If a Tessl or GitHub command fails because auth, login, workspace, or permission state appears
  missing, re-check after the user says they changed it.
- When the maintainer explicitly asks for autonomous repository work, carry it through
  implementation, validation, commit, push, and repository creation unless they ask to stop earlier.
- Before committing changes to the skill, README, evals, package metadata, scripts, CI, or agent
  docs, run:

  ```bash
  python3 scripts/validate_skill.py skills/java-streams
  python3 scripts/validate_eval_criteria.py evals evals-reference evals-regression
  python3 -m py_compile scripts/*.py
  bash -n scripts/*.sh
  tessl plugin lint .
  bash scripts/check_publish_dry_run.sh .
  tessl plugin publish --dry-run --bump patch .
  tessl plugin publish --dry-run .
  ```

- For skill behavior or eval changes, run hosted evals with Sonnet 4.6, but start with the smallest
  useful set to conserve Tessl daily rate-limit budget. Use `scripts/run_eval_suite.sh` so the run
  uses plugin context and the right variant policy.

  If any eval scenario's `task.md`, `criteria.json`, or `capability.txt` changed, run that exact
  scenario before finishing the PR. A pure move between `evals/`, `evals-reference/`, and
  `evals-regression/` does not need a hosted rerun when the task, scoring criteria, and capability
  text are unchanged except for suite-placement metadata or numbering notes; run local validators
  and update suite totals instead. The with-context result for every substantively changed scenario
  must be 100% before broader suite results, benchmark claims, or release-readiness claims are
  trusted. This rule applies even when the edit looks like a prompt cleanup or metadata-only scoring
  clarification. If Tessl hosted evals are unavailable, the PR must document the blocker and
  remaining targeted runs; do not make benchmark or release-readiness claims until those runs pass.

  Run targeted affected main or reference scenarios with both variants:

  ```bash
  scripts/run_eval_suite.sh main <scenario-name>
  scripts/run_eval_suite.sh reference <scenario-name>
  ```

  Run targeted affected regression scenarios with context only by default:

  ```bash
  scripts/run_eval_suite.sh regression <scenario-name>
  ```

  If any targeted with-context result is below 100%, fix the skill or eval and rerun only those
  targeted scenarios until they are clean. Then run the main eval set:

  ```bash
  scripts/run_eval_suite.sh main
  ```

  For runtime skill text or runtime reference changes, progressively widen the hosted checks: first
  affected scenarios, then the full main suite, then relevant reference scenarios, and before final
  release/open-source-ready claims, all reference scenarios with both variants plus all regression
  scenarios with context only. Run regression without-context only when intentionally checking
  whether a scenario should move back to reference. If a broad run finds only isolated failures,
  fix and rerun those scenarios targeted after the fix before spending rate-limit budget on another
  broad suite run.

- When adding or moving one scenario, classify it from the isolated run before choosing the final
  suite:

  ```bash
  tessl eval view <run-id> --json > /tmp/eval-run.json
  scripts/classify_eval_result.py /tmp/eval-run.json --scenario-dir <scenario-dir>
  ```

  Follow the recommendation unless the pull request documents a maintainer-approved override.

- Run the Tessl skill review at threshold 100 when changing runtime skill content:

  ```bash
  tessl skill review --threshold 100 skills/java-streams/SKILL.md
  ```

- Pull request titles and commits must use Conventional Commits. Release Please uses them to update
  `CHANGELOG.md`, `.tessl-plugin/plugin.json`, and GitHub releases. When Release Please creates a
  release with `GITHUB_TOKEN`, the normal `release: published` trigger does not fire, so the Release
  Please workflow dispatches `.github/workflows/publish-tessl.yml` with the created tag. Tessl
  publishing still happens only in `.github/workflows/publish-tessl.yml`.
- Keep the GitHub repository private until the maintainer explicitly asks to make it public. Still
  keep docs, metadata, license, security policy, and contribution workflow open-source ready.
- Keep `.tessl-plugin/plugin.json` public-ready with `"private": false`, but do not run a real
  Tessl publish unless the maintainer explicitly asks for publication.
- For maintainer-requested automation tasks where the user has asked for GitHub state, commit and
  push finished changes.

## References

- [Project Identity](project-identity.md)
- [Eval Guidance](evals.md)
- [Public Metadata And OSS Readiness](public-metadata.md)
