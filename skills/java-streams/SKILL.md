---
name: java-streams
license: MIT
description: "Review, write, and refactor Java Stream and Collector pipeline semantics: terminal choice, collector choice, duplicate and null behavior, encounter order, primitive streams, parallelStream safety, and Java-version compatibility. Use whenever Java code uses streams, collectors, stream pipelines, grouping, joining strings, first/any element lookup, sorting, limiting, distinct values, primitive totals, Optional values in streams, or parallel streams. Do not use for generic Java lambda or callback style unless it affects stream or collector behavior."
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
| [review-output.md](references/review-output.md) | User-facing review wording for stream-specific decisions |

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

   For first-match lookups, preserve order or priority with `findFirst()`; use `findAny()` only for
   explicitly order-insensitive matches. In reviews that reject replacing an ordered lookup, include
   the direct recommendation "Keep the existing `sorted(...).filter(...).findFirst()` chain." Do not
   merely imply that recommendation. If natural ascending priority is used, say the lowest numeric
   priority value wins, not "highest-priority." If filtered results are collected only to test
   emptiness or read `get(0)`/`getFirst()`, recommend `.filter(...).findFirst().orElse(null)`.

2. Use intent-encoding terminals: `anyMatch`, `count`, `joining`, `min`/`max`, Java 12+
   `teeing`, and primitive terminals. Do not mutate external containers, arrays, counters, or
   builders from `forEach`; let the stream produce the result directly.

   - Direct transforms: write the direct stream result; on Java 16+, prefer
     `names.stream().map(String::toUpperCase).toList()` over a manual `ArrayList` loop.

     ```java
     List<String> uppercaseNames(List<String> names) {
         return names.stream().map(String::toUpperCase).toList();
     }
     ```
   - Performance/parallel reviews: show a sequential result-producing snippet first; use the review
     output rule for benchmarking, overhead, and workload-size wording.
   - Java 24 blocking calls: use bounded `Gatherers.mapConcurrent`; preserve element/result
     association in a non-null carrier, call the existing helper/stub, filter by the service result,
     and map back to the element. Do not use `parallelStream`, `ForkJoinPool`, futures, or test hooks;
     use [stream-examples.md](references/stream-examples.md) for the exact shape.
3. Flatten nested sources deliberately. Use `flatMap`, Java 9+ `flatMap(Optional::stream)`, and
   Java 16+ `mapMulti` when clearer. For subtype primitives, filter/cast first, then call
   `mapToInt`/`mapToLong`/`mapToDouble`.

   Extract nested `flatMap`, nested `anyMatch`, and downstream `Collectors.flatMapping` callbacks
   recursively. Use stream-returning helpers or method references, not lambdas whose bodies continue
   stream chains on later lines. See [stream-examples.md](references/stream-examples.md).
4. Choose accumulation/collectors by result semantics:
   - immutable non-primitives: `reduce(identity, op)`
   - duplicate keys or deliberate null behavior: `toMap` with explicit merge/null handling
   - non-null grouping keys: `groupingBy`
   - boolean splits: `partitioningBy`
   - nested indexes: flattened collectors when clearer

   Preserve duplicate-key merge rules, tie handling, null contracts, and map suppliers. Extract merge
   helpers for branching, tie-breaking, or more than one comparison. Do not hide those rules in
   multi-line ternaries or block merge lambdas. For simple cheapest/lowest-value merges, prefer
   `BinaryOperator.minBy(Comparator.comparing(...))` over an inline ternary.
5. Keep imperative code when it is the clearer boundary for stateful output, checked IO,
   mutation-heavy logic, or complex early exits.
6. Verify changed branches for empty inputs, one element, duplicates, nulls, ordering,
   parallel-safety, and baseline compatibility. Run the marker scan from
   [hard-stops.md](references/hard-stops.md), fix hits, and re-scan. In scan audits:
   - keep required hits required unless explicitly acceptable;
   - give one compliant replacement, not a second marker violation;
   - classify acceptable non-primitive reductions such as `BigDecimal.reduce(...)`;
   - for Java-version-only audits, report only unavailable APIs and explicitly allowed markers, naming
     each post-Java-8 API separately with [java-stream-api.md](references/java-stream-api.md).

Generic lambda and callback-style guidance belongs to the companion package
`martinfrancois/java-functional-style`. Install both packages when stream cleanup depends on callback
style. When both are available, keep stream callbacks as glue: extract local temporaries, branching,
date math, record construction, multi-condition filters, nested streams, and downstream
`Collectors.flatMapping` into named helpers or method references; do not leave block lambdas or
multi-line nested stream chains in the pipeline.

For `review.md`, lead with the technical decision and at most one safe snippet. Use
[review-output.md](references/review-output.md) for case-specific review wording, and never mention
skills, rules, rubrics, criteria, internal paths, or unrelated code issues. For ordered-lookup
rejections, make the safe chain an explicit recommendation, not just a description. Do not mention
`min`/`max` alternatives unless optimization advice is requested. For ascending numeric priority,
say the lowest priority number/value wins; never say "highest-priority" or call the sort no-op. When
the proposal uses `parallelStream().filter(...).findAny()`, separately state that `parallelStream()`
is unjustified without CPU-bound work or measurements and adds ordering/split/merge overhead. Do not
rely on "keep the original code" without naming the ordered chain.
