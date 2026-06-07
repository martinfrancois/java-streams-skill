Reference scenarios are intentionally numbered by coverage area, not by public benchmark priority.
They cover stream patterns from the JFokus source that are useful regression coverage but should not
automatically drive main eval lift claims.

Number `12` was removed from reference coverage after the remote blocking-call review was represented
by the active main eval set. Do not include deleted or promoted reference numbers in reference
aggregation.

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
