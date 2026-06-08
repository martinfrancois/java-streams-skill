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

  For runtime skill text or runtime reference changes, progressively widen the hosted checks before
  calling the PR done: first affected scenarios, then the full main suite, then every reference
  scenario with both variants, then every regression scenario with context only. The final post-change
  evidence must show 100% with context for every retained scenario in every suite. Run regression
  without-context only when intentionally checking whether a scenario should move back to reference.
  If a broad run finds isolated failures, fix and rerun those scenarios targeted after the fix before
  spending rate-limit budget on another broad suite run; once targeted failures are clean, finish the
  remaining broad suites that have not yet run against the final skill state. If Tessl hosted evals
  are unavailable or rate-limited, document the exact missing runs and do not call the PR
  release-ready.

  Release evals only cover the published main suite. After any runtime skill text or runtime
  reference change, a successful publish run is not enough by itself: before saying the release or
  repository is done, also verify that every reference scenario has run with both variants and every
  regression scenario has run with context only against the final skill state. These runs may be
  split across targeted and suite runs to conserve Tessl quota, but they must be after the last
  runtime-context change. If quota, auth, or hosted availability blocks the broad reference or
  regression checks, open or update a GitHub issue with the exact missing commands, run IDs already
  completed, and the blocking condition.

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
  `CHANGELOG.md`, `.tessl-plugin/plugin.json`, and GitHub releases.
  - Use `fix(skill): ...` for corrections to `skills/java-streams/SKILL.md` or files it links as
    runtime references.
  - Use `feat(skill): ...` when adding a new runtime capability or materially broader skill behavior.
  - Use `test(evals): ...` when adding, moving, or reclassifying scenarios without changing their
    scoring intent.
  - Use `fix(evals): ...` when correcting a flawed task, criterion, score interpretation, or unfair
    eval expectation.
  - Use `docs: ...` only for user/contributor/agent docs that do not change runtime skill behavior
    and do not change eval scoring or suite membership.
  - Use the PR title type/scope for the highest-impact change in the PR; if runtime skill behavior
    changed, the PR title should normally be `fix(skill)` or `feat(skill)`, not `docs`.

  When Release Please creates a release with `GITHUB_TOKEN`, the normal `release: published` trigger
  does not fire, so the Release Please workflow dispatches `.github/workflows/publish-tessl.yml` with
  the created tag. Tessl publishing still happens only in `.github/workflows/publish-tessl.yml`.
  Release Please PRs created or updated with `GITHUB_TOKEN` may not trigger ordinary `pull_request`
  workflows, so `.github/workflows/release-please.yml` also posts the required release-PR
  `Commitlint` and `Validate skill and plugin` statuses. Keep that workflow based on the Release
  Please `pr` output instead of a separate `gh pr list` lookup, so status setup does not depend on
  GitHub search timing.
- When the maintainer asks for a release, keep Release Please as the source of truth. Do not edit
  `CHANGELOG.md`, `.release-please-manifest.json`, `.tessl-plugin/plugin.json`, tags, or GitHub
  releases by hand unless the maintainer explicitly asks to repair broken release state.

  If a Release Please PR is already open:

  ```bash
  gh pr list --state open --author "github-actions[bot]" \
    --head release-please--branches--main--components--java-streams
  gh pr checks <release-pr-number> --fail-fast=false
  ```

  Make sure the PR only contains Release Please files (`CHANGELOG.md`,
  `.release-please-manifest.json`, `.tessl-plugin/plugin.json`) and that required checks pass. If
  the release PR has no checks because it was just created, rerun the Release Please workflow for the
  current `main` run so it finds the existing PR and attaches the validation statuses. Then merge the
  release PR with the repository's linear-history merge method, normally squash merge, and wait for
  `.github/workflows/publish-tessl.yml` to finish.

  If no Release Please PR is open:

  ```bash
  git status --short --branch
  git log --oneline "$(git describe --tags --abbrev=0)"..main
  gh run list --workflow release-please.yml --limit 5
  ```

  If unreleased commits already include a releasable Conventional Commit such as `fix:` or `feat:`,
  rerun or trigger the Release Please workflow on `main` and wait for the release PR. If the only
  unreleased commits are non-releasable types such as `docs:`, `test:`, or `chore:`, and the
  maintainer still wants a new published version, create an empty releasable commit that accurately
  describes why a release is needed, for example:

  ```bash
  git commit --allow-empty -m "fix(evals): publish updated main eval suite"
  git push origin main
  ```

  Then let Release Please open the release PR, validate it, merge it, and wait for the Tessl publish
  workflow. After the publish run completes, confirm the GitHub release, Tessl latest version, and
  that no stale Release Please PR or branch remains.

  If the release contains any runtime skill text or runtime reference change, do not stop after the
  registry main eval passes. Confirm the post-change eval evidence also includes:

  ```bash
  scripts/run_eval_suite.sh reference
  scripts/run_eval_suite.sh regression
  ```

  `reference` must be run with both variants through the wrapper. `regression` must be run with
  context only through the wrapper. If these broad suite runs were already completed after the final
  runtime-context commit, reuse those run IDs; otherwise run them before reporting the release as
  complete. The completion report must state the main release eval run plus the reference and
  regression run IDs, or link the GitHub issue that records why the remaining checks are blocked.
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
