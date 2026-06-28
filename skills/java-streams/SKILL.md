---
name: java-streams
license: MIT
description: Review Java stream performance advice, especially slow stream mappings, external collection mutation with forEach/add, and whether parallelStream is safe; clean up mutation and write or refactor Java Stream and Collector code. Avoid common stream antipatterns such as materializing just to inspect, sorting before min/max, counting for existence, nested stream collections, unsafe null sorting, and careless findFirst/findAny changes. Use whenever writing, reviewing, or refactoring Java code that uses Java streams, collectors, stream pipelines, grouping, joining strings, first/any element lookup, sorting, limiting, distinct values, primitive totals, Optional values in streams, or parallel streams, including review prompts asking whether a lookup should use findFirst or findAny.
---

# Java Streams Skill

Preserve requested behavior, public API/artifact shape, encounter order, exceptions, null handling,
side effects, mutability, and Java-version compatibility. For implementation prompts, write only the
requested source; no extra public API, Javadoc, null guards, constructors, or utility ceremony unless
asked. Keep provided helper/record/service types in the requested file and nested when requested.

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
   | Existence check | `anyMatch` / `noneMatch` / `allMatch` |
   | Transformed list/set | `map`/`filter` then collect |
   | Concatenated text | `Collectors.joining` |
   | Numeric primitive result | `mapToInt`/`mapToLong`/`mapToDouble` terminals |
   | Two aggregates over same input (Java 12+) | `Collectors.teeing` |
   | Grouping/indexing | `groupingBy`, `partitioningBy`, or `toMap` with merge/null handling |

   Use `findAny()` only when all matches are equivalent and order does not choose the winner; in
   reviews, name that exception with the code's noun, e.g. "all matching primary addresses are
   equivalent." Use `findFirst()` when element `0`, sorted order, encounter order, or priority
   selects the value. Do not offer `min`/`max` unless the user asks for optimization.

2. Use intent-encoding terminals: `anyMatch`, `count`, `joining`, `min`/`max`, Java 12+
   `teeing`, and primitive terminals. Do not mutate external containers, arrays, counters, or
   builders from `forEach`; let the stream produce the result directly.

   - Direct transforms: write the direct stream result; on Java 16+, prefer
     `names.stream().map(String::toUpperCase).toList()` over a manual `ArrayList` loop.
   - Performance/parallel reviews: for external mutation, show a sequential result-producing snippet
     first. Explicitly separate the correctness fix from the performance decision: collecting
     directly removes external mutation; it is not a guaranteed throughput win. Do not cite resize
     overhead or list throughput as why `forEach(add)` is wrong. If discussing parallel work, mention
     measurement, common-pool/split overhead, and slower small-list or mostly-small call paths.
   - Java 24 bounded blocking calls: use `Gatherers.mapConcurrent` as documented in
     [java-stream-api.md](references/java-stream-api.md); no test hooks, overloads,
     `CompletableFuture` fan-out, or null sentinels. Call the provided production stub directly and
     carry `element + boolean result` through a non-null holder:

     ```java
     records.stream()
             .gather(Gatherers.mapConcurrent(
                     limit,
                     record -> new Checked<>(record, RemoteService.accepts(record.id()))))
             .filter(Checked::accepted)
             .map(Checked::value)
             .toList();

     record Checked<T>(T value, boolean accepted) {}
     ```
3. Flatten nested sources deliberately. Use `flatMap`, `flatMap(Optional::stream)` on Java 9+,
   and `mapMulti` on Java 16+ when clearer. For subtype primitives, filter/cast first, then call
   `mapToInt`/`mapToLong`/`mapToDouble` directly.
   Extract nested `flatMap` callbacks recursively: use `.flatMap(Type::childEntries)`, keep helpers
   stream-based rather than temp-list loops, and repeat inside helpers until callbacks no longer
   continue stream chains across lines. Apply the same shape to nested `anyMatch` chains and
   downstream `Collectors.flatMapping`: use named stream-returning helpers or method references, not
   lambdas whose bodies continue a nested stream chain on later lines. See
   [stream-examples.md](references/stream-examples.md) for final-shape helper patterns.

   ```java
   // Java 9+: flatten Optional values instead of filter(Optional::isPresent).map(Optional::get)
   optionals.stream().flatMap(Optional::stream).collect(Collectors.toList());
   ```
4. Choose accumulation/collectors by result semantics: use `reduce(identity, op)` for immutable
   non-primitives, `toMap` with merge behavior and deliberate null-key/value handling, non-null keys
   for `groupingBy`, `partitioningBy` for boolean splits, and flattened nested indexes when clearer.
   Preserve duplicate-key merge rules, tie handling, null contracts, and map suppliers. Carry
   `element + result`, never null sentinels. Extract collector merge helpers when duplicate-key
   resolution needs branching, tie-breaking, or more than one comparison; do not hide those rules in
   multi-line ternaries or block merge lambdas.
5. Preserve ordering, mutability, short-circuit behavior, and stream/collector semantics.
6. Keep imperative code when it is the clearer boundary for stateful output, checked IO,
   mutation-heavy logic, or complex early exits.
7. Verify changed branches for empty inputs, one element, duplicates, nulls, ordering,
   parallel-safety, and baseline compatibility. Run the marker scan from
   [hard-stops.md](references/hard-stops.md), fix hits, and re-scan. In scan audits, keep
   hard-stop severities: required hits stay required unless explicitly acceptable; also name
   acceptable non-primitive reductions such as `BigDecimal.reduce(...)` when present.

Generic lambda and callback-style guidance belongs to the companion package
`martinfrancois/java-functional-style`. Install both packages when stream cleanup depends on callback
style. When both are available, keep stream callbacks as glue: extract nested callback bodies and
filters with more than one domain condition to named helpers.

Review output: give a direct behavior-preserving decision plus one safe snippet. For `review.md`,
write short prose first; avoid tables, extra snippets, style sections, redundant-output sections, and
internal workflow labels unless asked. For ordered lookup rejections, include: "Keep the existing
`sorted(...).filter(...).findFirst()` chain." When rejecting `parallelStream().findAny()`, say
parallelism makes ordered selection less predictable or more expensive here and no CPU-bound work or
measurement justifies the overhead.
