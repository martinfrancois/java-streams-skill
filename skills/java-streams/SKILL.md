---
name: java-streams
license: MIT
description: Write, review, and refactor Java Stream and Collector code using best practices, improving readability and performance while avoiding common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, and careless findFirst/findAny or parallelStream changes. Use whenever writing, reviewing, or refactoring Java code that uses streams, collectors, primitive streams, Optional-producing stream terminals, map/flatMap/mapMulti, grouping, joining, distinct, sorted, limit, takeWhile/dropWhile, teeing, partitioningBy, summarizing, or parallel stream behavior.
---

# Java Streams Skill

Use this skill before writing Java stream code, and when reviewing or refactoring existing stream or
collector code. Preserve behavior, encounter-order contracts, exception behavior, null handling,
side effects, mutability expectations, and Java-version compatibility.

## Reference Bundle

| File | Purpose |
|---|---|
| [hard-stops.md](references/hard-stops.md) | Replacement antipatterns and the marker scan to run |
| [stream-examples.md](references/stream-examples.md) | Worked before/after examples from the reference set |
| [java-stream-api.md](references/java-stream-api.md) | Java-version compatibility for stream and collector APIs |

## Hard Stops

Before finalizing touched stream flow, check these rules (see
[hard-stops.md](references/hard-stops.md) for the full antipattern list and marker scan):

- Do not collect just to inspect one fact. Use `findAny`/`findFirst`, `anyMatch`/`noneMatch`/
  `allMatch`, `count`, `min`, `max`, `sum`, `joining`, or a collector that computes the result.
- Do not change `findFirst()` to `findAny()` unless every matching element is equivalent and no
  priority, display order, first configured value, or short-circuit order is part of the contract.
- Do not sort a whole stream just to get one extreme; use `min` or `max`.
- Do not use `count() > 0` or `collect(...).isEmpty()` for existence; use match/find terminals.
- Do not use `parallelStream()` as a default optimization. Confirm large enough data, stateless
  CPU-bound work, no ordering reliance, no shared mutable state, and no blocking IO.
- Do not call `sorted()` on possibly-null elements or keys without handling nulls.
- Do not use Java 9+ or Java 16+ stream APIs unless the project baseline supports them.

## Core Workflow

0. Check the Java baseline before choosing APIs. Read build/toolchain docs; if unclear, use Java
   8-compatible code or state the assumption. Do not use `Stream.toList()` or `mapMulti` before
   Java 16, `takeWhile`/`dropWhile`, `Optional.stream`, `Collectors.flatMapping`, or
   `Stream.ofNullable` before Java 9, `teeing` before Java 12, or gatherers before Java 24.
1. Identify the result shape first:
   - one arbitrary match: `filter(...).findAny()`;
   - first encounter-order match: `filter(...).findFirst()`;
   - existence: `anyMatch`, `noneMatch`, or `allMatch`;
   - transformed list/set: `map`/`filter` then collect;
   - concatenated text: `Collectors.joining`;
   - numeric primitive result: `mapToInt`/`mapToLong`/`mapToDouble` plus primitive terminals;
   - grouping/indexing: `groupingBy`, `mapping`, `counting`, `summing*`, `summarizing*`,
     `partitioningBy`, or `toMap` with a merge function.
2. Prefer stream terminals that encode the intent directly:

   ```java
   // avoid
   List<Item> out = items.stream().filter(Item::outOfStock).collect(Collectors.toList());
   return !out.isEmpty();

   // prefer
   return items.stream().anyMatch(Item::outOfStock);
   ```

3. Flatten nested sources deliberately. Use `flatMap` for nested collections and
   `flatMap(Optional::stream)` on Java 9+ for `Stream<Optional<T>>`. On Java 16+, consider
   `mapMulti` only when it makes a small zero-or-one/one-to-few transformation clearer or avoids
   many tiny stream allocations.
4. Use primitive streams for primitive aggregation. Prefer `mapToInt(...).sum()`,
   `mapToDouble(...).average()`, `Collectors.summingInt`, or `Collectors.summarizingInt` over
   boxed `reduce` when computing primitive totals or statistics. Use `reduce(identity, op)` for
   immutable non-primitive accumulation such as `BigDecimal`.
5. Choose collectors by map semantics:
   - `toSet` when duplicates are irrelevant and order is not part of the contract;
   - `distinct().sorted()` when producing a sorted unique list, filtering nulls first if natural
     ordering would see nulls;
   - `toMap(key, value)` only when keys are unique, or provide a merge function such as
     `BinaryOperator.minBy(...)`;
   - `groupingBy` when a key maps to many values;
   - `mapping` downstream when grouped values should be projected;
   - `counting`, `summing*`, or `summarizing*` downstream when grouped values should be aggregated;
   - `partitioningBy` for a boolean split where both `true` and `false` keys should exist;
   - `teeing` for two independent reductions over the same stream on Java 12+.
6. Preserve ordering and short-circuit behavior. `sorted`, `distinct`, `limit`, `takeWhile`, and
   `dropWhile` are order-sensitive; changing their order can change results or performance. For
   top-N pipelines, sort before `limit`; for null-sensitive sort keys, filter nulls or use
   `Comparator.nullsFirst/nullsLast`.
7. Keep imperative code when it is the clearer boundary. Stateful sequence output, checked IO,
   prompts, mutation-heavy code, or complex early exits may be better as a loop. If a loop remains,
   still use small stream helpers for real lookups or aggregates when that improves clarity.
8. Verify each changed branch. Run focused tests or reason through empty inputs, one element,
   multiple matches, duplicates, null keys/values, ordering, parallel-safety, and Java-baseline
   compatibility. Run the marker scan from [hard-stops.md](references/hard-stops.md); fix relevant
   hits and re-scan.
