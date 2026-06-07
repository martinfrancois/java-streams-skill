Reference scenarios are intentionally numbered by coverage area, not by public benchmark priority.
They cover stream patterns from the JFokus source that are useful regression coverage but should not
automatically drive main eval lift claims.

Number `12` was removed from reference coverage after the remote blocking-call review was represented
by the active main eval set. Do not include deleted or promoted reference numbers in reference
aggregation.

Number `25` contains the explicit hard-stop scan workflow audit that was demoted from the main eval
set. It requires access to the bundled scan header and `rg` command, so report it as reference
workflow evidence rather than as main Java stream reasoning lift.

When hosted history shows both with-context and without-context are consistently 100%, move the
scenario to `evals-regression/` instead of keeping it in normal reference-candidate runs.
