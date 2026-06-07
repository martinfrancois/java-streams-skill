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
├── evals-regression/
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
- `evals-reference/` keeps candidate, diagnostic, and broad coverage scenarios that should not
  drive main eval lift claims.
- `evals-regression/` keeps scenarios that hosted history shows are consistently solved by both
  with-context and without-context, plus context-dependent workflow checks that are only fair as
  with-context regression coverage.
- `scripts/` contains portable validation checks used by CI.

## Local Checks

Run these before committing skill, eval, README, package, script, or CI changes:

```bash
python3 scripts/validate_skill.py skills/java-streams
python3 scripts/validate_eval_criteria.py evals evals-reference evals-regression
python3 -m py_compile scripts/*.py
bash -n scripts/*.sh
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
repository's main eval checks. Prefer `scripts/run_eval_suite.sh`; it runs from a temporary plugin
copy so with-context variants can see the skill bundle:

```bash
scripts/run_eval_suite.sh main
```

Run hosted eval variants by suite purpose:

- `evals/`: run both `without-context` and `with-context`; these runs support public lift
  reporting. Use `scripts/run_eval_suite.sh main`.
- `evals-reference/`: run both `without-context` and `with-context`; these runs decide whether a
  scenario has meaningful lift or should move suites. Use `scripts/run_eval_suite.sh reference`.
- `evals-regression/`: run `with-context` only by default; these runs are safety checks, not lift
  discovery. Run regression `without-context` only when deliberately checking whether a scenario
  should move back to `evals-reference/`. Use `scripts/run_eval_suite.sh regression`.

## Commit Messages

Pull request titles and commits must use Conventional Commits. CI checks both the pull request title
and every commit in the pull request.

Use this format:

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
`evals-reference/` contains candidate and diagnostic coverage that helps tune the skill or decide
what to promote later. `evals-regression/` contains solved scenarios and context-dependent workflow
checks; these are useful with-context safety checks, but they do not directly drive the main lift
claim.

The main eval set should stay focused on realistic tasks where context should improve stream
quality. It must include natural activation prompts and explicit invocation prompts. Natural
scenarios must not mention `$java-streams` or ask to use the skill. Explicit scenarios may name the
skill and must be labeled as explicit in `criteria.json`.

Every scenario directory must contain `task.md`, `criteria.json`, and `capability.txt`. Main eval
implementation criteria must include compile/artifact checks and behavior correctness checks as
safety checks, but the main score should mainly measure stream-specific quality. Each main eval
criterion must set `category` to `safety`, `stream_quality`, or `maintainability`.

With-context must be 100% for every retained scenario in every suite. If with-context is below
100%, fix the skill or eval and rerun that scenario targeted before choosing or changing a suite.

Do not hide baseline-solved scenarios just to improve lift. Move baseline-solved scenarios to
`evals-regression/` when hosted evidence shows both variants are 100%. Keep clean low-delta but
still diagnostic scenarios in `evals-reference/`.

When adding a new scenario, classify it from an isolated hosted run:

1. Put ordinary candidate scenarios in `evals-reference/`. Put context-dependent workflow scenarios
   that require exact skill-provided text, commands, or procedures, such as the hard-stop scan
   command, in `evals-regression/`.
2. Run `scripts/run_eval_suite.sh reference <scenario-name>` for ordinary scenarios, or
   `scripts/run_eval_suite.sh regression <scenario-name>` for context-dependent workflow scenarios.
3. Save `tessl eval view <run-id> --json` output and run:

   ```bash
   scripts/classify_eval_result.py <run-json> --scenario-dir <scenario-dir>
   ```

4. Use the recommended suite unless the pull request documents a maintainer-approved reason to
   override it. In short: with-context below 100 means fix required before classification;
   context-dependent workflow checks go to regression once with-context is 100; both variants 100
   goes to regression; clean with-context plus without-context below 100 goes to reference or main
   depending on delta, coverage, and weighting.

The current main promotion floor is 27.5 percentage points, matching the weakest current main
scenario delta. Main eval weights should stay evidence-weighted: put more points on scenario
families with larger observed missed-point reduction, keep ordinary 100-point main scenarios around
15 safety / 80 stream-quality / 5 maintainability points, and document any
`main_eval_weight_multiplier` in `criteria.json` metadata.

When with-context is below 100%, keep the scenario wherever it already lives. Fix the skill or eval
there, then rerun only that targeted scenario until it is clean before running broader suites. After
targeted failures are clean, run `evals/` for the main score, relevant `evals-reference/` scenarios
with both variants for nearby behavior, and `evals-regression/` with context only for final release
safety or broad changes.

Runtime skill references must not contain eval inventories, expected answers, score rubrics, hosted
run IDs, or benchmark claims. Put maintainer-only eval history in `docs/agents/`.

Context-dependent workflow evals are explicit workflow-use scenarios because they ask for exact
skill-provided text, commands, or procedures. Run and report them as with-context regression checks,
not as natural activation, reference lift, or independent Java stream reasoning.
