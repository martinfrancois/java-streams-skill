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
evidence showed it still had useful ordinary lift, but was the weakest active main scenario for the
registry's unweighted public uplift calculation. Keep the scenario in reference coverage unless
future evidence shows it should return to main.
