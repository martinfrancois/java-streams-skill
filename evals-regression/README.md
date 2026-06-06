# Regression Evals

This directory is for scenarios that are consistently solved by both the with-context and
without-context variants in hosted runs.

Keep these scenarios out of the main lift score and out of normal reference-candidate runs. Run
them as a final safety check before release, after broad skill changes, or when the changed area is
directly related to one of these scenarios.

Do not move a scenario here just because it currently fails with context. If with-context is below
100%, keep the scenario in its current suite, fix the skill or eval in place, and run that scenario
targeted until it is clean before moving on to broader eval runs.
