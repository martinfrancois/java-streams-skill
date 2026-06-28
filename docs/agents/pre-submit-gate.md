# Pre-Submit Gate

## Scope

This page captures the internal pre-submission procedure for skill and eval changes so contributors can
run the same budget-aware sequence every time.

## Rules

- Run `scripts/pre_submit_gate.sh` with `--plan-only` (or `scripts/internal_pr_readiness.sh --plan`)
  before major edits to inspect the planned sequence.
- Run `tessl review run --threshold 100 skills/java-streams/SKILL.md` first for any content change in
  runtime references, runtime checks, or eval logic. If this fails, stop immediately and fix quality.
- `scripts/pre_submit_gate.sh` executes eval runs with JSON capture and validates that every scenario is
  100% with-context before allowing the sequence to advance. If any scenario is below 100% or
  missing with-context scoring, fix those scenarios and rerun only the failing scope.
- Wait for Tessl to mark the whole eval run `completed` before advancing, even if the with-context
  variant has already scored 100%. Main/reference runs may still have baseline solves or scores in
  flight, and starting the next stage early can create avoidable overlapping hosted work.
- The hard goal for runtime skill changes is: after the last change to `skills/java-streams/SKILL.md`
  or any file in that skill bundle, quality review is 100 and every retained scenario in `evals/`,
  `evals-reference/`, and `evals-regression/` has 100% with-context evidence for that exact skill
  bundle state. Evidence can be split across targeted and suite runs.
- Track evidence per scenario, not per suite label. Once a scenario has already passed 100%
  with-context for the current skill bundle fingerprint, do not rerun it merely because its suite is
  being broadened. Run only the remaining scenarios that lack valid evidence.
- For runtime/skill-text changes, run only the affected scope first, then continue to full `main`,
  `reference`, and `regression` suites once targeted checks pass.
- For non-runtime edits, use targeted scope only.
- Do not spend budget on broad suites while a targeted with-context failure is known. If a targeted
  run is below 100% with-context, fix that issue and rerun only the failed targeted scenario(s).
- Run ordered targeted probes in tiny batches by default. One scenario per targeted hosted run is
  usually the best eval-solution budget tradeoff: if the probe fails, the gate stops after the
  smallest possible hosted surface; if it passes, the scenario still counts toward final evidence.
  The default order is manual focus, history-ranked risk probes, impact-analysis probes, then
  directly changed scenario directories that were not already covered.
- Only after targeted with-context is clean should broader checks be run:
  1. remaining `main`
  2. remaining `reference`
  3. remaining `regression` (context only).
- After each hosted run stage, require an explicit confirmation of 100% with-context before moving on.
- Treat pending or slow hosted eval runs as normal. Do not rerun a hosted eval because it appears
  stuck, slow, or missing scoring; patiently wait and poll `tessl eval view <run-id> --json` until
  Tessl reports completed scoring or a hard service failure. A slow pending run can later produce
  valid scoring, while a rerun burns duplicate eval budget and can create confusing overlapping
  evidence.
- Never use unbounded loops for hosted evals, reviews, or other external/quota-consuming commands.
  Poll a specific run ID with bounded attempts, a sleep interval, visible output, and a clear stop
  condition. Do not suppress all output from long-running hosted commands, because hidden output can
  mask runaway behavior.
- If unexpected background eval/review work appears, audit both local process ancestry and Codex
  session logs before explaining the cause. When a Codex tool call started the process, state that
  directly with the timestamp, command, and evidence path instead of softening it as merely
  unintentional.
- If Tessl eval access is blocked (auth/rate-limit/service error), stop at that stage and record exact
  blocked commands; do not claim release-readiness without completion evidence or a blocker note.

## Cost-aware sequencing

To avoid repeated broad failures:

- Treat runtime skill text as frozen before hosted eval spending begins. The biggest budget waste is
  collecting partial or broad evidence, then changing `skills/java-streams/SKILL.md` or bundled
  runtime references and invalidating that evidence. Do local criteria review, obvious wording fixes,
  and quality cleanup first; then start hosted runs.
- Start with the minimum targeted surface first.
- Before hosted evals, do a local criteria crosswalk for changed runtime guidance: read the affected
  scenarios' `task.md` and `criteria.json`, verify the skill text explicitly names the required
  artifact, Java baseline, API, and rejection pattern, and fix obvious gaps before spending hosted
  budget. Hosted evals are for validating behavior, not discovering avoidable wording omissions.
- The default strategy is phase-based, not endlessly one-by-one: local crosswalk and quality first,
  small targeted probes while failure risk is high, then balanced broad chunks once targeted
  evidence is clean and the runtime fingerprint is intentionally frozen.
- Batch only one expansion step per correction cycle (targeted → main → reference → regression).
- Preserve the final code state between stages; if code changes again, restart the sequence.
- Reuse successful run IDs and skip duplicate scenario checks whenever they were produced after the
  last skill bundle change.
- If targeted failures were already rerun and are now clean, subtract those scenarios from the later
  broad suite stage. Example: if `reference/05` and `regression/22` were fixed and rerun at 100%,
  and then full main passes, the next hosted command should run the remaining reference scenarios
  except `05`; the regression stage should likewise exclude `22`.
- If a later stage fails and the fix changes skill bundle content, the fingerprint changes and prior
  evidence is stale. Rerun targeted failures first, then rebuild final evidence from the new state.
- When a mixed broad run has isolated failures, the gate records passing scenarios from that run
  before stopping, so the next cycle can rerun only the failed scenarios and later finish the still
  missing coverage.
- Broad stages should use a middle-ground batch size after targeted probes are clean. The default
  gate chunks remaining scenarios in batches of up to 6 per suite, so small main/reference remainders
  run together and larger regression sweeps do not spend a separate long scoring wait per scenario.
  This does not reduce the all-pass floor, but it balances eval-solution risk against wall-clock
  time. Use `--broad-batch-mode progressive` only when a fresh broad failure is likely and eval
  budget matters more than elapsed time.
- Broad-stage order is budget-aware and does not change the final requirement. The default order is
  `main,reference,regression`; most known failures are already pulled forward by historical risk
  probes, and the remaining broad stage is only for still-unproven scenarios. Use `--broad-order`
  only when current evidence points to a different risk distribution.
- For runtime-only changes, use impact analysis to choose early targeted probes before broadening.
  The analyzer ranks scenarios by overlap between changed skill-bundle text and scenario
  task/capability/criteria text. These are only scheduling hints: they may reduce wasted broad runs,
  but they do not reduce the final evidence floor.
- If the local evidence cache is missing but a valid hosted JSON run exists for the same final skill
  bundle state, ingest it instead of rerunning:

  ```bash
  python3 scripts/eval_evidence.py ingest \
    --file .tessl/eval-evidence/java-streams-pre-submit.json \
    --fingerprint "$(python3 scripts/eval_evidence.py fingerprint --skill-dir skills/java-streams)" \
    --repo-root . \
    --suite reference \
    --run-json /tmp/reference-run.json
  ```

Budget estimate for this repo (useful for planning):

- `scripts/run_eval_suite.sh main` usually submits two variants (baseline + with-context).
- `scripts/run_eval_suite.sh reference` usually submits two variants.
- `scripts/run_eval_suite.sh regression` is typically context-only.
- A full final sequence therefore should be expected to be larger than a single targeted run, so run it
  only when earlier stages are clean.
- Do not optimize below the required final evidence floor. With the current suite composition, a
  fully clean final state requires 39 scenario-solutions: `main` 4 scenarios times 2 variants,
  `reference` 6 times 2, and `regression` 19 times 1. Budget optimizations may remove duplicate or
  stale reruns, but must not remove required scenario coverage or required variants.
- Before a reset-day run, calculate the remaining floor from current evidence and compare it with
  available budget. If the remaining floor is small and targeted evidence is already clean, prefer
  balanced batches to finish quickly instead of continuing with single-scenario broad probes.

Postmortem rule:

- If a tuning cycle consumes far more than the final evidence floor, pause and audit before starting
  more hosted work. Separate unavoidable cost from avoidable burn:
  - unavoidable: final evidence for the current fingerprint, including required variants;
  - avoidable: evidence invalidated by later runtime edits, duplicate runs for slow scoring,
    unbounded loops, broad runs before quality is 100, and hosted runs that reveal wording gaps a
    local criteria crosswalk should have caught.
- Update this process and the gate defaults when the audit finds a better strategy. Prefer durable
  scripted or documented changes over relying on memory.

Run-count examples:

- Three failing scenarios in one suite: fix, rerun them in ordered tiny targeted batches unless
  preserving wall-clock time matters more than solution budget, then run only scenarios still
  missing evidence.
- Two failing scenarios split across reference and regression: fix, rerun one targeted reference run
  and one targeted regression run. If both pass and main later passes, run remaining reference
  scenarios excluding the already-proven reference scenario, then remaining regression scenarios
  excluding the already-proven regression scenario.
- If quality review is below 100, run zero hosted evals until quality is fixed.
- Re-run the parameter sweep when the failure distribution changes materially. Prefer paginated
  Tessl run history over the CLI's default one-page list: the JSON response includes `links.next`,
  which can be followed with the Tessl access token from `~/.tessl/api-credentials.json` without
  starting any new eval runs. Exclude missing-score/incomplete runs from scenario risk ranking; use
  scored below-100 with-context failures as the risk signal.
- Impact-analysis probes save budget when they catch a failure before broad suites. When they pass,
  they still count toward final scenario evidence, so they should not add scenario-solutions beyond
  the required final floor.
- Keep a historical risk-probe list in `docs/agents/eval-risk-probes.txt`. These are scenarios that
  previously had scored with-context failures during skill tuning, ordered by observed failure count
  per hosted solution cost. Run the first six by default for runtime changes, then continue with
  balanced broad chunks. Increase `--risk-limit` only when local criteria crosswalk or recent
  failures indicate a high chance of another broad failure; otherwise too many one-scenario probes
  save little eval budget and cost too much wall-clock time across repeated fingerprints.

## Scenario Evidence Cache

`scripts/pre_submit_gate.sh` stores local scenario evidence in:

```bash
.tessl/eval-evidence/java-streams-pre-submit.json
```

The cache is keyed by a SHA-256 fingerprint of the files under `skills/java-streams/`, including
`SKILL.md` and bundled references. When the skill bundle changes, cached evidence for the previous
fingerprint is ignored automatically.

Useful options:

- `--evidence-file <path>`: use a different evidence cache, useful for simulations.
- `--reset-evidence`: clear the cache before planning.
- `--ignore-evidence`: force all planned scenarios to rerun.
- `--broad-order <order>`: override automatic budget-aware ordering.
- `--impact-limit <n>`: cap runtime-change impact-analysis probes.
- `--no-impact-analysis`: disable impact-analysis probes.
- `--risk-limit <n>`: cap historical risk probes; default is 6.
- `--risk-probe-file <path>`: override the historical risk-probe list.
- `--no-risk-probes`: disable historical risk probes.
- `--target-batch-size <n>`: increase targeted same-suite batch size when wall-clock time is more
  important than minimizing wasted eval-solutions.
- `--broad-batch-mode balanced|progressive|suite`: use balanced broad chunks by default. Choose
  `progressive` when conserving eval solutions matters more than wall-clock time, or `suite` when
  current evidence is very strong and you intentionally want the old full-remaining-suite behavior.

## Internal command

The internal pre-submit tool is:

```bash
scripts/pre_submit_gate.sh
```

Use this internal non-plugin skill wrapper for concise local workflow:

```bash
scripts/internal_pr_readiness.sh --plan
```

Modes:

- `--plan` (default): print the staged run plan.
- `--targeted`: run targeted eval checks.
- `--full`: run targeted checks plus required full `main`/`reference`/`regression` stages (goal mode).

Common usage:

```bash
scripts/pre_submit_gate.sh --plan-only
scripts/pre_submit_gate.sh --focus main:02-delivery-appointments-mapconcurrent
scripts/pre_submit_gate.sh --plan-only --run-broad
scripts/pre_submit_gate.sh --run-broad --base-ref origin/main
scripts/internal_pr_readiness.sh --targeted --focus reference:05-parallel-cpu-review
scripts/internal_pr_readiness.sh --full --base-ref origin/main --auto-continue
```

Add `--auto-continue` only for automation after you have manually verified each stage yourself.

## References

- [Eval Guidance](evals.md)
- [Workflow](workflow.md)
