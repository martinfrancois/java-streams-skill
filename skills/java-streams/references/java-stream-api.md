# Java Stream And Collector API Compatibility

Always infer the project Java baseline before choosing APIs. Check `pom.xml`, Maven compiler
settings, Gradle toolchains, `sourceCompatibility`, `targetCompatibility`, `.github/workflows/*`,
`Dockerfile`, `.sdkmanrc`, `.java-version`, and project docs.

If the baseline is unclear, prefer Java 8-compatible stream code or state the assumption explicitly.

## Stream APIs

| API or feature | Minimum Java | Notes |
| --- | ---: | --- |
| `Collection.stream()` / `Stream` | 8 | Sequential stream pipeline. |
| `parallelStream()` / `.parallel()` | 8 | Uses common fork-join pool; not async and not a default optimization. |
| `filter`, `map`, `flatMap`, `peek` | 8 | `peek` is for diagnostics; do not rely on it for required side effects. |
| `findFirst`, `findAny` | 8 | `findFirst` preserves encounter-order semantics; `findAny` is for equivalent matches. |
| `anyMatch`, `noneMatch`, `allMatch` | 8 | Short-circuit existence/universal checks. |
| `min`, `max` | 8 | Prefer over sorting the whole stream for one extreme. |
| `reduce` | 8 | Good for immutable non-primitive accumulation; use primitive terminals for primitive totals. |
| `sorted`, `distinct`, `limit`, `skip`, `count` | 8 | Respect ordering and null behavior. |
| `IntStream`, `LongStream`, `DoubleStream` | 8 | Use primitive terminals such as `sum`, `average`, `min`, `max`, `summaryStatistics`. |
| `IntStream.range`, `rangeClosed`, `mapToObj` | 8 | Good for index/range object creation. |
| `Stream.ofNullable` | 9 | Nullable-to-stream bridge. |
| `takeWhile`, `dropWhile` | 9 | Prefix operations on ordered streams; not general filters. |
| `Optional.stream` | 9 | Flatten `Stream<Optional<T>>` with `flatMap(Optional::stream)`. |
| `Stream.toList()` | 16 | Returns an unmodifiable list; not equivalent to mutable `Collectors.toList()`. Do not use when callers or later code mutate the list. |
| `mapMulti` and primitive `mapMulti` variants | 16 | Efficient one-to-few mapping when clearer than `flatMap`. |
| `Stream.gather(Gatherer)` / built-in gatherers | 24 | Advanced extension point; `Gatherers.mapConcurrent` can help blocking per-element work. |

## Collectors

| API or feature | Minimum Java | Notes |
| --- | ---: | --- |
| `Collectors.toList`, `toSet` | 8 | `toList` mutability is unspecified; use explicit collection if required. |
| `Collectors.joining` | 8 | Join mapped text in one terminal. |
| `Collectors.toMap` | 8 | Provide a merge function when duplicate keys are possible. Default map results may preserve a null key, but null values are rejected; preserve the existing null contract explicitly. |
| `Collectors.groupingBy` | 8 | Key maps to a list or downstream aggregate. Null classifier keys are not accepted. |
| `Collectors.mapping` | 8 | Project values inside downstream collectors. |
| `Collectors.counting` | 8 | Count elements, often downstream of `groupingBy`. |
| `Collectors.summingInt`, `summingLong`, `summingDouble` | 8 | Primitive totals, often downstream. |
| `Collectors.averagingInt`, `averagingLong`, `averagingDouble` | 8 | Primitive averages. |
| `Collectors.summarizingInt`, `summarizingLong`, `summarizingDouble` | 8 | Count, sum, min, max, and average together. |
| `Collectors.partitioningBy` | 8 | Boolean split with both keys present. |
| `Collectors.minBy`, `maxBy`, `reducing` | 8 | Optional-producing reductions. |
| `Collectors.flatMapping` | 9 | Downstream flattening. |
| `Collectors.filtering` | 9 | Downstream filtering. |
| `Collectors.teeing` | 12 | Combine two independent collectors over the same input. |

## Adjacent Java Features

| API or feature | Minimum Java | Notes |
| --- | ---: | --- |
| `List.of`, `Set.of`, `Map.of` | 9 | Adjacent examples only. |
| `var` local variables | 10 | Avoid in examples when Java 8 compatibility is needed. |
| records | 16 | Adjacent examples only. |
| pattern matching for `instanceof` | 16 | Useful with `mapMulti`; requires Java 16+. |
| `List.getFirst()` / sequenced collections | 21 | Do not use below Java 21. |
| virtual threads | 21 | Relevant to gatherer concurrency discussions, not ordinary streams. |

Natural sorting and collectors are null-sensitive. If a stream may contain null elements, null
values, or null grouping keys, filter them out or use explicit null handling before sorting or
collecting. For `toMap`, preserve existing null-key behavior deliberately instead of filtering or
retaining null keys by accident.
