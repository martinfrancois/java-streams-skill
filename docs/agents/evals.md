# Eval Guidance

## Scope

Use this when editing `evals/`, `evals-reference/`, `evals-regression/`, skill evals,
benchmark claims, or scoring rules.

## Rules

- Don't cheat. Don't leak the diagnosis or desired fix in eval prompts.
- Run quality review first, and if it is below 100%, stop and fix all quality issues before any new
  hosted eval rerun. Then execute targeted evals for every changed scenario, and only progressively
  broaden suites after targeted runs are clean. Preserve the daily budget by stopping at each stage
  unless failures require another targeted rerun; only then proceed to broader hosted checks. If a
  broad run shows any with-context below 100%, stop that run and return to targeted reruns for failed
  scenarios only.
- Use the pre-submit gate before your first hosted command:

  ```bash
  scripts/pre_submit_gate.sh --plan-only
  ```

  Then execute only the printed targeted stages. The gate now enforces that each stage reaches
  100% with-context before allowing expansion to the next stage.
- Keep natural activation prompts neutral. Explicit invocation prompts may name `$java-streams`, but
  should not leak the desired fix beyond invoking the skill. Mark prompts that name `$java-streams`
  as `metadata.invocation: "explicit"` and do not report them as natural activation evidence.
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
- Skill-context-dependent evals require information that only comes from the skill package or agent
  instructions, such as exact wording, commands, procedures, checklists, headers, or bundled
  reference text. Keep them in `evals-regression/` once with-context is 100%, regardless of the
  without-context score. Do not count them in the main or reference lift score, do not describe them
  as natural activation or independent Java stream reasoning, and do not call weighted checklist
  items hard gates.
- Keep three eval buckets:
  - `evals/` is the main eval set used for public lift reporting.
  - `evals-reference/` is for candidate, diagnostic, and broad coverage scenarios that may still
    help tune or promote future main evals.
  - `evals-regression/` is for scenarios that hosted history shows are consistently solved by both
    with-context and without-context, plus skill-context-dependent checks that are only fair as
    with-context regression coverage. These protect against regressions but should not be part of
    normal lift discovery runs.
- Every scenario directory must contain `task.md`, `criteria.json`, and `capability.txt`.
- Every `criteria.json` must classify `metadata.invocation` and `metadata.task_type`.
- Use `metadata.evidence_type` when scenario placement needs to be explicit:
  - `ordinary_lift`: an ordinary main or reference scenario where both variants are fair to compare.
    This value is invalid in `evals-regression/`, and it must not be used when the task overlaps
    same-domain runtime skill references.
  - `focused_main`: a main-suite scenario that intentionally covers a specific skill behavior and
    may share bounded, documented runtime-reference overlap. Report it separately from ordinary
    broad natural lift.
  - `focused_reference`: a reference-suite scenario that intentionally emphasizes a specific skill
    behavior or behavior delta. It may carry high weight on that focused behavior, but it is not
    ordinary broad lift or unseen generalization evidence.
  - `solved_regression`: a regression scenario that hosted history shows both variants solve at
    100%. This value is invalid outside `evals-regression/`.
  - `skill_context_dependent`: a regression scenario that requires exact skill-provided text,
    commands, procedures, checklists, headers, or bundled reference text. This value is required for
    such scenarios and is invalid outside `evals-regression/`.
- Every main eval criterion must classify `category` as `safety`, `stream_quality`, or
  `maintainability`.
- Main eval implementation scenarios need compile/artifact and behavior checks as safety checks, but
  the public benchmark should be weighted toward `stream_quality`.
- For main eval scenarios, use roughly `15` safety points, `80` stream-quality points, and `5`
  maintainability points per 100-point scenario unless a scenario has a documented reason to differ.
- Runtime skill references must not contain eval inventories, expected answers, score rubrics,
  hosted run IDs, or fixed score claims.
- Don't cheat by leaking the desired fix in task prompts, and don't treat runtime-reference overlap
  as ordinary lift. Same-domain or near-solution overlap between runtime skill references and eval
  tasks is allowed only for explicitly classified focused main, focused reference, or regression
  evidence.
- Metadata rationale documents why an overlap classification is honest; it does not bypass
  validation by itself. Vague words such as "focused", "coverage", "kept", or "intentional" are not
  enough unless the suite placement and `metadata.evidence_type` agree.
- Active main/general evals must stay neutral. It is fine for an eval to test `Gatherers.mapConcurrent`,
  `Collectors.teeing`, `takeWhile`, or `dropWhile`; it is not fine for ordinary broad lift evidence
  to reuse the same domain identifiers, record names, method names, constants, thresholds, long
  phrasing, or near-solution helper shapes from a runtime example.
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
- For external-mutation evals, criteria should fail unsafe shared mutation, not pure parallelism
  itself. A pure ordered `parallelStream().map(...).toList()` answer can be correct for a large
  CPU-bound implementation task, while a review task should still require measurement and small-list
  caveats before recommending parallelism as a performance fix.
- Promote or demote scenarios based on purpose and evidence:
  - `with-context < 100`: fix/rerun targeted before choosing or changing a suite.
  - `with-context = 100` and `without-context < 100`: useful lift evidence; keep in main or
    reference depending on coverage, delta, and weighting.
  - `with-context = 100` and `without-context = 100`: regression coverage.
  - `with-context = 100` and the scenario requires skill-only context, exact skill-provided text, a
    bundled command, or a skill-specific procedure: regression coverage, regardless of the
    without-context score.
- Classify new scenarios with the same evidence rule every time:
  - Draft ordinary new scenarios in `evals-reference/`.
  - Draft skill-context-dependent scenarios that require exact skill-provided text, commands,
    procedures, checklists, headers, or bundled reference text in `evals-regression/` and set
    `metadata.evidence_type` to `skill_context_dependent`.
  - Run the scenario in isolation with `scripts/run_eval_suite.sh reference <scenario-name>` for
    ordinary scenarios or `scripts/run_eval_suite.sh regression <scenario-name>` for
    skill-context-dependent scenarios.
  - Save `tessl eval view <run-id> --json` output and run
    `scripts/classify_eval_result.py <run-json> --scenario-dir <scenario-dir>`.
  - Follow the classifier unless there is a documented maintainer reason to override it. The
    default rule is: with-context below 100 -> fix required before classification;
    skill-context-dependent -> regression once with-context is 100, regardless of without-context
    score; both variants 100 -> regression; clean with-context plus without-context below 100 ->
    reference or main depending on delta, coverage, and weighting.
- Main promotion floor: a new scenario should not move to main unless its percentage-point delta is
  at least 30 percentage points and it improves capability coverage. Treat 30 pp as maintainer
  policy for future promotion or demotion decisions, not as a current hosted benchmark result. Old
  hosted deltas are historical evidence only; do not use them for release-readiness claims, public
  score/lift claims, or current benchmark claims until they are rerun against the current active
  suite membership, denominator, commit/ref, natural/explicit split, and pinned CLI behavior.
- Main weighting policy:
  - Keep weights evidence-weighted, not evenly sampled.
  - Do not describe the main eval set as representative of all Java Stream and Collector work.
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
- Use `scripts/run_eval_suite.sh` for hosted evals. It runs from a temporary plugin copy, passes
  `--skill java-streams` so with-context runs actually exercise this skill, passes `--force` so
  post-fix checks cannot reuse stale hosted solutions, and enforces the suite variant policy. Use the
  Tessl default solver unless intentionally comparing another model. If the account has
  model-selection entitlement, Sonnet 4.6 or a better frontier model is recommended for a more
  representative real-world check.

  ```bash
  scripts/run_eval_suite.sh main
  scripts/run_eval_suite.sh reference
  scripts/run_eval_suite.sh regression
  ```

- Direct equivalent for this repository's main eval runs:

  ```bash
  tessl eval run --skill java-streams --force .
  ```
  The Tessl CLI runs the baseline control by default when plugin context is present. Use
  `--skip-baseline` only for context-only regression runs. Public docs may still show tile-oriented
  examples; for this repository, use the pinned CLI and `scripts/run_eval_suite.sh` as the source of
  truth.
  Tessl's public changelog notes that model and agent selection are plan-entitlement-gated:
  <https://docs.tessl.io/changelog>. Tessl also documents why the default eval solver is not pinned
  to Sonnet 4.6 for ordinary skill-development checks:
  <https://tessl.io/blog/why-were-changing-our-default-eval-model/>. Check
  `tessl eval run --list-agents` for the current default because Tessl can change it over time.
- Run variants by suite purpose:
  - `evals/` main: always run both baseline control and `with-context`, because it supports public
    lift reporting.
  - `evals-reference/`: always run both baseline control and `with-context`, because it is used to
    find meaningful lift and promotion candidates.
  - `evals-regression/`: run `with-context` only by default, because it is safety coverage rather
    than lift discovery. Run `without-context` for regression only when intentionally checking
    whether a scenario should move back to reference.
- Keep hosted eval usage minimal while preserving confidence and Tessl daily rate-limit budget:
  - Freeze runtime skill text before hosted spending whenever possible. The expensive failure mode is
    not the final all-suite requirement itself; it is rerunning required evidence after later edits to
    `skills/java-streams/SKILL.md` or bundled runtime references change the skill fingerprint. Do the
    local scenario/criteria crosswalk and obvious skill wording fixes before starting hosted runs.
  - A pure suite move does not require a hosted rerun when `task.md`, `criteria.json`, and
    `capability.txt` content are unchanged except for suite-placement metadata or numbering notes.
    Run local validators and update suite totals/numbering instead. If the move also changes task
    wording, scoring criteria, capability text, runtime skill behavior, or benchmark claims, follow
    the targeted rerun rules below.
  - For any eval scenario edit, first run every changed scenario directory, using the variant rule
    above for the suite the scenario belongs to. This is mandatory for changes to `task.md`,
    `criteria.json`, or `capability.txt`, including wording-only prompt edits and metadata/scoring
    clarifications.
  - Do not finish the PR, update benchmark claims, or call the suite release-ready until every
    changed scenario has a 100% with-context result. If Tessl hosted evals are unavailable, document
    the blocker and exact remaining targeted runs in the PR; benchmark and release-readiness claims
    remain blocked until those runs pass.
  - For runtime skill text or runtime reference changes, start with the affected scenario
    directories most likely to move, using the suite variant rule above. Use the pre-submit gate's
    impact-analysis suggestions for runtime-only changes when no maintainer-specified focus is
    obvious, and keep historical risk probes in the early targeted pass.
  - After quality is 100 and targeted probes are clean, switch to balanced broad chunks for the
    remaining required evidence. Do not keep broadening one scenario at a time unless a fresh broad
    failure is likely and conserving eval-solutions is more important than elapsed time.
  - If any affected with-context result is below 100%, keep rerunning only those targeted scenarios
    after fixes until they are clean.
  - Then run the remaining `evals/` scenarios for the main score, excluding scenarios already proven
    clean after the last skill bundle change.
  - Run relevant `evals-reference/` scenarios with both variants when deciding promotion or checking
    nearby behavior.
  - Before final release/open-source-ready claims after a runtime skill change, run every reference
    scenario with both variants and every regression scenario with context only. This evidence may be
    split across targeted and broad runs, and already-proven scenarios should be excluded from later
    broadening as long as they passed after the last change to the skill bundle.
  - Run `evals-regression/` with context only as a final safety check before release or after broad
    changes, not on every tuning loop.
  - If a broad run exposes isolated failures, fix those exact scenarios and rerun them targeted
    before spending rate-limit budget on another broad suite run. Preserve successful scenario-level
    evidence from the same final skill state instead of rerunning it only because another scenario in
    the suite failed.
  - Never rerun a hosted eval merely because it looks stuck, slow, pending, or temporarily missing
    scoring. Tessl scoring can lag after scenario execution. Keep polling the existing run with
    `tessl eval view <run-id> --json` and wait for completion or a hard service failure; only rerun
    after a completed scored failure and a relevant fix, or after Tessl reports a non-recoverable run
    failure.
  - Never poll hosted evals with an unbounded loop or a bare `tessl eval run`. Poll the specific
    existing run ID with bounded attempts, visible output, and a stop condition; if unexpected
    background eval work appears, inspect process ancestry and Codex session logs before explaining
    where it came from.
  - For budgeting sanity, run the full suite stages incrementally and confirm each stage with
    100% with-context before the next one:
    budget-aware remaining suites from `scripts/pre_submit_gate.sh`, or a maintainer-approved
    explicit order via `--broad-order`.
  - If the change is runtime-wide and no scenario edit exists, prefer a scoped focus run first (via
    `--focus <scope>:<scenario>`) before any broad suite rerun.

## Current Suite Composition

Update this section whenever active eval membership or scoring changes.

- Main eval set: 4 active scenarios, 1400 total checklist points.
- Natural activation subset: 1 scenario.
- Explicit invocation subset: 3 scenarios.
- Java 24 bounded remote-call / `Gatherers.mapConcurrent` coverage: 3 scenarios, 1200 checklist
  points. This dominates the current main score because hosted evidence previously showed strong
  deltas in that family; do not over-read it as broad Java Streams coverage.
- Scenarios `01-offer-availability-mapconcurrent` and `02-delivery-appointments-mapconcurrent` are
  intentionally focused Java 24 runtime-guidance coverage. They should remain different domains and
  result-carrier patterns from the bundled bounded `Gatherers.mapConcurrent` example in
  `stream-examples.md`; report them as focused skill-use coverage rather than broad independent lift
  evidence.
- Java 17 collector and prefix-operation coverage: 1 scenario, 200 checklist points.
- Uppercase side-effect review moved from main number `07` back to reference number `26` because it
  remains useful explicit reference lift evidence for external mutation and parallelism advice, but
  the main suite should stay focused on the strongest evidence-weighted coverage. Keep it in
  reference unless future current-suite evidence shows that it meets the 30 pp floor and improves
  main coverage.
- Session roster indexing moved from main number `06` to reference number `15` because hosted
  evidence showed the without-context result was already high while with-context was clean, and the
  runtime references contain same-domain session-registration examples. It remains useful focused
  natural Java 17 collector coverage, but it is not ordinary broad lift evidence.
- Overdue shipment notices is focused reference coverage for extracting non-trivial stream lambda
  bodies into helpers. Its high multi-line-lambda criterion weight is intentional focused
  behavior-delta coverage, not ordinary broad lift evidence.
- Hard-stop scan audits: regression explicit workflow-use only.
- Reference suite: 6 scenarios, 560 total checklist points. Deleted reference number 12 and
  regression-moved scenarios are not counted.
- Regression suite: 19 scenarios, 1820 total checklist points.
- Hosted benchmark evidence is pending rerun for the current active suite. Do not publish exact
  run IDs, baseline scores, with-context scores, or lift ratios until they are verified against the
  current `evals/` contents, denominators, natural/explicit split, and commit/ref.
- Scenario movement notes in `evals/NUMBERING.md`, `evals-reference/NUMBERING.md`, and
  `evals-regression/NUMBERING.md` preserve historical classification rationale, but they are not
  current benchmark claims.

## Checks

Run the shared validation commands in [Workflow](workflow.md). When editing eval criteria, also run
the criteria JSON check listed there.

## References

- [Workflow](workflow.md)
- [Skill Behavior](skill-behavior.md)
- [Pre-Submit Gate](pre-submit-gate.md)
