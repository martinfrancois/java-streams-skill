Regression scenarios keep their original reference numbers when they move from `evals-reference/`.
Numbering gaps are intentional and show coverage that either remains in reference, was removed, or
was never part of the solved-regression bucket.

After hosted run `019e9f8c-775f-75a8-bcb1-dd6ebe8f43d7`, reference numbers `1`, `2`, `4`, `6`,
`7`, `9`, `10`, `11`, `13`, `14`, `17`, `18`, `19`, `20`, and `24` moved here because both
without-context and with-context scored 100 / 100.

Reference numbers `22`, `23`, and `25` also moved here because they are context-dependent workflow
scenarios that require exact skill-provided scan text. Treat them as with-context workflow
regression checks, not as fair without-context lift evidence.

Reference number `16` moved here after targeted run `019e9fa8-ccf2-77c7-885f-2cba4939e16f`,
where both without-context and with-context scored 100 / 100.
