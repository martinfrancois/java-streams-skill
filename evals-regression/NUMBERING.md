Regression scenarios keep their original reference numbers when they move from `evals-reference/`.
Numbering gaps are intentional and show coverage that either remains in reference, was removed, or
was never part of the solved-regression bucket.

After hosted run `019e9f8c-775f-75a8-bcb1-dd6ebe8f43d7`, reference numbers `1`, `2`, `4`, `6`,
`7`, `9`, `10`, `11`, `13`, `14`, `17`, `18`, `19`, `20`, and `24` moved here because both
without-context and with-context scored 100 / 100.

Reference numbers `22`, `23`, and `25` also moved here because they are skill-context-dependent
scenarios that require exact skill-provided text or commands. Treat them as with-context regression
checks, not as fair without-context lift evidence, regardless of their without-context score.

Reference number `16` moved here after targeted run `019e9fa8-ccf2-77c7-885f-2cba4939e16f`,
where both without-context and with-context scored 100 / 100.

With-context runs against the PR #94 runtime text (commit `a81acce`) on 2026-10-03, default solver
`deepseek-v4.1-flash`: `04`, `22`, and `25` in `01a1039a-d4e9-76d2-9e7a-56945dfa7352`, the other
sixteen in `01a103a9-22fe-713b-bec2-f1bf09957918`. All nineteen scored 100.

## Rebuild for the deepseek-v4.1-flash solver (2026-10-20)

Local baseline screening, 2026-10-20: each scenario's `task.md` ran through Claude Code with
DeepSeek V4.1 Flash as the solver (`deepseek-flash` on DeepSeek's own API, the model behind the
Tessl default solver `deepseek-v4.1-flash`) and no skill context, then Claude Haiku graded the
written files against the scenario's `criteria.json`. Scores are percentages, mean over the runs
listed. `scripts/local_screen.sh` reproduces it. This is not hosted evidence: no Tessl run IDs
exist for these scenarios yet, and hosted confirmation is the next step (see the November issue
#108).

Moved here with `evidence_type` `solved_regression`:

- `52` to `55`: the former main scenarios `01` to `04` (offer availability, delivery appointments,
  payment screening review, invoice bounds). Hosted runs on 2026-10-03 and the 1.2.2 publish run
  scored each 100 without context and 100 with context. They take new numbers because `01`, `02`,
  and `04` already exist here.
- `05-parallel-cpu-review` and `26-uppercase-side-effect-review` from `evals-reference/`: local
  baseline 100 in both runs, hosted with-context 100 on 2026-10-03.
- `29`, `32`, `33`, `34`, `36`, `39`, `40`, `41`, `46`, `47`: new scenarios drafted from the eval
  issues whose local baseline was 98 to 100 in every run. Their with-context side has no hosted
  evidence yet; run them with context once credits allow and keep them only if they score 100.

## Old regression scenarios rescreened (2026-10-20)

The scenarios that were already here before the rebuild had hosted both-arms evidence from the
old solver only, so they went through the same local baseline screen (two runs each, six for the
two that disagreed). Skill-context-dependent scenarios stay here whatever their baseline, because
their checklists ask for exact skill-provided text.

| Scenario | Runs | Baseline | Placement |
| --- | --- | --- | --- |
| `06`, `10`, `14`, `16`, `17`, `20`, `24` | 2 | 100 | stays |
| `11-null-category-price-index` | 2 | 100 (99 to 100) | stays |
| `07-catalog-feed` | 2 | 99 (98 to 99) | stays |
| `18-priority-findany-review` | 2 | 99 (98 to 99) | stays |
| `19-null-collector-review` | 2 | 98 | stays |
| `22-java8-version-scan` | 2 | 99 | stays, skill-context-dependent |
| `23-collector-order-scan` | 2 | 94 (93 to 94) | stays, skill-context-dependent |
| `25-hard-stop-scan-audit` | 2 | 96 (93 to 98) | stays, skill-context-dependent |
| `09-order-collector-report` | 6 | 98 (96 to 100) | back to reference: flattens the orders twice instead of once in four runs of six |
| `13-training-and-packets` | 6 | 97 (83 to 100) | back to reference: one run of six writes nested loops instead of `flatMap` |

The rule is the one used for the new scenarios: 98 to 100 in every run stays regression, anything
that dips below 98 in a run is lift material and goes to reference.
