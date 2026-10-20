Reference scenarios are intentionally numbered by coverage area, not by public benchmark priority.
They cover stream patterns from the JFokus source that are useful regression coverage but should not
automatically drive main eval lift claims.

Number `12` was removed from reference coverage after the remote blocking-call review was represented
by the active main eval set. Do not include deleted or promoted reference numbers in reference
aggregation.

Number `15` contains the session roster indexes scenario demoted from active main eval number `06`.
Hosted release run `019ea20b-cf1b-73da-955f-d782db861b86` scored it `92/100` without context and
`100/100` with context, so it remains ordinary reference lift evidence but should not drive the
evidence-weighted main score unless future hosted history shows a stronger delta.

Number `26` contains the uppercase side-effect review scenario that was promoted to main eval
number `07`, then demoted back to reference after release evidence showed useful ordinary lift but
weaker main-suite priority than the stronger evidence-weighted coverage. It remains useful natural
review coverage for external stream mutation, lambda purity, and careful `parallelStream()`
performance advice. Keep it here unless future current-suite evidence shows it meets the 30 pp
promotion floor and improves main coverage.

Number `27` covers high-volume uppercase implementation from
<https://github.com/martinfrancois/java-streams-skill/issues/4>. Targeted Sonnet 4.6 run
`019ea26a-754b-718f-ac66-cd111d4b1e79` scored it `99/100` without context and `100/100` with
context. Keep it in `evals-reference/` unless future hosted history shows it should move to main or
regression.

Number `28` covers implementation readability for stream chains that need non-trivial mapping logic:
the stream should use short glue lambdas or method references while extracted helpers own
multi-step derivation. Keep it in `evals-reference/` until targeted hosted evidence shows whether it
belongs in main or regression.

Number `25` contains the explicit hard-stop scan workflow audit that was demoted from the main eval
set and later moved to `evals-regression/`. It requires exact skill-provided text, so report it as
with-context regression coverage rather than as main or reference Java stream reasoning lift.

After hosted run `019e9f8c-775f-75a8-bcb1-dd6ebe8f43d7`, reference numbers `1`, `2`, `4`, `6`,
`7`, `9`, `10`, `11`, `13`, `14`, `17`, `18`, `19`, `20`, and `24` moved to
`evals-regression/` because both with-context and without-context scored 100 / 100. Keep those
numbers out of reference aggregation unless a future hosted run shows they are no longer solved by
both variants.

After the same review pass, reference numbers `22`, `23`, and `25` also moved to
`evals-regression/`. They are skill-context-dependent scenarios that require exact skill-provided
text or commands, so they are useful with-context regression checks but should not be counted as
fair without-context reference lift evidence, regardless of their without-context score.

After targeted run `019e9fa8-ccf2-77c7-885f-2cba4939e16f`, reference number `16` moved to
`evals-regression/` because both with-context and without-context scored 100 / 100.

When hosted history shows both with-context and without-context are consistently 100%, move the
scenario to `evals-regression/` instead of keeping it in normal reference-candidate runs.

With-context run against the PR #94 runtime text (commit `a81acce`) on 2026-10-03, default solver
`deepseek-v4.1-flash`: all six reference scenarios scored 100 in
`01a103b0-1209-7449-b98b-7c573a67ece7`. No baseline was run this time to save credits.

## Rebuild for the deepseek-v4.1-flash solver (2026-10-20)

Local baseline screening, 2026-10-20: each scenario's `task.md` ran through Claude Code with
DeepSeek V4.1 Flash as the solver (`deepseek-flash` on DeepSeek's own API, the model behind the
Tessl default solver `deepseek-v4.1-flash`) and no skill context, then Claude Haiku graded the
written files against the scenario's `criteria.json`. Scores are percentages, mean over the runs
listed. `scripts/local_screen.sh` reproduces it. This is not hosted evidence: no Tessl run IDs
exist for these scenarios yet, and hosted confirmation is the next step (see the November issue
#108).

Numbers `29` to `51` were drafted from the open eval issues (one scenario per issue; the issue
link is in each `criteria-meta.json`). Every draft entered here first and was then placed by its
local baseline:

| Scenario | Issue | Runs | Without skill | Placement |
| --- | --- | --- | --- | --- |
| `29-foreach-smell-cleanup` | #5 | 2 | 100 | regression |
| `30-eager-work-before-allmatch` | #39 | 6 | 75 (73 to 75) | reference: keeps a hand-written loop instead of the lazy stream check, stable 25-point delta, under the 30-point floor |
| `31-line-to-record-extraction` | #40 | 6 | 30 (20 to 35) | main |
| `32-hidden-lookup-before-writes` | #41 | 2 | 100 | regression |
| `33-foreach-into-outer-map` | #42 | 2 | 100 | regression |
| `34-identity-mapper-in-tomap` | #44 | 2 | 99 | regression |
| `35-one-line-stream-chains` | #45 | 6 | 84 (82 to 85) | reference: wraps chains but splits the single `anyMatch` chain every time |
| `36-unexplained-tocollection` | #46 | 2 | 100 | regression |
| `37-line-splitting-contract` | #47 | 2 | 94 (87 to 100) | reference |
| `38-temporary-list-then-addall` | #48 | 6 | 87 (80 to 100) | reference |
| `39-predicate-loop-audit` | #49 | 2 | 100 | regression |
| `40-append-then-freeze` | #50 | 2 | 100 | regression |
| `41-equivalent-match-lookup` | #51 | 2 | 100 | regression |
| `42-zero-one-or-ambiguous-lookup` | #53 | 6 | 91 (84 to 100) | reference |
| `43-reject-if-any-validator` | #55 | 6 | 69 (48 to 100) | main, made explicit |
| `44-single-dedup-boundary` | #56 | 6 | 73 (20 to 100) | reference: bimodal, one run in three writes a loop instead of a pipeline |
| `45-nested-streams-in-optional-chain` | #57 | 6 | 83 (62 to 92) | reference: generic helper names and `findAny` to `findFirst` drift |
| `46-constructor-owned-snapshot` | #58 | 2 | 100 | regression |
| `47-direct-immutable-array-mapping` | #59 | 2 | 99 | regression |
| `48-conditional-delimiter-reduction` | #60 | 2 | 97 | reference |
| `49-char-predicate-contracts` | #61 | 2 | 96 (92 to 100) | reference |
| `50-identity-string-reduction` | #62 | 2 | 95 | reference |
| `51-sort-after-collect` | #72 | 2 | 97 | reference |

The existing reference scenarios were screened the same way: `05` 100 and `26` 100 (both moved to
`evals-regression/`, keeping their numbers), `08` 94, `15` 90, `27` 76 (six runs, 65 to 100: a
`for` loop into a pre-sized `ArrayList` in five of six), `28` 39 (two runs, 30 and 47). `28` stays
focused reference coverage despite its delta because its domain overlaps the runtime example in
`stream-examples.md`; `31` is the de-domained main-suite version of the same failure.

Scenarios at 95 to 97 (`48`, `50`, `51`, `37`, `49`) stay here as weak lift rather than moving to
regression, because the regression rule needs both variants at 100 and the baseline is not there.
They are the first candidates to retire if the reference suite needs trimming.
