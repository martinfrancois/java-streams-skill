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
  python3 -m py_compile scripts/validate_skill.py scripts/validate_eval_criteria.py
  bash -n scripts/check_publish_dry_run.sh
  tessl plugin lint .
  bash scripts/check_publish_dry_run.sh .
  tessl plugin publish --dry-run --bump patch .
  tessl plugin publish --dry-run .
  ```

- For skill behavior or eval changes, run hosted evals with Sonnet 4.6, but start with the smallest
  useful set. Run targeted affected scenarios first:

  ```bash
  tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context <scenario-dir>
  ```

  If any targeted with-context result is below 100%, fix the skill or eval and rerun only those
  targeted scenarios until they are clean. Then run the main eval set:

  ```bash
  tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context .
  ```

  Run relevant `evals-reference/` scenarios for nearby behavior and `evals-regression/` only as a
  final safety check before release or after broad changes.

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
