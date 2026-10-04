Active scenarios are numbered by the order they entered main eval coverage. Numbering gaps are
allowed only when documented here.

Number `05` was demoted to `evals-regression/25-hard-stop-scan-audit` because it requires exact
access to the bundled hard-stop scan header and `rg` command. That makes it useful explicit
workflow-use coverage, but not a fair without-context main benchmark scenario.

Number `06` was demoted to `evals-reference/15-session-roster-indexes` because hosted history showed
the without-context result was already high (`92/100` in release run
`019ea20b-cf1b-73da-955f-d782db861b86`). It remains useful broad Java 17 collector and natural
activation coverage, but it is weak evidence for the evidence-weighted main score.

Number `07` was demoted back to `evals-reference/26-uppercase-side-effect-review` after release
evidence showed useful ordinary lift, but the main suite should stay focused on the strongest
evidence-weighted coverage. Keep the scenario in reference coverage unless future current-suite
evidence shows it meets the 30 pp promotion floor and improves main coverage.

Proof for the PR #94 runtime text (commit `a81acce`) on 2026-10-03. Before this window the Tessl
default solver changed from `deepseek-v4-flash` to `deepseek-v4.1-flash`. Runs
`01a10394-27cb-711f-8632-12d5b0c0b1e9` (`01`, `02`) and `01a103a1-b700-720e-abaa-84f17fbb23c2`
(`03`, `04`): all four scored 100 with context and 100 without, so the main suite shows no lift
under the new solver (1.0x against 2.22x for v1.2.0). The skill text is not the cause; the
baselines rose. Choosing new main scenarios is a maintainer decision.
