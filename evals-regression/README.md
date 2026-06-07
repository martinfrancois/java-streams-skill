# Regression Evals

This directory is for scenarios that are consistently solved by both the with-context and
without-context variants in hosted runs, plus explicit bundled-workflow scenarios that are only fair
as with-context regression checks.

Keep these scenarios out of the main lift score and out of normal reference-candidate runs. Run
them as a final safety check before release, after broad skill changes, or when the changed area is
directly related to one of these scenarios.

Do not move a scenario here just because it currently fails with context. If with-context is below
100%, keep the scenario in its current suite, fix the skill or eval in place, and run that scenario
targeted until it is clean before moving on to broader eval runs.

Most current regression scenarios were moved from `evals-reference/` after hosted run
`019e9f8c-775f-75a8-bcb1-dd6ebe8f43d7`, where each moved scenario scored 100 / 100 both without
context and with context.

The hard-stop scan workflow scenarios also live here. They require exact bundled scan text, so use
their with-context results as workflow regression coverage and do not count their without-context
scores as fair lift evidence.
