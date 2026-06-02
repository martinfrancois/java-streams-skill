# Eval Guidance

## Scope

Use this when editing `evals/`, `evals-reference/`, skill evals, benchmark claims, or scoring rules.

## Rules

- Don't cheat. Don't leak the diagnosis or desired fix in eval prompts.
- Keep natural activation prompts neutral. Avoid clue words that tell the model the exact failure,
  such as "order-independent" or "preserving laziness", unless those words are truly part of the
  user task. Explicit invocation prompts may name `$java-optionals`, but they should not leak the
  diagnosis or desired fix beyond invoking the skill.
- The headline eval should mirror the real failure mode: tasks where an agent writes or changes Java
  Optional code and may introduce Optional antipatterns.
- Keep a documented mix of invocation styles:
  - Natural activation scenarios don't mention `$java-optionals`, "use the skill", or similar
    command-style phrasing.
  - Explicit invocation scenarios may say `Use $java-optionals`.
  - Report natural, explicit, headline-combined, and reference/full results separately when hosted
    data is available.
- Include evals where the agent writes new Optional code, not only reviews or refactors snippets.
- Review-only or no-op evals must still require a concrete artifact, such as `review.md`, so empty
  answers can't pass by accident.
- Keep broad review or smoke scenarios in `evals-reference/` unless they're part of the headline
  benchmark.
- Every scenario directory must contain `task.md`, `criteria.json`, and `capability.txt`.
- Every `criteria.json` must classify `metadata.invocation` and `metadata.task_type`.
- Every headline criterion must classify `category` as `safety`, `optional_quality`, or
  `maintainability`.
- Headline implementation scenarios need compile/artifact checks and behavior checks as safety
  checks, but the headline score should mainly measure Optional-specific quality.
- Treat compile and behavior checks as safety-category checks. They make broken answers visible in
  the score, but this skill's public benchmark should be weighted toward the `optional_quality`
  subtotal because the skill is not primarily trying to improve compilation.
- For headline scenarios, use roughly `15` safety points, `80` Optional-quality points, and `5`
  maintainability points per 100-point scenario unless a scenario has a documented reason to differ.
- `evals/11-checked-boundary-selection-cleanup` is intentionally weighted as a 60-point headline
  case because checked-boundary scoring is noisier and should not dominate the combined headline
  score. Its category ratio still follows the headline policy: roughly 15% safety, 80%
  Optional-quality, and 5% maintainability.
- `evals-reference/45-workflow-validation-cleanup` remains reference/regression coverage. It is
  intentionally not part of the focused headline suite because the active headline set should stay
  concentrated on the clearest Optional-quality signal.
- Runtime skill references must not contain eval inventories, expected answers, score rubrics,
  hosted run IDs, or fixed score claims.
- Every Java scenario, including temporary candidate scenarios, must state the Java version to
  assume, such as `Assume Java 17.`. Criteria should catch accidental use of APIs newer than that
  baseline.
- If the baseline is too high, first check whether the eval is too generic or too easy before
  changing the skill. The baseline should reveal the real failures from the issue.
- Be careful when tightening prompts or scoring. If a change mainly increases empty-output noise or
  brittle failures instead of measuring the Optional behavior better, revert or redesign it.
- A 2x raw score ratio is useful only when earned by honest, realistic eval design. Don't suppress
  legitimate coverage just to improve lift.
- Track raw score, percentage-point lift, raw score ratio, missed-point reduction, and the
  `optional_quality` subtotal when updating benchmark claims.
- Don't hide scenarios merely because the baseline solves them. Move them to `evals-reference/`
  only when they're better as broader regression coverage than headline evidence, and document why.
- For transcript-derived cases, compare the reduced scenario against available replay evidence, PR
  notes, or git history before adding headline evals. The reduced eval should reproduce the same
  without-skill vs with-skill difference seen in the full repository. If the with-skill replay still
  fails, record it as a regression target instead of promoting it as a passing eval.
- Historical eval inventories, replay plans, hosted-run notes, and legacy eval formats are not kept
  as active documentation. Keep current policy in these docs and use git history for old answer
  keys, replay logs, and one-off run details.

## Checks

Run the shared validation commands in [Workflow](workflow.md). When editing eval criteria, also run
the criteria JSON check listed there.

## References

- [Workflow](workflow.md)
- [Skill Behavior](skill-behavior.md)
