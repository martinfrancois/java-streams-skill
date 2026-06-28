---
name: java-streams
license: MIT
description: Review Java stream performance advice, especially slow stream mappings, external collection mutation with forEach/add, and whether parallelStream is safe; clean up mutation and write or refactor Java Stream and Collector code. Avoid common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, and careless findFirst/findAny changes. Use whenever writing, reviewing, or refactoring Java code that uses Java streams, collectors, stream pipelines, grouping, joining strings, first/any element lookup, sorting, limiting, distinct values, primitive totals, Optional values in streams, or parallel streams, including review prompts asking whether a lookup should use findFirst or findAny.
---

# Java Streams Skill

Preserve requested behavior, public API/artifact shape, encounter order, exceptions, null handling,
side effects, mutability, and Java-version compatibility. For implementation prompts, write the
requested Java source file before explaining. Keep provided helper/record/service types in that file,
and keep them nested when requested; do not create sibling source files, package-private top-level
replacements, hooks, test seams, delegate fields, overloads, caches, retries, or adapters unless
asked.

## Reference Bundle

| File | Purpose |
|---|---|
| [hard-stops.md](references/hard-stops.md) | Replacement antipatterns and the marker scan to run |
| [stream-examples.md](references/stream-examples.md) | Worked before/after examples from the reference set |
| [java-stream-api.md](references/java-stream-api.md) | Java-version compatibility for stream and collector APIs |

## Core Workflow

When the prompt asks for a named artifact such as `review.md` or a Java source file, create that
exact file. Do not answer only in chat when a file artifact is requested.

0. Check the Java baseline first. Use [java-stream-api.md](references/java-stream-api.md) for
   minimum versions and fallbacks.
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

   Find-first rule: keep `findFirst()` when code takes element `0`, sorted order, or encounter order
   chooses the winner. In these reviews, include the exception before performance claims: `findAny`
   fits only if all matching values are equivalent and order does not choose the winner. Keep
   `sorted(...).filter(...).findFirst()` when it defines the selected value; suggest `min`/`max` only
   when it preserves that winner.

2. Use intent-encoding terminals: `anyMatch`, `count`, `joining`, `min`/`max`, Java 12+
   `teeing`, and primitive terminals. Do not mutate external containers, arrays, counters, or
   builders from `forEach`; let the stream produce the result directly.

   - Implementation prompts: for one-to-one transformations, write the direct stream result unless
     mutable output or the Java baseline says otherwise; on Java 16+, prefer
     `names.stream().map(String::toUpperCase).toList()` over a manual `ArrayList` loop.
   - External mutation/performance reviews: show a sequential result-producing snippet first. For
     million-item CPU maps, mention benchmarking a pure parallel variant and include:
     "`parallelStream()` can be slower for small lists or call paths that are usually small."
   - Parallel reviews: apply [hard-stops.md](references/hard-stops.md); no custom pool snippets
     unless asked.
   - Java 24 bounded blocking calls: use `Gatherers.mapConcurrent(limit, item -> carrier(item,
     stub(item)))`, then filter/map/sort; no test hooks, overloads, `CompletableFuture` fan-out, or
     null sentinels.

   ```java
   import java.util.List;

   final class OrderChecks {
       boolean hasOverdue(List<Order> orders) {
           return orders.stream().anyMatch(Order::isOverdue);
       }

       record Order(boolean overdue) {
           boolean isOverdue() {
               return overdue;
           }
       }
   }
   ```
3. Flatten nested sources deliberately. Use `flatMap`, `flatMap(Optional::stream)` on Java 9+,
   and `mapMulti` on Java 16+ when clearer. For subtype primitives, filter/cast first, then call
   `mapToInt`/`mapToLong`/`mapToDouble` directly.

   ```java
   // Java 9+: flatten Optional values instead of filter(Optional::isPresent).map(Optional::get)
   optionals.stream().flatMap(Optional::stream).collect(Collectors.toList());
   ```
4. Choose accumulation/collectors by result semantics: use `reduce(identity, op)` for immutable
   non-primitives, `toMap` with merge behavior and deliberate null-key/value handling, non-null keys
   for `groupingBy`, `partitioningBy` for boolean splits, and flattened nested indexes when clearer.
   Preserve duplicate-key merge rules, tie handling, null contracts, and map suppliers. Carry
   `element + result`, never null sentinels.
5. Preserve ordering, mutability, short-circuit behavior, and stream/collector semantics.
6. Keep imperative code when it is the clearer boundary for stateful output, checked IO,
   mutation-heavy logic, or complex early exits.
7. Verify changed branches for empty inputs, one element, duplicates, nulls, ordering,
   parallel-safety, and baseline compatibility. Run the marker scan from
   [hard-stops.md](references/hard-stops.md), fix hits, and re-scan. In scan audits, keep
   hard-stop severities: required hits stay required unless explicitly acceptable.

Generic lambda, method-reference, identity-function, no-op callback stage, supplier-laziness, and
callback readability guidance belongs to the companion package `martinfrancois/java-functional-style`.
Install both packages when stream cleanup also depends on non-trivial callback style.

Review output:

- Give a direct behavior-preserving decision plus one safe snippet.
- Create `review.md` when requested, even for rejection-only reviews.
- Explain code behavior, not internal workflow.
- Avoid internal workflow labels such as "per the skill", "hard stop", "marker", "scan",
  "checklist", "rubric", or "criteria" unless the user asks about the workflow itself.
