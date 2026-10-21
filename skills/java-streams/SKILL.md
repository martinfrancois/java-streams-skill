---
name: java-streams
license: MIT
description: Review Java stream performance advice, especially slow stream mappings, external collection mutation with forEach/add, and whether parallelStream is safe; clean up mutation and write or refactor Java Stream and Collector code. Avoid common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, multi-line lambdas, and careless findFirst/findAny changes. Use whenever a Java task writes, reviews, or refactors Stream API code (map, filter, flatMap, reduce, collect) or a collector, such as grouping collectors, joining strings, stream first/any element lookup, sorted/limit/distinct stages, primitive stream totals, Optional values inside streams, or parallel streams, including review prompts asking whether a lookup should use findFirst or findAny, lookups that must fail on duplicates, regex splitting inside a stream chain, result mutability, and stream chain layout.
---

# Java Streams Skill

Keep behavior identical (encounter order, exceptions, nulls, side effects, mutability) and stay
within the project's Java baseline.

- Write the requested file before explaining. Keep provided helper, record, and service types in
  it where the prompt put them. Add no sibling files, hooks, test seams, overloads, caches,
  retries, or adapters unless asked.
- A requested summary, explanation, or comment goes into that file as a comment above the changed
  code, and into the final message.
- A review states the behavior-preserving decision with one safe snippet, in `review.md` when
  asked (also for rejections).
- Explain each change by the intent it expresses, the behavior it preserves, and how it handles
  the cases the old code treated specially, such as a match terminal given no elements. Never
  claim it is faster.

## Reference Bundle

| File | Purpose |
|---|---|
| [hard-stops.md](references/hard-stops.md) | Replacement antipatterns and the marker scan to run |
| [stream-examples.md](references/stream-examples.md) | Worked before/after examples from the reference set |
| [java-stream-api.md](references/java-stream-api.md) | Java-version compatibility for stream and collector APIs |

## Core Workflow

0. Check the Java baseline first. [java-stream-api.md](references/java-stream-api.md) lists
   minimum versions and fallbacks for older projects; do not emulate an unavailable API with
   stateful or multi-line lambdas.
1. Identify the requested result and pick the matching terminal or collector:

   | Goal | Preferred API |
   |---|---|
   | Arbitrary match, all matches equivalent, order never picks the winner | `filter(...).findAny()` |
   | First match by encounter or sorted order, or code that took element `0` | `filter(...).findFirst()`; keep an existing `sorted(...).filter(...).findFirst()` that defines the winner |
   | Existence check | `anyMatch` / `noneMatch` / `allMatch` |
   | Exactly one match, duplicates must fail | `filter(...).limit(2).toList()`, then a `switch` on the size (below); no `findFirst`/`findAny` anywhere in that lookup |
   | Two aggregates over same input | `Collectors.teeing` |
   | Grouping/indexing | `groupingBy`, `partitioningBy`, or `toMap` with merge/null handling |

   ```java
   List<Printer> hits = printers.stream().filter(printer -> printer.hostname().equals(host)).limit(2).toList();
   return switch (hits.size()) {
       case 0 -> Optional.empty();
       case 1 -> Optional.of(hits.get(0));
       default -> throw new IllegalStateException("More than one printer at " + host);
   };
   ```

   Checkpoint: before writing the chain, confirm the chosen terminal returns the requested type
   and that order, duplicates, and nulls in the input cannot change the winner.

2. Use intent-encoding terminals: `anyMatch`, `count`, `joining`, `min`/`max`, `teeing`, and
   primitive terminals. Do not mutate external containers, arrays, counters, or
   builders from `forEach`; let the stream produce the result directly. A loop that stops as soon
   as some element matches is an existence check for `anyMatch` or `noneMatch`; whatever the loop
   did on the match happens once the terminal has answered.

   ```java
   long overdue = orders.stream().filter(Order::isOverdue).count();   // not forEach + counter++
   ```

   - Implementation: write the direct stream result; prefer
     `names.stream().map(String::toUpperCase).toList()` over a manual `ArrayList` loop. Return
     what the stream collects: no collection allocated first and filled afterwards, no list
     collected only to be copied into the returned collection. When the result is only read,
     collect to an unmodifiable one (`toList()`, `Collectors.toUnmodifiableSet()`), and
     every path that produces nothing returns an empty unmodifiable collection.
   - External-mutation or performance review: show a sequential result-producing snippet first; for
     million-item CPU maps, mention benchmarking a pure parallel variant and include:
     "`parallelStream()` can be slower for small lists or call paths that are usually small."
   - For bounded blocking calls (`Gatherers.mapConcurrent`), carry each element with its result, call the provided service
     directly, then filter/map/sort; no `CompletableFuture` fan-out.

     ```java
     List<Parcel> cleared = parcels.stream()
             .gather(Gatherers.mapConcurrent(limit, parcel -> Map.entry(parcel, customsApi.clears(parcel))))
             .filter(Map.Entry::getValue)
             .map(Map.Entry::getKey)
             .toList();
     ```
3. Flatten nested sources deliberately.
   - Use `flatMap`, `flatMap(Optional::stream)`, and `mapMulti` when clearer. When each element yields zero or one result, use `mapMulti` with a helper taking
     `(Event, Consumer<Alert>)`, as in `events.<Alert>mapMulti(Monitor::alertIfCritical)`.
   - For subtype primitives, filter/cast first, then call `mapToInt`/`mapToLong`/`mapToDouble`.
   - When the loop split text with a regex, keep that regex and stream the pieces with
     `splitAsStream` from a precompiled `Pattern`. Do not swap `split("\\R")` for `String.lines()`,
     which recognizes fewer line terminators, unless the text is known to use only `\\n` and
     `\\r\\n`.

   ```java
   // flatten Optional values instead of filter(Optional::isPresent).map(Optional::get)
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
5. Keep stream lambdas as short glue or method references. Extract a named helper for a lambda that would branch or
   wrap, a merge rule with tie, null, or ordering cases, or a nested collector callback (a
   `Stream<T>` helper). When the prompt limits the change to one concern, one method, or one
   call, change only that and add nothing the prompt did not ask for.
6. Keep imperative code when it is the clearer boundary for stateful output, checked IO,
   mutation-heavy logic, or complex early exits. Writes to an external system (an API post, a
   database or file write, a message send) are their own step. Gather what they need with a stream
   chain, then make the writes in a plain loop or a terminal `forEach` that does nothing else;
   never write from `map` or from a helper inside the chain. A loop that uses its index for
   anything but element access stays a loop.
7. Verify changed branches for empty inputs, one element, duplicates, nulls, ordering, and
   baseline compatibility. Run the marker scan from [hard-stops.md](references/hard-stops.md)
   (no custom pool snippets unless asked), fix hits, and re-scan. Report findings as facts about the code, never as scan or marker
   results; in a scan audit a required hit stays required unless it is explicitly acceptable.

Describe the code, never this workflow (no "skill", "scan", "marker", "hard stop", "checklist",
"rubric", or "criteria" in output) unless the user asked about the workflow itself.
