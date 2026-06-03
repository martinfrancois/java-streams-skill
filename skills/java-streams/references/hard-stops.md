# Java Stream Hard Stops

Use this reference before finalizing Java stream cleanup or first-pass implementation when the code
touches stream terminals, collectors, ordering, primitive aggregation, null sorting, or parallelism.

## Replacement Antipatterns

Fix these before finalizing:

- `filter(...).collect(...).isEmpty()`, `filter(...).collect(...).size()`, or a temporary list just
  to decide existence. Use `anyMatch`, `noneMatch`, `allMatch`, `findAny`, or `findFirst`.
- `filter(...).count() > 0` for existence. Use `anyMatch`.
- `sorted(...).findFirst()` or sorted-then-sublist just to get one extreme. Use `min`/`max`; keep
  sorting only when the ordered list itself is required.
- `map(...).collect(toList())` followed immediately by `String.join`. Use `Collectors.joining`.
- Boxed numeric `reduce` for primitive totals/statistics. Use primitive streams or summarizing
  collectors unless the type is genuinely non-primitive, such as `BigDecimal`.
- Nested `map(... stream ... collect(...)).flatMap(...)` where a direct `flatMap` pipeline is
  clearer.
- `filter(Optional::isPresent).map(Optional::get)` on Java 9+. Use `flatMap(Optional::stream)`.
- `toMap` without a merge function when duplicate keys are possible.
- `groupingBy` where null classifier keys can reach the collector, or `toMap` where null keys or
  values would change the existing null-handling contract. Default `toMap` can preserve one null
  key in a `HashMap` result, but it rejects null values.
- `sorted()` or `Comparator.naturalOrder()` where null elements or keys can reach the comparator.
- `Stream.toList()` where a mutable result is required or later code mutates the list.
- `parallelStream()` or `.parallel()` added without checking CPU-bound work, data size, ordering,
  shared state, blocking calls, and collector safety.
- Java-version drift: `toList`, `mapMulti`, `teeing`, `takeWhile`, `dropWhile`, `Optional.stream`,
  `Collectors.flatMapping`, `Stream.ofNullable`, or gatherers used below their minimum Java version.

## Ordering Rules

- Keep `findFirst()` when list order, configuration priority, chronological order, first fallback,
  or user-visible order matters.
- Use `findAny()` only when all matches are equivalent. It is often fine after filtering a set of
  equivalent flags, IDs, or permissions.
- `distinct().sorted()` is usually better than `sorted().distinct()` when duplicates can be removed
  before sorting.
- `limit(n)` must come after sorting when computing top-N by an ordering. It may come before an
  expensive map/filter only when that preserves semantics.
- `takeWhile` and `dropWhile` are prefix operations. They are not replacements for `filter`.

## Parallelism Rules

Use parallel streams only after checking:

1. Work per element is CPU-heavy enough to amortize split/merge overhead.
2. Operations are stateless and non-interfering.
3. Encounter order is not required, or the ordered terminal is still worth the cost.
4. The pipeline does not perform blocking IO or remote calls. For Java 24+ blocking per-element
   calls, consider `Gatherers.mapConcurrent` only when the baseline supports it and virtual-thread
   concurrency is the intended design.
5. The terminal/collector is safe under parallel execution.

## Scan Command

When documenting a scan, start with this header so later reviews can tell which workflow was used:

```text
java-streams hard-stop scan v1
```

Run a hard-stop scan over touched Java files before finalizing. The command uses PCRE2 and
multiline mode so it catches normally formatted fluent chains. Some markers are intentionally broad;
classify legitimate uses instead of deleting them mechanically.

```bash
rg -nUP "count\\(\\)\\s*>\\s*0|collect\\([^;]+\\)\\s*\\.\\s*(?:isEmpty|size)\\(|sorted\\([^;]*\\)\\s*\\.\\s*findFirst\\(|sorted\\(\\)\\s*\\.\\s*findFirst\\(|limit\\([^;]+\\)\\s*\\.\\s*sorted\\(|String\\.join\\(|filter\\(Optional::isPresent\\)\\s*\\.\\s*map\\(Optional::get\\)|parallelStream\\(|\\.parallel\\(\\)|Collectors\\.toMap\\(|Collectors\\.groupingBy\\(|Comparator\\.naturalOrder\\(\\)|(?<!Collectors)\\.toList\\(|mapMulti\\(|takeWhile\\(|dropWhile\\(|Collectors\\.teeing\\(|Optional::stream|Collectors\\.flatMapping|Stream\\.ofNullable|\\.gather\\(" <touched Java files>
```

For each hit, decide whether it is legitimate for the project Java baseline and behavior. Fix
stream-quality issues. If a marker remains because it is legitimate, state why.
