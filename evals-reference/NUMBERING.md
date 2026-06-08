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
