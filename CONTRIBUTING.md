# Contributing

Thanks for helping improve the Java Streams Skill.

This project helps AI coding agents write, review, and clean up Java Stream and Collector code
without common stream antipatterns. You don't need maintainer access or a Tessl workspace to make
most useful contributions.

Keep changes focused on observed failure modes: materializing just to inspect, counting for
existence, sorting just to get one extreme, careless `findFirst()` / `findAny()` changes, boxed
numeric reductions, nested collection stream chains, unsafe `toMap`, null-sensitive sorting, Java
baseline drift, and casual `parallelStream()` usage.

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
├── skills/java-streams/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/
│       ├── hard-stops.md
│       ├── java-stream-api.md
│       └── stream-examples.md
├── docs/agents/
├── AI_CONTRIBUTION_POLICY.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

- `skills/java-streams/SKILL.md` is the runtime instruction file loaded by agents.
- `skills/java-streams/agents/openai.yaml` provides display metadata.
- `skills/java-streams/references/hard-stops.md` lists replacement antipatterns and the final scan.
- `skills/java-streams/references/stream-examples.md` contains runtime-safe examples.
- `skills/java-streams/references/java-stream-api.md` records Java-version compatibility guidance.
- `docs/agents/` contains current maintainer policy and workflow guidance.
- `evals/` contains the hosted Tessl main eval set used for lift reporting.
- `evals-reference/` keeps extra regression scenarios that should not drive main eval lift claims.
- `scripts/` contains portable validation checks used by CI.

## Local Checks

Run these before committing skill, eval, README, package, script, or CI changes:

```bash
python3 scripts/validate_skill.py skills/java-streams
python3 scripts/validate_eval_criteria.py evals evals-reference
python3 -m py_compile scripts/validate_skill.py scripts/validate_eval_criteria.py
bash -n scripts/check_publish_dry_run.sh
tessl plugin lint .
```

If you change the skill text or reference files, also run:

```bash
tessl skill review --threshold 100 skills/java-streams/SKILL.md
```

If you have Tessl access, run the publish dry-run:

```bash
bash scripts/check_publish_dry_run.sh .
tessl plugin publish --dry-run --bump patch .
```

Hosted evals require Tessl authentication and a linked Tessl project. Use Sonnet 4.6 for this
repository's main eval checks:

```bash
tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context .
```

## Commit Messages

Pull request titles and commits must use Conventional Commits. CI checks both the pull request title
and every commit in the pull request.

Use this shape:

```text
type(optional-scope): short description
```

Common types in this repository:

- `feat`: user-facing skill behavior, new guidance, or new benchmark coverage.
- `fix`: correct wrong guidance, broken metadata, validation, CI, or release behavior.
- `docs`: README, contributing guide, source notes, examples, or contributor docs.
- `test`: eval scenarios, eval criteria, or validation coverage.
- `ci`: GitHub Actions, Renovate, Release Please, or publishing automation.
- `chore`: repository maintenance that doesn't change user-facing behavior.
- `refactor`: restructure docs, scripts, or skill text without changing behavior.

## Hosted Evals

In this repository, the main eval set lives in `evals/` and is used for public lift reporting.
`evals-reference/` contains broader regression coverage that helps catch regressions but does not
directly drive the main lift claim.

The main eval set should stay focused on realistic tasks where context should improve stream
quality. It must include natural activation prompts and explicit invocation prompts. Natural
scenarios must not mention `$java-streams` or ask to use the skill. Explicit scenarios may name the
skill and must be labeled as explicit in `criteria.json`.

Every scenario directory must contain `task.md`, `criteria.json`, and `capability.txt`. Main eval
implementation criteria must include compile/artifact checks and behavior correctness checks as
safety checks, but the main score should mainly measure stream-specific quality. Each main eval
criterion must set `category` to `safety`, `stream_quality`, or `maintainability`.

Do not hide baseline-solved scenarios just to improve lift. Move them to `evals-reference/` when
they are better as regression coverage and report that separately.

Runtime skill references must not contain eval inventories, expected answers, score rubrics, hosted
run IDs, or benchmark claims. Put maintainer-only eval history in `docs/agents/`.
