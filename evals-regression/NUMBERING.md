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
