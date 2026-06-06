---
name: java-streams
license: MIT
description: Write, review, and refactor Java Stream and Collector code using best practices, improving readability and performance while avoiding common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, and careless findFirst/findAny or parallelStream changes. Use whenever writing, reviewing, or refactoring Java code that uses streams, collectors, primitive streams, Optional-producing stream terminal operations, map/flatMap/mapMulti, grouping, joining, distinct, sorted, limit, takeWhile/dropWhile, teeing, partitioningBy, summarizing, or parallel stream behavior.
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

Before finalizing touched stream flow, run the scan and apply the replacement rules in
[hard-stops.md](references/hard-stops.md).
Filtered-list first-element access has first-match semantics; use `findFirst()` unless all matches
are equivalent.

## Core Workflow

0. Check the Java baseline before choosing APIs. Read build/toolchain docs; if unclear, use Java
   8-compatible code or state the assumption. Use [java-stream-api.md](references/java-stream-api.md)
   for minimum Java versions.
1. Identify the result shape:
   - one arbitrary/equivalent match: `filter(...).findAny()`;
   - first encounter-order, priority, chronological, or user-visible match:
     `filter(...).findFirst()`;
   - existence: `anyMatch`, `noneMatch`, or `allMatch`;
   - transformed list/set: `map`/`filter` then collect;
   - concatenated text: `Collectors.joining`;
   - numeric primitive result: `mapToInt`/`mapToLong`/`mapToDouble` plus primitive stream terminal
     operations;
   - two independent aggregates over the same input on Java 12+: `Collectors.teeing`;
   - grouping/indexing: `groupingBy`, downstream collectors, `partitioningBy`, or `toMap` with
     explicit merge/null handling.
2. Prefer stream terminal operations that encode intent directly: `anyMatch` for existence, `count`
   for numeric counts, `joining` for text, `min`/`max` for a single extreme, `teeing` for a Java
   12+ min/max pair over the same input, and primitive stream terminal operations for primitive
   totals.
3. Flatten nested sources deliberately. Use `flatMap` for nested collections and
   `flatMap(Optional::stream)` on Java 9+. On Java 16+, prefer `mapMulti` for mixed subtype checks or
   small conditional emission; use primitive streams for primitive results.
4. Use primitive streams for primitive aggregation. Keep and explicitly classify `reduce(identity,
   op)` as acceptable for immutable non-primitive accumulation such as `BigDecimal`.
5. Choose collectors by result semantics, and state duplicate-key/null contracts explicitly. When a
   later step needs an expensive check result, carry `element + result`; do not use `null` sentinels.
6. Preserve ordering, mutability, and short-circuit behavior. For top-N, sort before `limit`; for
   nullable sort keys, filter or use `Comparator.nullsFirst/nullsLast`; for mutable results, keep a
   mutable collector.
7. Keep imperative code when it is the clearer boundary. Stateful sequence output, checked IO,
   prompts, mutation-heavy code, or complex early exits may be better as a loop. If a loop remains,
   still use small stream helpers for real lookups or aggregates when that improves clarity.
8. Verify each changed branch. Check empty inputs, one element, duplicates, nulls, ordering,
   parallel-safety, and Java-baseline compatibility. Run the marker scan from
   [hard-stops.md](references/hard-stops.md); copy its header and command verbatim when documenting
   a scan. Fix relevant hits and re-scan.

Short reviews: decision first, direct stream issues only, one safer shape if useful. Omit scan
details and unchanged-code critiques unless asked.

Quick examples:

```java
boolean hasOutOfStock = products.stream()
        .anyMatch(product -> product.stock() == 0);

Optional<Product> newest = products.stream()
        .max(Comparator.comparing(Product::updatedAt));
```
