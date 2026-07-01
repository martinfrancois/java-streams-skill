# Java Stream Hard Stops

Use this reference before finalizing Java stream cleanup or first-pass implementation when the code
touches stream terminal operations, collectors, ordering, primitive aggregation, null sorting, or
parallelism.

## Replacement Antipatterns

Fix these before finalizing:

- `filter(...).collect(...).isEmpty()`, `filter(...).collect(...).size()`, or a temporary list just
  to decide existence. Use `anyMatch`, `noneMatch`, `allMatch`, `findAny`, or `findFirst`.
- A temporary filtered list followed by `get(0)`, `getFirst()`, or equivalent first-element access.
  Use `findFirst` to preserve encounter-order behavior unless the domain explicitly says all matches
  are equivalent and encounter order does not decide the result. In reviews that compare
  `findFirst` and `findAny`, name that `findAny` exception explicitly before discussing parallelism
  or performance. Do not say `findAny` is appropriate merely because the stream is parallel or
  unordered.
- `filter(...).count() > 0` for existence. Use `anyMatch`.
- Plain `count()` is appropriate when the requested result is a numeric count; do not replace it
  with `anyMatch`.
  The hard-stop scan regex catches only `count() > 0` existence checks, not plain `count()`. If an
  audit calls out plain `count()` as allowed, say it is an allowed usage, not a scan hit.
- `sorted(...).findFirst()` or sorted-then-sublist just to get one extreme. Use `min`/`max`; keep
  sorting only when the ordered list itself is required.
- Two separate `min` and `max` stream passes over the same input when Java 12+ is available and the
  requested result is a pair/range. Use `Collectors.teeing(minBy(...), maxBy(...), ...)` so the
  stream states "compute these two aggregates together".
- `map(...).collect(toList())` followed immediately by `String.join`. Use `Collectors.joining`.
- Boxed numeric `reduce` for primitive totals/statistics. Use primitive streams or summarizing
  collectors unless the type is genuinely non-primitive, such as `BigDecimal`.
  In audits, explicitly classify non-primitive reductions such as
  `reduce(BigDecimal.ZERO, BigDecimal::add)` as acceptable.
- Nested `map(... stream ... collect(...)).flatMap(...)` where a direct `flatMap` stream chain is
  clearer.
- Nested `flatMap`, `Collectors.flatMapping`, or `anyMatch` callbacks whose bodies continue stream
  chains across later lines. Extract stream-returning or boolean helpers so the outer chain reads as
  glue while preserving flattening and short-circuit semantics.
- Stream `filter` predicates with more than one meaningful domain condition when a named predicate
  helper would explain the rule, such as "undelivered and past due".
- `filter(Optional::isPresent).map(Optional::get)` on Java 9+. Use `flatMap(Optional::stream)`.
- `toMap` without a merge function when duplicate keys are possible.
- `toMap` over keys that the original loop skipped when null. Preserve the skip-null behavior with
  a filter before collecting; do not describe a single null key as a guaranteed exception.
- `groupingBy` where null classifier keys can reach the collector. Treat this as a required fix,
  not a conditional caveat, unless the code already proves non-null before the collector. In scan
  audits, use unambiguous wording such as "requires fix"; do not downgrade nullable `groupingBy` to
  "requires review".
- Also fix `toMap` where null keys or values would change the existing null-handling contract. Do
  not say `toMap` throws `NullPointerException` just because a key is null: the default `HashMap`
  result may keep one null key, duplicate null keys fail as duplicate keys, and null values are
  rejected. If the original loop skipped null keys, filter them before `toMap` so the behavior is
  deliberate rather than accidental.
  In scan audits, classify marker hits against the task's domain notes. If the task states an
  invariant that makes a marker acceptable, such as globally unique `toMap` keys or non-null
  `groupingBy` classifiers, list it as acceptable with that invariant. Do not turn a proven
  invariant into a required fix unless the task asks for defensive hardening.
- `sorted()` or `Comparator.naturalOrder()` where null elements or keys can reach the comparator.
- `sorted().distinct()` when the same result can be produced as `distinct().sorted()`. In scan
  audits, classify this as a required ordering/efficiency fix rather than an acceptable minor note,
  unless the code needs sort-before-de-duplication semantics.
- `Stream.toList()` where a mutable result is required or later code mutates the list. Prefer a
  mutable collector; do not modernize this to `new ArrayList<>(stream.toList())` when the task or
  surrounding code says `Stream.toList()` is not valid.
- `stream().forEach(...)` or `parallelStream().forEach(...)` that mutates an external
  `Collection`, `Map`, array, counter, holder object, or `StringBuilder`. Make the stream produce
  the result directly with `toList()`, `collect(...)`, `toMap(...)`, `joining`, `sum`, or another
  matching terminal operation. Do not recommend `Collections.synchronizedList`, `AtomicInteger`, or
  similar wrappers as the default fix when a collector or terminal operation owns the accumulation.
  A terminal `forEach` can remain when the side effect is the actual goal, such as logging or
  calling an API, and the side effect is safe for the chosen stream mode.
- `parallelStream()` or `.parallel()` added without checking CPU-bound work, data size, ordering,
  shared state, blocking calls, and collector safety.
- Blocking predicate-like checks that return the original element or `null` as a false sentinel.
  Carry the element with the explicit service result, then filter and map back to the element. Use a
  boolean result for boolean-returning services; keep the full decision record when the service
  returns one. Use `Map.entry` only on Java 9+ when both values are non-null; otherwise use a
  null-tolerant holder such as `AbstractMap.SimpleImmutableEntry` or a project type.
- Java-version drift: `toList`, `mapMulti`, `teeing`, `takeWhile`, `dropWhile`, `Optional.stream`,
  `Collectors.flatMapping`, `Stream.ofNullable`, or gatherers used below their minimum Java version.
  For a version-drift audit, report these unavailable APIs and explicitly allowed markers only; do
  not add unrelated modernization suggestions, import cleanup, `groupingBy` null-key, or
  collector-safety caveats.
  For below-baseline replacement code, preserve stream semantics with a small loop or helper when
  no equivalent stream API exists, such as `takeWhile`/`dropWhile` prefixes, downstream
  flat-mapping, or paired min/max aggregation.
  Do not sketch below-baseline replacements that keep a nested stream chain lambda across lines; use
  a named helper or plain loop instead.
  For Java 8 `Collectors.flatMapping` drift, give the loop/helper replacement as the primary
  replacement; do not include a nested `flatMap(... -> ...stream().map(...))` alternative.
  For Java 8 `mapMulti` drift, use `map(...)` when the callback emits exactly one value per input,
  or `flatMap(...)`/a helper only for real one-to-many emission. Do not invent replacements using
  post-Java-8 helpers such as `describeConstable`, `Optional.stream`, or `Map.entry`.
  Java 8 replacement snippets must not use Java 9+ helpers such as `Map.entry`.
  When one stream chain contains multiple unavailable APIs, list each unavailable API separately.
  Example: `flatMap(Optional::stream).toList()` on a Java 8 baseline has two version-drift hits:
  `Optional::stream` requires Java 9 and `Stream.toList()` requires Java 16.
- Missing imports for stream APIs introduced by the rewrite, such as `Comparator`, `Map`,
  `Collectors`, `BinaryOperator`, or `Gatherers`.

Generic identity-function, no-op callback stage, supplier-laziness, and callback readability
markers belong to `java-functional-style`, not this stream hard-stop scan.

## Ordering Rules

- Keep `findFirst()` when list order, configuration priority, chronological order, first fallback,
  or user-visible order matters.
- For numeric priority sorted with `Comparator.comparing(...priority...)`, describe the contract
  precisely, for example "lowest priority number wins" when natural ascending order is used.
- When reviewing a proposed replacement of ordered selection with `findAny()` or `parallelStream()`,
  recommend keeping the existing ordered `sorted(...).filter(...).findFirst()` chain first. Mention
  `min(...)`/`max(...)` only as an optional refactor when the task asks for optimization advice.
  For a `parallelStream().findAny()` proposal, explicitly state that parallelism makes the ordered
  selection less predictable or more expensive here, and that no CPU-bound work or measurement
  justifies that overhead.
- Use `findAny()` only when the domain explicitly says all matching domain values, such as
  replicated endpoints with identical results, are equivalent and encounter order does not define
  which one wins. Use
  `findFirst()` for first configured, first listed, chronological, priority, fallback, or
  user-visible results. In reviews, state the positive exception with the code's noun, e.g.
  "`findAny()` would be appropriate only if the domain declares all matching primary addresses
  equivalent and encounter order does not define which one wins." Do not present `findAny()` as a
  performance shortcut unless that semantic precondition is already satisfied.
- `distinct().sorted()` is the required rewrite for `sorted().distinct()` when duplicates can be
  removed before sorting and no sort-before-de-duplication semantics are required.
- `limit(n)` must come after sorting when computing top-N by an ordering. It may come before an
  expensive map/filter only when that preserves semantics.
- `takeWhile` and `dropWhile` are prefix operations. They are not replacements for `filter`.

## Parallelism Rules

Use parallel streams only after checking:

1. Work per element is CPU-heavy enough to amortize split/merge overhead.
2. Operations are stateless and non-interfering.
3. Encounter order is not required, or the ordered stream terminal operation is still worth the cost.
4. The stream chain does not perform blocking IO or remote calls. For Java 24+ blocking per-element
   calls with a requested concurrency limit, use `Gatherers.mapConcurrent` with that bound when the
   baseline supports it and virtual-thread concurrency is the intended design. Preserve
   element/result association explicitly with a baseline-compatible holder rather than null sentinels
   or side maps. Do not add wrapper hooks, overloads, delegates, futures, sentinels, caches, or
   retries unless requested. Do not replace bounded stream concurrency with unbounded
   `CompletableFuture` fan-out. For remote calls, call out the concurrency limit, timeout handling
   for slow calls, and error propagation/retry policy.
5. The stream terminal operation or collector is safe under parallel execution.

For acceptable CPU-heavy parallel streams, state that the benefit should be measured or benchmarked
because fork-join splitting, merging, and common-pool contention can outweigh the gain. For code
whose main problem is external mutation such as `stream().map(...).forEach(result::add)`, recommend
the direct collector/toList form as the correctness/readability baseline. Do not claim that direct
collection is guaranteed faster, and do not say `parallelStream()` will be faster merely because the
input is large. Explain the rewrite in terms of ownership, correctness, and readability; treat
low-level allocation details as secondary unless measurements make them relevant. Never describe
ordinary `ArrayList` growth as `O(N^2)`; resizing is amortized O(N) total. In reviews, show the
sequential direct-collection fix before any parallel version.
For external-mutation performance reviews, include the distinction in plain text: direct collection
fixes correctness/readability first; throughput still requires benchmarking a side-effect-free
sequential stream against a side-effect-free parallel stream on the real workload.
When the workload is not clearly CPU-bound or the input is expected to be small/tiny, explicitly state
that parallelization is not justified here.
For large CPU-bound transformations, strongly recommend benchmarking a pure parallel version after
the stream chain is side-effect-free; make the benchmark requirement visible next to that
recommendation and before any parallel snippet, and call out that small-list or mostly-small call
paths can be slower.
For external-mutation performance reviews, keep the main snippet sequential and do not add unrelated
style notes about logging, printing, imports, naming, or nearby code.
Do not say the speedup is expected, significant, core-count-scaled, or otherwise likely until
measurements support it.
For simple cache/index construction, filtering, or map population, explicitly say when there is no
CPU-heavy stateless work to justify `parallelStream()`. Do not suggest `toConcurrentMap` or another
parallel collector as the main fix unless the task provides measured need or genuinely CPU-heavy
per-element work. Prefer sequential collector-owned accumulation. In shared-map/list mutation
reviews, keep the decision scoped to the race/corruption risk, lack of CPU-heavy work or
measurement, and the collector-owned replacement; do not add encounter-order warnings unless the
task's behavior depends on encounter order.

## Scan Command

When documenting a scan, start with this header so later reviews can tell which workflow was used:

```text
java-streams hard-stop scan v1
```

Run a hard-stop scan over touched Java files before finalizing. The command uses PCRE2 and
multiline mode so it catches normally formatted fluent chains. Some markers are intentionally broad;
classify legitimate uses instead of deleting them mechanically.

```bash
rg -nUP "count\\(\\)\\s*>\\s*0|collect\\([^;]+\\)\\s*\\.\\s*(?:isEmpty|size|getFirst)\\(|collect\\([^;]+\\)\\s*\\.\\s*get\\(\\s*0\\s*\\)|sorted\\([^;]*\\)\\s*\\.\\s*findFirst\\(|sorted\\(\\)\\s*\\.\\s*findFirst\\(|limit\\([^;]+\\)\\s*\\.\\s*sorted\\(|sorted\\([^;]*\\)\\s*\\.\\s*distinct\\(|sorted\\(\\)\\s*\\.\\s*distinct\\(|String\\.join\\(|filter\\(Optional::isPresent\\)\\s*\\.\\s*map\\(Optional::get\\)|parallelStream\\(|\\.parallel\\(|\\.forEach\\(|Collectors\\.toMap\\(|Collectors\\.groupingBy\\(|Comparator\\.naturalOrder\\(\\)|(?<!Collectors)\\.toList\\(|mapMulti\\(|takeWhile\\(|dropWhile\\(|Collectors\\.teeing\\(|Optional::stream|Collectors\\.flatMapping|Stream\\.ofNullable|\\.gather\\(" <touched Java files>
```

For each hit, decide whether it is legitimate for the project Java baseline and behavior. Fix
stream-quality issues. If a marker remains because it is legitimate, state why. When an audit asks
for allowed stream markers or allowed usages, also call out plain `count()` when it is the requested
numeric result rather than a `count() > 0` existence check, and state that plain `count()` is not a
hit for the bundled scan regex.
Also call out non-primitive reductions such as `reduce(BigDecimal.ZERO, BigDecimal::add)` as
acceptable when the requested/domain type is non-primitive; do not force primitive aggregation for
`BigDecimal`.

In ordinary code reviews, do not expose internal workflow labels such as "hard stop", "marker",
"scan", or "skill checklist" in headings, rationale, or recommendations. Use those terms only when
the task explicitly asks for a scan/workflow audit or exact skill-provided command.

When the requested audit is specifically about Java-version drift, keep the report scoped to APIs
that are unavailable for the stated baseline and to explicitly allowed markers. Do not add unrelated
collector/null-safety notes, such as `groupingBy` null-key caveats, unless the task also asks for a
general stream safety review. Reconcile every scan hit against the code before writing the final
audit; do not drop a later hit just because an earlier hit appears in the same stream chain.
