# Eval Guidance

## Scope

Use this when editing `evals/`, `evals-reference/`, skill evals, benchmark claims, or scoring rules.

## Rules

- Don't cheat. Don't leak the diagnosis or desired fix in eval prompts.
- Keep natural activation prompts neutral. Explicit invocation prompts may name `$java-streams`, but
  should not leak the desired fix beyond invoking the skill.
- The Java streams skill is broadly about stream and collector correctness, maintainability,
  laziness, ordering, reduction, collection, flattening, and concurrency choices.
- The main eval set is evidence-weighted: it should cover core skill capabilities and give more
  weight to scenario families where hosted runs show the largest improvement with the skill versus
  without it. Read the main score as "where this skill measurably helps most," not as an evenly
  sampled survey of every Java Streams API.
- The main eval should focus on realistic failure modes where this skill should change the answer:
  Java stream code that may materialize unnecessarily, count for existence, sort for one extreme,
  mishandle order, misuse collectors, miss primitive streams, or overuse parallel streams.
- The main suite should include at least one scenario for each core capability area that the skill
  claims to improve when a useful with-vs-without delta exists, higher weights for scenario families
  with the largest missed-point reduction, natural and explicit invocation scenarios reported
  separately, and reference scenarios kept separate unless promoted and normalized.
- When choosing or weighting main scenarios, prefer hosted eval evidence: baseline score,
  with-context score, raw score lift, missed-point reduction, and whether failures match real
  observed stream or collector mistakes.
- Do not promote a reference scenario into main only for topical balance if the baseline already
  solves it and the skill adds little measurable value. Keep such cases in `evals-reference/`.
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

## Capability Review Checklist

Use this as a review checklist when deciding whether the main suite is becoming too narrow. These
areas are not individually mandatory if hosted evidence shows little skill delta:

- remote/blocking stream operations and bounded concurrency;
- `Gatherers.mapConcurrent` and Java 24+ stream APIs;
- avoiding unsafe `parallelStream()`;
- preserving encounter order where it matters;
- using `findFirst()` vs `findAny()` correctly;
- avoiding collect-then-inspect when a terminal operation is better;
- reductions, min/max, sorting, and extremes;
- collectors: `groupingBy`, `partitioningBy`, `toMap`, duplicate keys, downstream collectors;
- flattening, `flatMap`, and Optional-producing stream chains;
- avoiding accidental materialization;
- `Stream.toList()` mutability and Java-version pitfalls;
- null-sensitive sorting and comparator behavior;
- primitive streams and boxing/unboxing pitfalls;
- hard-stop scan and review scenarios.

If most current main weight is in one family, such as Java 24 remote checks, that can be acceptable
only when hosted evidence shows the strongest missed-point reduction there, docs call the suite
evidence-weighted rather than topic-specific, non-concurrency stream and collector capabilities are
represented when they also show meaningful delta, and broader coverage remains in
`evals-reference/`.

## Checks

Run the shared validation commands in [Workflow](workflow.md). When editing eval criteria, also run
the criteria JSON check listed there.

## References

- [Workflow](workflow.md)
- [Skill Behavior](skill-behavior.md)
