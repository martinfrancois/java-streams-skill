---
name: java-streams
license: MIT
description: Write, review, and refactor Java Stream and Collector code using best practices, improving readability and performance while avoiding common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, and careless findFirst/findAny or parallelStream changes. Use whenever writing, reviewing, or refactoring Java code that uses streams, collectors, primitive streams, Optional-producing stream terminals, map/flatMap/mapMulti, grouping, joining, distinct, sorted, limit, takeWhile/dropWhile, teeing, partitioningBy, summarizing, or parallel stream behavior.
---

# Java Streams Skill

Use this skill before writing, reviewing, or refactoring Java stream and collector code. Preserve
behavior, encounter order, exceptions, null handling, side effects, mutability, and Java-version
compatibility.

## Reference Bundle

| File | Purpose |
|---|---|
| [hard-stops.md](references/hard-stops.md) | Replacement antipatterns and the marker scan to run |
| [stream-examples.md](references/stream-examples.md) | Worked before/after examples from the reference set |
| [java-stream-api.md](references/java-stream-api.md) | Java-version compatibility for stream and collector APIs |

## Hard Stops

Before finalizing touched stream flow, run the scan in [hard-stops.md](references/hard-stops.md).
Keep these rules in view:

- Preserve behavior contracts: encounter order, first-match semantics, null handling, duplicate-key
  handling, mutability expectations, and Java-version compatibility.
- Use terminals and collectors that encode the requested result directly instead of collecting,
  sorting, or counting just to inspect one fact.
- Treat `parallelStream()`, `findAny()`, `Stream.toList()`, `groupingBy`, and `toMap` as semantic
  choices; only use them when their ordering, mutability, null handling, merge, and thread-safety
  contracts match the existing code.
- Keep loops where they express complex state, checked IO, prompting, mutation-heavy code, or early
  exits more clearly than a stream pipeline.

## Core Workflow

0. Check the Java baseline before choosing APIs. Read build/toolchain docs; if unclear, use Java
   8-compatible code or state the assumption. Use [java-stream-api.md](references/java-stream-api.md)
   for minimum Java versions.
1. Identify the result shape:
   - one arbitrary match: `filter(...).findAny()`;
   - first encounter-order match: `filter(...).findFirst()`;
   - existence: `anyMatch`, `noneMatch`, or `allMatch`;
   - transformed list/set: `map`/`filter` then collect;
   - concatenated text: `Collectors.joining`;
   - numeric primitive result: `mapToInt`/`mapToLong`/`mapToDouble` plus primitive terminals;
   - grouping/indexing: `groupingBy`, downstream collectors, `partitioningBy`, or `toMap` with
     explicit merge/null handling.
2. Prefer terminals that encode intent directly: `anyMatch` for existence, `count` for counts,
   `joining` for text, `min`/`max` for extremes, and primitive terminals for primitive totals.
3. Flatten nested sources deliberately. Use `flatMap` for nested collections and
   `flatMap(Optional::stream)` on Java 9+ for `Stream<Optional<T>>`. On Java 16+, consider
   `mapMulti` only when it makes a small zero-or-one/one-to-few transformation clearer or avoids
   many tiny stream allocations.
4. Use primitive streams for primitive aggregation. Keep `reduce(identity, op)` for immutable
   non-primitive accumulation such as `BigDecimal`.
5. Choose collectors by result semantics: `toMap` for one value per key, `groupingBy` for many
   values per key, downstream collectors for projections/aggregates, and `partitioningBy` for a
   complete boolean split. Preserve duplicate-key and null-handling contracts explicitly.
6. Preserve ordering, mutability, and short-circuit behavior. `sorted`, `distinct`, `limit`,
   `takeWhile`, and `dropWhile` are order-sensitive. For top-N pipelines, sort before `limit`; for
   nullable sort keys, filter or use `Comparator.nullsFirst/nullsLast`; for mutable results, keep
   `Collectors.toCollection(ArrayList::new)` or `Collectors.toList()`.
7. Keep imperative code when it is the clearer boundary. Stateful sequence output, checked IO,
   prompts, mutation-heavy code, or complex early exits may be better as a loop. If a loop remains,
   still use small stream helpers for real lookups or aggregates when that improves clarity.
8. Verify each changed branch. Check empty inputs, one element, duplicates, nulls, ordering,
   parallel-safety, and Java-baseline compatibility. Run the marker scan from
   [hard-stops.md](references/hard-stops.md); include its header when documenting a scan. Fix
   relevant hits and re-scan.
