# Contributing

Thanks for helping improve the Java Optional Skill.

This project helps AI coding agents write and clean up Java `Optional` code without replacing one
bad pattern with another. You don't need maintainer access or a Tessl workspace to make most useful
contributions.

Keep changes focused on the observed failure modes: weak Optional boundaries, null-style control
flow, fake single-Optional collections, eager fallback work, unclear checked-IO handling,
`findFirst()` / `findAny()` mistakes, and overcorrected collection streams.

## Community Standards

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md) in issues, pull requests, discussions, and
reviews.

AI-assisted contributions are welcome. If AI materially helped with a change, follow the
[AI Contribution Policy](AI_CONTRIBUTION_POLICY.md) and disclose that in the pull request body.

For suspected vulnerabilities, don't open a public issue. Follow the private reporting path in the
[Security Policy](SECURITY.md).

## Repository Layout

```text
.
├── .tessl-plugin/plugin.json
├── .github/ISSUE_TEMPLATE/
├── .github/pull_request_template.md
├── .github/workflows/
├── evals/
├── evals-reference/
├── scripts/
├── skills/java-optionals/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/
│       ├── hard-stops.md
│       ├── java-optional-api.md
│       └── optional-examples.md
├── docs/agents/
│   ├── evals.md
│   ├── workflow.md
│   └── ...
├── AI_CONTRIBUTION_POLICY.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

- `.github/ISSUE_TEMPLATE/` and `.github/pull_request_template.md` guide public issues and pull
  requests.
- `skills/java-optionals/SKILL.md` is the runtime instruction file loaded by agents.
- `skills/java-optionals/agents/openai.yaml` provides display metadata.
- `skills/java-optionals/references/hard-stops.md` lists replacement antipatterns and the final
  scan agents should run before finishing Optional cleanup.
- `skills/java-optionals/references/optional-examples.md` contains runtime-safe examples.
- `skills/java-optionals/references/java-optional-api.md` records Java 8 through Java 26
  Optional-family compatibility guidance.
- `docs/agents/` contains current maintainer policy and workflow guidance.
- `evals/` contains the hosted Tessl implementation-regression benchmark used for headline
  reporting.
- `evals-reference/` keeps extra review and test scenarios that are useful during development but
  aren't part of the headline benchmark.
- `scripts/` contains portable validation checks used by CI.
- `.github/workflows/ci.yml` validates skill metadata, eval criteria, Tessl linting, and the
  publish dry-run when `TESSL_TOKEN` is configured.
- `.github/workflows/skill-review.yml` runs `tessl skill review` on pull requests when
  `TESSL_TOKEN` is configured.
- `AI_CONTRIBUTION_POLICY.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md` set expectations for AI
  assistance, project conduct, and private vulnerability reporting.

## Local Setup

Clone the repository, make your change on a branch, and run the local checks below before opening a
pull request. There are no project dependencies to install for the Python validation scripts.

The Tessl CLI is needed for Tessl linting, skill review, publish dry-runs, and hosted evals. If you
don't have Tessl set up locally, still run the Python checks and mention that Tessl checks were not
run in your pull request.

## Local Checks

Run these before committing skill, eval, README, package, script, or CI changes:

```bash
python3 scripts/validate_skill.py skills/java-optionals
python3 scripts/validate_eval_criteria.py evals evals-reference
python3 -m py_compile scripts/validate_skill.py scripts/validate_eval_criteria.py
bash -n scripts/check_publish_dry_run.sh
tessl plugin lint .
```

If you change the skill text or reference files, also run:

```bash
tessl skill review --threshold 90 skills/java-optionals/SKILL.md
```

The threshold is intentionally below 100 so useful, specific guidance doesn't get removed only to
make the review score look cleaner. Treat the review output as a quality signal and address valid
feedback.

If you have Tessl access, you can also run the publish dry-run:

```bash
bash scripts/check_publish_dry_run.sh .
tessl plugin publish --dry-run --bump patch .
```

The script runs the fast skipped-eval package smoke check and retries with a patch bump if the
current version already exists. `tessl plugin publish --dry-run --bump patch .` is a PR-safe
local/manual full eval-ingesting dry-run when the current manifest version may already exist.
PR CI runs tokenless validation and plugin lint. Authenticated Tessl publish dry-runs run only on
trusted `main` pushes and release/publish workflows. Release publishing uses exact-version
`tessl plugin publish --dry-run .` immediately before `tessl plugin publish .`.

`tessl skill review`, `bash scripts/check_publish_dry_run.sh .`, and hosted evals require Tessl
authentication. Hosted evals also require a linked Tessl project. If you don't have access, include
the local checks you did run and say which Tessl checks need maintainer help.

## Commit Messages

Pull request titles and commits must use Conventional Commits. CI checks both the pull request title
and every commit in the pull request.

Use this shape:

```text
type(optional-scope): short description
```

Keep the description short, lowercase, and written as an action or result. Don't end it with a
period.

Common types in this repository:

- `feat`: user-facing skill behavior, new guidance, or new benchmark coverage.
- `fix`: correct wrong guidance, broken metadata, validation, CI, or release behavior.
- `docs`: README, contributing guide, source notes, examples, or contributor docs.
- `test`: eval scenarios, eval criteria, or validation coverage.
- `ci`: GitHub Actions, Renovate, Release Please, or publishing automation.
- `chore`: repository maintenance that doesn't change user-facing behavior.
- `refactor`: restructure docs, scripts, or skill text without changing behavior.

Scopes are optional. Use one when it makes the change easier to scan:

```text
feat(skill): add selector fallback guidance
test(evals): cover eager fallback regression
docs(readme): clarify why the skill exists
ci(renovate): wait seven days before update PRs
fix(release): publish Tessl releases with evals
```

Avoid vague or non-conventional messages:

```text
update stuff
fixes
README changes
WIP
```

Release Please uses Conventional Commits after changes land on `main`:

- `feat` normally creates a minor release.
- `fix` normally creates a patch release.
- `feat!`, `fix!`, or a `BREAKING CHANGE:` footer creates a major release.
- `docs`, `ci`, `chore`, `refactor`, and `test` usually don't create a release by themselves unless
  they include a breaking-change marker.

For breaking changes, use either form:

```text
feat!: change skill activation contract
```

or:

```text
feat: change skill activation contract

BREAKING CHANGE: agents must now load the skill through the new package name.
```

If your branch has several small commits, each commit still needs a valid message. It's fine to keep
history simple and use one clear commit for a focused pull request.

## Hosted Evals

Hosted evals are useful when a change affects the skill behavior, benchmark scenarios, or README
score claims. They require Tessl authentication and a linked Tessl project.

If you have your own Tessl workspace, link your checkout to your own project and run:

```bash
tessl eval run --variant with-context --variant without-context .
```

If you don't have a Tessl workspace, that's fine. Open the pull request with the local check results,
and a maintainer can run the hosted evals before release.

The headline benchmark should stay focused on realistic tasks that mirror the motivating failures.
It must include a documented mix of natural activation prompts and explicit invocation prompts.
Natural scenarios must not mention `$java-optionals` or ask to use the skill. Explicit scenarios may
name the skill and must be labeled as explicit in `criteria.json`.

Every scenario directory must contain `task.md`, `criteria.json`, and `capability.txt`. Headline
implementation criteria must include compile/artifact checks and behavior correctness checks as
safety checks, but the headline score should mainly measure Optional-specific quality. Each headline
criterion must also set `category` to `safety`, `optional_quality`, or `maintainability` so
benchmark reports can separate Optional quality from compile/behavior checks. For headline
scenarios, use roughly `15` safety points, `80` Optional-quality points, and `5` maintainability
points per 100-point scenario unless a scenario has a documented reason to differ. Do not hide
baseline-solved scenarios just to improve lift; move them to `evals-reference/` when they're better
as regression coverage and report that separately.

Runtime skill references must not contain eval inventories, expected answers, score rubrics, hosted
run IDs, or benchmark claims. Put maintainer-only eval history in `docs/agents/`.

## Benchmark Updates

When the hosted benchmark changes:

- record the run ID;
- record the content commit;
- update baseline and skill scores;
- update lift, raw score ratio, and missed-point reduction;
- update the Optional-quality subtotal;
- report natural activation, explicit invocation, headline combined, and reference/full results
  separately when available;
- keep the README wording clear about what the benchmark measures and avoid stale fixed claims.

## Release Checklist

Releases are handled by maintainers. Release Please opens or updates a release pull request after
changes land on `main`. Merging that release pull request updates `CHANGELOG.md`, bumps
`.tessl-plugin/plugin.json`, creates the GitHub release, and then publishes the Tessl plugin from the
publish workflow.

Before merging a release pull request:

- run local checks;
- run hosted evals or confirm the current benchmark is still valid;
- test the skill against at least one Java Optional change outside this repository;
- confirm `README.md` stays user-focused;
- confirm contributor-only process details live here.

## Dependency Updates

Renovate keeps GitHub Actions, commitlint, and pinned action digests current. Major updates need
manual approval from the dependency dashboard.
