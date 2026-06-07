---
name: java-streams
license: MIT
description: Write, review, and refactor Java Stream and Collector code using best practices, improving readability and performance while avoiding common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, and careless findFirst/findAny or parallelStream changes. Use whenever writing, reviewing, or refactoring Java code that uses streams, collectors, primitive streams, Optional-producing stream terminal operations, map/flatMap/mapMulti, grouping, joining, distinct, sorted, limit, takeWhile/dropWhile, teeing, partitioningBy, summarizing, or parallel stream behavior.
---

# Java Streams Skill

Preserve behavior, encounter order, exceptions, null handling, side effects, mutability, and
Java-version compatibility.

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
1. Identify the requested result and pick the matching terminal or collector:

   | Goal | Preferred API |
   |---|---|
   | Arbitrary/equivalent match | `filter(...).findAny()` |
   | First encounter-order match | `filter(...).findFirst()` |
   | Existence check | `anyMatch` / `noneMatch` / `allMatch` |
   | Transformed list/set | `map`/`filter` then collect |
   | Concatenated text | `Collectors.joining` |
   | Numeric primitive result | `mapToInt`/`mapToLong`/`mapToDouble` terminals |
   | Two aggregates over same input (Java 12+) | `Collectors.teeing` |
   | Grouping/indexing | `groupingBy`, `partitioningBy`, or `toMap` with merge/null handling |

2. Prefer terminal operations that encode intent directly: `anyMatch` for existence, `count`
   for numeric counts, `joining` for text, `min`/`max` for a single extreme, `teeing` for a Java
   12+ min/max pair over the same input, and primitive stream terminal operations for primitive
   totals.

   ```java
   // Before: counts all matches just to test existence
   boolean hasLateOrders = orders.stream().filter(Order::late).count() > 0;
   // After: short-circuits when the first match is found
   boolean hasLateOrders = orders.stream().anyMatch(Order::late);
   ```

   External mutation: do not create an `ArrayList`, `HashMap`, array, counter, holder object, or
   `StringBuilder` and mutate it from `forEach`; let the stream produce the result directly.
   Performance review: show sequential direct collection as the correctness baseline first; mention
   a pure parallel collection benchmark prominently for large CPU-bound inputs.

3. Flatten nested sources deliberately. Use `flatMap` for nested collections and
   `flatMap(Optional::stream)` on Java 9+. On Java 16+, prefer `mapMulti` for small conditional
   reference-value emission. For primitive values from a subtype, filter/cast first then
   `mapToInt`/`mapToLong`/`mapToDouble` directly; do not box and immediately unbox.

4. Use primitive streams for primitive aggregation. Use `reduce(identity, op)` for immutable
   non-primitive accumulation such as `BigDecimal`.
5. Choose collectors by result semantics. For `toMap`, specify duplicate-key merge behavior; for
   `groupingBy`, prove classifier keys are non-null or handle nulls first; for boolean splits, use
   `partitioningBy`; when a later step needs an expensive result, carry `element + result`, never
   null sentinels.

6. Preserve ordering, mutability, and short-circuit behavior:
   - **Top-N**: sort before `limit`.
   - **Nullable sort keys**: filter nulls or use `Comparator.nullsFirst`/`nullsLast`.
   - **Mutable results**: use `Collectors.toList()` or `Collectors.toCollection(ArrayList::new)`, not `Stream.toList()`.
   - **Short-circuit**: omit stateful intermediate ops (e.g., `sorted`) before `findFirst`/`anyMatch` when order is irrelevant.
   - **Lambda purity**: mapping/filtering lambdas should not mutate state visible outside the
     lambda and should not depend on outside state that can change during the stream operation.
7. Keep imperative code when it is the clearer boundary. Prefer a loop for stateful sequence
   output, checked IO, mutation-heavy logic, or complex early exits. Where a loop remains, use
   stream helpers for real lookups or aggregates when that improves clarity.
8. Verify each changed branch: empty inputs, one element, duplicates, nulls, ordering,
   parallel-safety, and Java-baseline compatibility. Run the marker scan from
   [hard-stops.md](references/hard-stops.md); fix relevant hits and re-scan.

Short reviews: decision first, direct stream issues only, one safer stream chain if useful. Avoid
internal workflow labels such as "hard stop", "marker", "scan", "checklist", or skill names in
user-facing output unless the task explicitly asks for that workflow. Omit scan details and
unchanged-code critiques unless asked.
