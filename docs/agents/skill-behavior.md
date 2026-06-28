# Skill Behavior

## Scope

Use this when editing `skills/java-streams/SKILL.md`, runtime references, skill metadata, install
guidance, or auto-selection wording.

## Rules

- The skill should not require users to explicitly type `$java-streams` every time.
- Metadata should let agents auto-select it for Java tasks involving streams, collectors, primitive
  streams, stream terminal operations, `findFirst`, `findAny`, `anyMatch`, `noneMatch`, `allMatch`,
  `flatMap`,
  `mapMulti`, `joining`, `min`, `max`, `sum`, `groupingBy`, `toMap`, `partitioningBy`, `teeing`,
  `takeWhile`, `dropWhile`, `parallelStream`, and stream Java-version compatibility.
- Skill guidance must start by detecting the project Java baseline before selecting stream,
  collector, record, pattern matching, or gatherer APIs.
- Runtime Java API tables should state the minimum Java version and practical usage note. Do not add
  JEP numbers, preview/finalization history, or other release trivia unless it directly changes what
  code the agent should write.
- Cover every JFokus reference pattern in runtime guidance or eval coverage:
  `findAny`/`findFirst`, match terminal operations, `flatMap`, `Optional::stream`, `joining`, `min`/`max`,
  primitive ranges, `reduce`, primitive `sum`, `parallelStream`, `sorted`, gatherers, `limit`,
  `count`, `distinct`, `toSet`, `toMap`, `groupingBy`, `mapping`, `counting`, `mapMulti`,
  `summing*`/`averaging*`, `summarizing*`, `partitioningBy`, `teeing`, and `takeWhile`/`dropWhile`.
- Keep `findAny()` guidance defensive. It is only right when all matches are equivalent and no
  ordering or priority contract depends on the first match.
- Keep `parallelStream()` guidance defensive. It should require CPU-bound stateless work, enough
  data, no blocking IO, no unsafe shared mutable state, and collector safety.
- For external stream mutation such as `stream().map(...).forEach(result::add)`, document direct
  collection as the correctness/readability baseline, not as a guaranteed throughput win. A pure
  ordered `parallelStream().map(...).toList()` is the benchmark candidate for large CPU-bound
  transformations; recommend benchmarking it prominently after the safe baseline, and never allow
  parallel shared mutable accumulation.
- Avoid `pipeline` for Java stream behavior; use `stream chain`, `stream operation`, or more specific
  wording. Reserve `pipeline` for CI/release contexts.
- Avoid `shape` for Java stream behavior; use `stream chain`, `collector approach`, `result`, or
  more specific wording. Reserve `Shape` only for Java types or domain examples that actually use
  that name.
- The skill should not force streams over clear stateful loops. Stateful sequence output, checked IO,
  prompts, mutation-heavy code, or complex early exits can remain imperative.
- Generic lambda, method-reference, identity-function, no-op functional stage, supplier-laziness,
  and callback readability guidance belongs to `java-functional-style`. Keep only stream and
  collector semantics canonical here.
- Runtime guidance should keep internal workflow language out of ordinary user-facing reviews. Avoid
  terms such as "hard stop", "marker", "scan", "checklist", and skill names unless the user asked
  for an explicit skill workflow, audit, or scan command.
- Runtime references must not contain eval answer keys, scenario inventories, hosted run IDs, or
  fixed score claims.

## References

- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
- [Ownership Boundaries](ownership-boundaries.md)
