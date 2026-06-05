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
- Cover every JFokus reference pattern in runtime guidance or eval coverage:
  `findAny`/`findFirst`, match terminal operations, `flatMap`, `Optional::stream`, `joining`, `min`/`max`,
  primitive ranges, `reduce`, primitive `sum`, `parallelStream`, `sorted`, gatherers, `limit`,
  `count`, `distinct`, `toSet`, `toMap`, `groupingBy`, `mapping`, `counting`, `mapMulti`,
  `summing*`/`averaging*`, `summarizing*`, `partitioningBy`, `teeing`, and `takeWhile`/`dropWhile`.
- Keep `findAny()` guidance defensive. It is only right when all matches are equivalent and no
  ordering or priority contract depends on the first match.
- Keep `parallelStream()` guidance defensive. It should require CPU-bound stateless work, enough
  data, no blocking IO, no unsafe shared mutable state, and collector safety.
- The skill should not force streams over clear stateful loops. Stateful sequence output, checked IO,
  prompts, mutation-heavy code, or complex early exits can remain imperative.
- Runtime references must not contain eval answer keys, scenario inventories, hosted run IDs, or
  fixed score claims.

## References

- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
