# Eval Guidance

## Scope

Use this when editing `evals/`, `evals-reference/`, `evals-regression/`, skill evals,
benchmark claims, or scoring rules.

## Rules

- Don't cheat. Don't leak the diagnosis or desired fix in eval prompts.
- Keep natural activation prompts neutral. Explicit invocation prompts may name `$java-streams`, but
  should not leak the desired fix beyond invoking the skill.
- The main eval should focus on realistic failure modes where this skill should change the answer:
  Java stream code that may materialize
  unnecessarily, count for existence, sort for one extreme, mishandle order, misuse collectors,
  miss primitive streams, or overuse parallel streams.
- Keep a documented mix of invocation styles:
  - Natural activation scenarios don't mention `$java-streams`, "use the skill", or similar
    command-style phrasing.
  - Explicit invocation scenarios may say `Use $java-streams`.
  - Report natural, explicit, main eval combined, reference, and regression results separately when
    hosted data is available.
- Include evals where the agent writes new stream code, not only reviews or refactors snippets.
- Review-only or no-op evals must still require a concrete artifact, such as `review.md`.
- Context-dependent workflow evals ask for exact text, commands, or procedures that only the skill
  context provides, such as the hard-stop scan header and `rg` command. Keep them in
  `evals-regression/` as explicit with-context workflow-use evidence. Do not count them in the main
  or reference lift score, do not describe them as natural activation or independent Java stream
  reasoning, and do not call weighted checklist items hard gates.
- Keep three eval buckets:
  - `evals/` is the main eval set used for public lift reporting.
  - `evals-reference/` is for candidate, diagnostic, and broad coverage scenarios that may still
    help tune or promote future main evals.
  - `evals-regression/` is for scenarios that hosted history shows are consistently solved by both
    with-context and without-context, plus explicit context-dependent workflow checks that are only
    fair as with-context regression coverage. These protect against regressions but should not be
    part of normal lift discovery runs.
- Every scenario directory must contain `task.md`, `criteria.json`, and `capability.txt`.
- Every `criteria.json` must classify `metadata.invocation` and `metadata.task_type`.
- Every main eval criterion must classify `category` as `safety`, `stream_quality`, or
  `maintainability`.
- Main eval implementation scenarios need compile/artifact and behavior checks as safety checks, but
  the public benchmark should be weighted toward `stream_quality`.
- For main eval scenarios, use roughly `15` safety points, `80` stream-quality points, and `5`
  maintainability points per 100-point scenario unless a scenario has a documented reason to differ.
- Runtime skill references must not contain eval inventories, expected answers, score rubrics,
  hosted run IDs, or fixed score claims.
- Active evals must not be near-copies of runtime reference examples. It is fine for an eval to test
  `Gatherers.mapConcurrent`, `Collectors.teeing`, `takeWhile`, or `dropWhile`; it is not fine to
  reuse the same domain class, method, record, constant, and carrier pattern from a runtime example.
- Active and reference/regression tasks must not be exact or near-exact duplicates. If a reference
  scenario is promoted or replaced by active coverage, delete or materially rewrite the reference
  copy and document the numbering gap.
- Every Java scenario must state the Java version to assume, such as `Assume Java 17.`.
- If the baseline is too high, first check whether the eval is too generic or too easy before
  changing the skill.
- With-context must be 100% for every retained scenario in every suite. If with-context is below
  100%, the scenario is not ready to classify or report. Fix the skill or eval in place and run that
  scenario targeted until it is clean before running broader suites. Do not move failing
  with-context scenarios to hide them.
- Promote or demote scenarios based on purpose and evidence:
  - `with-context < 100`: fix/rerun targeted before choosing or changing a suite.
  - `with-context = 100` and `without-context < 100`: useful lift evidence; keep in main or
    reference depending on coverage, delta, and weighting.
  - `with-context = 100` and `without-context = 100`: regression coverage.
  - `with-context = 100` and without-context is intentionally not applicable because the scenario
    depends on exact skill-provided workflow text: regression coverage.
- Classify new scenarios with the same evidence rule every time:
  - Draft ordinary new scenarios in `evals-reference/`.
  - Draft context-dependent workflow scenarios that require exact skill-provided text, commands, or
    procedures, such as the hard-stop scan command, in `evals-regression/`.
  - Run the scenario in isolation with `scripts/run_eval_suite.sh reference <scenario-name>` for
    ordinary scenarios or `scripts/run_eval_suite.sh regression <scenario-name>` for
    context-dependent workflow scenarios.
  - Save `tessl eval view <run-id> --json` output and run
    `scripts/classify_eval_result.py <run-json> --scenario-dir <scenario-dir>`.
  - Follow the classifier unless there is a documented maintainer reason to override it. The
    default rule is: with-context below 100 -> fix required before classification;
    context-dependent workflow -> regression once with-context is 100; both variants 100 ->
    regression; clean with-context plus without-context below 100 -> reference or main depending on
    delta, coverage, and weighting.
- Main promotion floor: a new scenario should not move to main unless its percentage-point delta is
  at least as strong as the weakest current main scenario and it improves capability coverage. The
  current floor is 27.5 percentage points, from `04-invoice-bounds-and-temperature-windows`
  (`200/200` with context, `145/200` without context). Update this floor whenever main eval
  membership, scoring, or hosted results change.
- Main weighting policy:
  - Keep weights evidence-weighted, not evenly sampled.
  - Give more total points to scenario families with larger observed missed-point reduction, while
    keeping the skill broadly about Java Streams and Collectors.
  - Normalize ordinary 100-point main scenarios around 15 safety, 80 stream-quality, and 5
    maintainability points unless the scenario has a documented reason to differ.
  - Use `main_eval_weight_multiplier` only when a scenario family has stronger hosted delta or higher
    benchmark importance; document why in `criteria.json` metadata and this file.
  - Do not add or inflate weak-delta scenarios only to make coverage look balanced.
- A 2x raw score ratio is useful only when earned by honest, realistic eval design. Don't suppress
  legitimate coverage just to improve lift.
- Track raw score, percentage-point lift, raw score ratio, missed-point reduction, and the
  `stream_quality` subtotal when updating benchmark claims.
- Use `scripts/run_eval_suite.sh` for hosted evals. It runs from a temporary plugin copy so
  with-context variants can see the skill bundle, and it enforces the suite variant policy. Use
  Sonnet 4.6 unless intentionally comparing another model.

  ```bash
  scripts/run_eval_suite.sh main
  scripts/run_eval_suite.sh reference
  scripts/run_eval_suite.sh regression
  ```

- Direct equivalent for this repository's main eval runs:

  ```bash
  tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context .
  ```
- Run variants by suite purpose:
  - `evals/` main: always run both `without-context` and `with-context`, because it supports public
    lift reporting.
  - `evals-reference/`: always run both `without-context` and `with-context`, because it is used to
    find meaningful lift and promotion candidates.
  - `evals-regression/`: run `with-context` only by default, because it is safety coverage rather
    than lift discovery. Run `without-context` for regression only when intentionally checking
    whether a scenario should move back to reference.
- Keep hosted eval usage minimal while preserving confidence:
  - For skill or eval changes, first run only the affected scenario directories, using the variant
    rule above for the suite the scenario belongs to.
  - If any affected with-context result is below 100%, keep rerunning only those targeted scenarios
    after fixes until they are clean.
  - Then run `evals/` for the main score.
  - Run relevant `evals-reference/` scenarios with both variants when deciding promotion or checking
    nearby behavior.
  - Run `evals-regression/` with context only as a final safety check before release or after broad
    changes, not on every tuning loop.

## Current Suite Composition

Update this section whenever active eval membership or scoring changes.

- Main eval set: 5 active scenarios, 1500 total checklist points.
- Natural activation subset: 2 scenarios.
- Explicit invocation subset: 3 scenarios.
- Hard-stop scan audits: regression explicit workflow-use only.
- Reference suite: 2 scenarios, 160 total checklist points. Deleted reference number 12 and
  regression-moved scenarios are not counted.
- Regression suite: 19 scenarios, 1820 total checklist points.
- Latest hosted evidence: full main run `019e9f67-8102-7517-8d4b-d2044a1d3f08`, plus targeted
  scenario 04 rerun `019e9f7d-d65b-724f-9dd0-900db4d0c7b3` after clarifying chronological reading
  order in the prompt. The main numbers below exclude the demoted hard-stop workflow scenario from
  the full run and replace scenario 04's original baseline score with the targeted rerun score.
  - Combined: with-context 1500 / 1500, without-context 628 / 1500, raw score ratio 2.39x.
  - Natural subset: with-context 500 / 500, without-context 146 / 500.
  - Explicit subset: with-context 1000 / 1000, without-context 482 / 1000.
  - Demoted hard-stop workflow scenario: with-context 100 / 100, without-context 83 / 100; report
    this only as with-context workflow regression evidence.
- Latest reference-suite hosted run: `019e9f8c-775f-75a8-bcb1-dd6ebe8f43d7` on this branch.
  Scenarios that scored 100 / 100 in both variants were moved to `evals-regression/`.
  Context-dependent hard-stop scan workflow scenarios were also moved to `evals-regression/`,
  because their exact scan-command recall is only fair as with-context regression coverage.
  - Remaining nonzero positive reference deltas: CPU-heavy parallel review 5 percentage points,
    primary-contact review 5 percentage points.
- Targeted rerun `019e9fa8-ccf2-77c7-885f-2cba4939e16f` confirmed
  `16-java11-report-review` at with-context 100 / 100 and without-context 100 / 100 after a rubric
  precision fix, so it moved to `evals-regression/`.

## Checks

Run the shared validation commands in [Workflow](workflow.md). When editing eval criteria, also run
the criteria JSON check listed there.

## References

- [Workflow](workflow.md)
- [Skill Behavior](skill-behavior.md)
