# Stream Review Output

Use these rules only for user-facing stream reviews. Keep the final artifact focused on the Java
behavior, not the workflow that found it.

## Ordered Lookup

If a proposal replaces `sorted(...).filter(...).findFirst()`, reject it and explicitly recommend:
"Keep the existing `sorted(...).filter(...).findFirst()` chain." This must be a direct recommendation,
not only an implied conclusion. Also state the concrete ordering contract. For ascending numeric
priority, say the lowest priority number/value wins; do not say "highest-priority" unless the code
uses an explicit reversed comparator. Do not call the sort no-op and do not suggest `findAny`, `min`,
`max`, or collectors unless the task asks for optimization advice.

If that proposal also uses `parallelStream().filter(...).findAny()`, make the parallelism point a
separate sentence: `parallelStream()` is unjustified without CPU-bound work or measurements and adds
split/merge/order overhead for this lookup.

If the ordered source is a loop over configured order, recommend keeping the loop or using
`contacts.stream().filter(...).findFirst()`; do not mention a sorted chain.

## `findFirst` And `findAny`

`findAny()` is valid only when the domain declares all matching values equivalent and order
irrelevant. Do not infer this from names like `primary`, `default`, or `preferred`, or from
parallelism. State this semantic exception before performance or nondeterminism.

For primary-address examples, use:
"`findAny()` is appropriate only when all matching primary addresses are considered equivalent and
encounter order does not matter."

When asked whether to keep collecting, use `findFirst`, or use `findAny`, include that collecting
all matches is unnecessary, `findFirst()` preserves existing `get(0)` encounter order, and
`findAny()` needs domain-guaranteed equivalence.

## Java Version

When rejecting `Stream.toList()` on Java 11 or lower, state the baseline incompatibility as its own
problem: "`Stream.toList()` was added in Java 16, so it is unavailable on Java 11." Then separately
state any mutability problem if later code calls `add`, `sort`, or otherwise mutates the result.

## Performance And Parallelism

Include benchmarking, small/mostly-small slowdown, and relevant common-pool, blocking, or ordering
risk. For high-volume uppercase/list-transform reviews, say `parallelStream()` can be slower for
small lists or call paths where most invocations are small, so benchmark the real workload before
using it for throughput.

## Nullable Collectors

If the original loop skipped null keys, say the proposed collector changes behavior by retaining or
colliding on null keys unless filtered first. Do not claim a single null key always throws; the
required fix is preserving the skip-null contract before collecting.

## Remote Calls

For `mapConcurrent` snippets, preserve approved-only sorted output and call the existing helper.
