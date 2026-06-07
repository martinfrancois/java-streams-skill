Active scenarios are numbered by the order they entered main eval coverage. Numbering gaps are
allowed only when documented here.

Number `05` was demoted to `evals-reference/25-hard-stop-scan-audit` because it requires exact
access to the bundled hard-stop scan header and `rg` command. That makes it useful explicit
workflow-use coverage, but not a fair without-context main benchmark scenario.
