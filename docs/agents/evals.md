# Eval Guidance

## Scope

Use this when editing `evals/`, `evals-reference/`, skill evals, benchmark claims, or scoring rules.

## Rules

- Don't cheat. Don't leak the diagnosis or desired fix in eval prompts.
- Keep natural activation prompts neutral. Explicit invocation prompts may name `$java-streams`, but
  should not leak the desired fix beyond invoking the skill.
- The main eval should mirror real failure modes: Java stream code that may materialize
  unnecessarily, count for existence, sort for one extreme, mishandle order, misuse collectors,
  miss primitive streams, or overuse parallel streams.
- Keep a documented mix of invocation styles:
  - Natural activation scenarios don't mention `$java-streams`, "use the skill", or similar
    command-style phrasing.
  - Explicit invocation scenarios may say `Use $java-streams`.
  - Report natural, explicit, main eval combined, and reference/full results separately when hosted
    data is available.
- Include evals where the agent writes new stream code, not only reviews or refactors snippets.
- Review-only or no-op evals must still require a concrete artifact, such as `review.md`.
- Keep broad smoke scenarios and baseline-solved scenarios in `evals-reference/` unless they are
  part of the main eval set.
- Every scenario directory must contain `task.md`, `criteria.json`, and `capability.txt`.
- Every `criteria.json` must classify `metadata.invocation` and `metadata.task_type`.
- Every main eval criterion must classify `category` as `safety`, `stream_quality`, or
  `maintainability`.
- Main eval implementation scenarios need compile/artifact and behavior checks as safety checks, but
  the public benchmark should be weighted toward `stream_quality`.
- For main eval scenarios, use roughly `15` safety points, `80` stream-quality points, and `5`
  maintainability points per 100-point scenario unless a scenario has a documented reason to differ.
- Runtime skill references must not contain eval inventories, expected answers, score rubrics,
  hosted run IDs, or fixed score claims.
- Every Java scenario must state the Java version to assume, such as `Assume Java 17.`.
- If the baseline is too high, first check whether the eval is too generic or too easy before
  changing the skill.
- A 2x raw score ratio is useful only when earned by honest, realistic eval design. Don't suppress
  legitimate coverage just to improve lift.
- Track raw score, percentage-point lift, raw score ratio, missed-point reduction, and the
  `stream_quality` subtotal when updating benchmark claims.
- Use Sonnet 4.6 for this repository's main eval runs:

  ```bash
  tessl eval run --agent claude:claude-sonnet-4-6 --variant without-context --variant with-context .
  ```

## Checks

Run the shared validation commands in [Workflow](workflow.md). When editing eval criteria, also run
the criteria JSON check listed there.

## References

- [Workflow](workflow.md)
- [Skill Behavior](skill-behavior.md)
