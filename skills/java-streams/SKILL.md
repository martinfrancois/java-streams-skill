---
name: java-streams
license: MIT
description: Review Java stream performance advice, especially slow stream mappings, external collection mutation with forEach/add, and whether parallelStream is safe; clean up mutation and write or refactor Java Stream and Collector code. Avoid common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, multi-line lambdas, and careless findFirst/findAny changes. Use whenever writing, reviewing, or refactoring Java code that uses Java streams or collectors, such as stream pipelines, grouping collectors, joining strings, stream first/any element lookup, sorted/limit/distinct stages, primitive stream totals, Optional values inside streams, or parallel streams, including review prompts asking whether a lookup should use findFirst or findAny.
---

# Java Streams Skill

Keep behavior identical, including encounter order, exceptions, nulls, side effects, and mutability,
and stay within the project's Java baseline. Write the requested Java file before explaining; keep provided helper,
record, and service types in it (nested when requested); add no sibling files, hooks, test seams,
overloads, caches, retries, or adapters unless asked.

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
   minimum versions and fallbacks; do not emulate unavailable APIs with stateful or multi-line
   lambdas.
1. Identify the requested result and pick the matching terminal or collector:

   | Goal | Preferred API |
   |---|---|
   | Arbitrary match, all matches equivalent, order never picks the winner | `filter(...).findAny()` |
   | First match by encounter or sorted order, or code that took element `0` | `filter(...).findFirst()`; keep `sorted(...).filter(...).findFirst()` when it defines the winner, and suggest `min`/`max` only when it keeps that winner |
   | Existence check | `anyMatch` / `noneMatch` / `allMatch` |
   | Transformed list/set | `map`/`filter` then collect |
   | Concatenated text | `Collectors.joining` |
   | Numeric primitive result | `mapToInt`/`mapToLong`/`mapToDouble` terminals |
   | Two aggregates over same input (Java 12+) | `Collectors.teeing` |
   | Grouping/indexing | `groupingBy`, `partitioningBy`, or `toMap` with merge/null handling |

   Checkpoint: before writing the pipeline, confirm the chosen terminal returns the requested type
   and that order, duplicates, and nulls in the input cannot change the winner. In `findFirst`
   versus `findAny` reviews, state that equivalence condition before any performance claim.

2. Use intent-encoding terminals: `anyMatch`, `count`, `joining`, `min`/`max`, Java 12+
   `teeing`, and primitive terminals. Do not mutate external containers, arrays, counters, or
   builders from `forEach`; let the stream produce the result directly.

   ```java
   long overdue = orders.stream().filter(Order::isOverdue).count();   // not forEach + counter++
   ```

   - Implementation: write the direct stream result; on Java 16+ prefer
     `names.stream().map(String::toUpperCase).toList()` over a manual `ArrayList` loop.
   - External-mutation or performance review: show a sequential result-producing snippet first; for
     million-item CPU maps, mention benchmarking a pure parallel variant and include:
     "`parallelStream()` can be slower for small lists or call paths that are usually small."
   - Java 24 bounded blocking calls: carry each element with its result, call the provided service
     directly, then filter/map/sort; no test hooks, overloads, `CompletableFuture` fan-out, or null
     sentinels.

     ```java
     List<Parcel> cleared = parcels.stream()
             .gather(Gatherers.mapConcurrent(limit, parcel -> Map.entry(parcel, customsApi.clears(parcel))))
             .filter(Map.Entry::getValue)
             .map(Map.Entry::getKey)
             .toList();
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

   ```java
   Map<Boolean, List<Order>> byOverdue = orders.stream().collect(Collectors.partitioningBy(Order::isOverdue));
   BigDecimal total = amounts.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
   ```
   Carry `element + result`, never null sentinels.

   ```java
   final class SeatIndex {
       // Latest booking per seat wins; seats without a code are skipped, as the loop did.
       static Map<String, Booking> latestBySeat(List<Booking> bookings) {
           return bookings.stream()
                   .filter(booking -> booking.seatCode() != null)
                   .collect(Collectors.toMap(Booking::seatCode, Function.identity(), SeatIndex::later, LinkedHashMap::new));
       }

       private static Booking later(Booking left, Booking right) {
           return right.bookedAt().isAfter(left.bookedAt()) ? right : left;
       }
   }
   ```
5. Preserve ordering, mutability, short-circuit behavior, and lambda readability. Keep stream lambdas
   as short glue or method references. Extract a named helper when a lambda would branch or wrap,
   when a duplicate-key merge rule needs more than a same-line expression for ties, nulls, or
   ordering, and for nested collector callbacks (a named `Stream<T>` helper).
6. Keep imperative code when it is the clearer boundary for stateful output, checked IO,
   mutation-heavy logic, or complex early exits.
7. Verify changed branches for empty inputs, one element, duplicates, nulls, ordering,
   parallel-safety, and baseline compatibility. Run the marker scan and the parallel-safety
   conditions from [hard-stops.md](references/hard-stops.md) (no custom pool snippets unless asked),
   fix hits, and re-scan. In scan audits, keep
   hard-stop severities: required hits stay required unless explicitly acceptable.

Review output: state the behavior-preserving decision, add one safe snippet, create `review.md`
when asked (also for rejections), explain code behavior only, and never write "per the skill",
"hard stop", "marker", "scan", "checklist", "rubric", or "criteria" unless the user asked about the
workflow itself.
