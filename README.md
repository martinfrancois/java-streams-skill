# Java Streams Skill for AI Agents

[![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Fmartinfrancois%2Fjava-streams)](https://tessl.io/registry/martinfrancois/java-streams)

AI agents often know Java streams well enough to chain `filter`, `map`, and `collect`, but not
enough to choose the right stream operation for the job in new code, reviews, and cleanup.

They write code that looks modern at first glance, then materializes a list just to check whether
anything matched, sorts a whole stream to get one newest item, counts for existence, uses boxed
numeric reductions, changes `findFirst()` to `findAny()` without noticing the order contract, or
adds `parallelStream()` where it makes the code slower or less predictable.

This skill gives the agent a compact decision guide before it writes or changes stream code: choose
the stream terminal operation that matches the result, preserve ordering and null behavior, pick
collectors by map semantics, use primitive streams for primitive totals, and treat parallel streams
as a design choice rather than a default optimization.

It also tells the agent to check the project Java version first. The right stream code for Java 8
may be different from the right code for Java 17, Java 21, or Java 24.

## Getting Started

### 1. Install

Install the published Tessl plugin using the option that fits your setup:

| Tool | Command |
| --- | --- |
| npm | `npx tessl i martinfrancois/java-streams` |
| yarn | `yarn dlx tessl i martinfrancois/java-streams` |
| pnpm | `pnpx tessl i martinfrancois/java-streams` |
| bun | `bunx tessl i martinfrancois/java-streams` |
| Tessl CLI | `tessl i martinfrancois/java-streams` |

### 2. Use It

Agents that support skill auto-selection, such as
[Codex](https://developers.openai.com/codex/skills) and
[Claude Code](https://code.claude.com/docs/en/skills), can choose this skill automatically from the
task or code context. The task does not need to say `stream` by name.

It can trigger when Java code uses streams, collectors, primitive streams, `findFirst()` /
`findAny()`, match terminal operations, `flatMap`, `mapMulti`, `joining`, `min` / `max`, `sum`,
`groupingBy`, `toMap`, `partitioningBy`, `teeing`, `takeWhile` / `dropWhile`, or parallel stream
behavior.

For important stream-heavy work, you can still name the skill explicitly:

```text
Use $java-streams to implement this Java feature with stream and collector best practices.
```

For cleanup work:

```text
Use $java-streams to clean up this Java stream pipeline without changing behavior.
```

For reviews:

```text
Use $java-streams to review this Java stream code and suggest any fixes.
```

## Why This Exists

The motivation is AI-written Java code that technically uses streams, but misses what streams are
good at expressing. In the favorite-products stock-check eval, the task was to keep user favorites in
preference order for checking, call a blocking remote inventory API, allow at most 8 checks at the
same time, return only in-stock products, and sort the final result by product name.

Unassisted outputs produced shapes like this for the blocking remote call:

```java
private static final Semaphore STOCK_CHECKS = new Semaphore(8);

List<Product> favoriteProducts(User user) {
    return user.favoriteProducts().parallelStream()
            .filter(product -> {
                try {
                    STOCK_CHECKS.acquire();
                    return InventoryApi.check(product.sku());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    throw new RuntimeException(e);
                } finally {
                    STOCK_CHECKS.release();
                }
            })
            .sorted(Comparator.comparing(Product::name))
            .toList();
}
```

This preserves the basic filter-and-sort behavior, but it is a weak stream answer: `parallelStream()`
uses the common fork-join pool, which is not the right default for blocking remote calls, and the
static semaphore is shared state across requests rather than a clear per-operation concurrency limit.
Other unassisted runs avoided `parallelStream()` but still submitted one virtual-thread task per
product up front, blocked those tasks on a semaphore, and returned `null` for out-of-stock products.
That bounds execution, but still creates unbounded fan-out pressure and hides the product/check
association behind a null sentinel.

With the skill, the same task is guided toward the Java 24 stream-native shape:

```java
List<Product> favoriteProducts(User user) {
    return user.favoriteProducts().stream()
            .gather(Gatherers.mapConcurrent(8,
                    product -> Map.entry(product, InventoryApi.check(product.sku()))))
            .filter(Map.Entry::getValue)
            .map(Map.Entry::getKey)
            .sorted(Comparator.comparing(Product::name))
            .toList();
}
```

This keeps the concurrency limit local and explicit, uses the stream API designed for bounded
concurrent per-element work, carries each product with its stock-check result, and keeps the final
filter/map/sort pipeline readable.

Other stream failure modes this skill targets include:

- collecting filtered elements into a list, then checking `isEmpty()` or reading the first item;
- using `count() > 0` instead of `anyMatch(...)`;
- using `sorted(...).findFirst()` instead of `min(...)` or `max(...)`;
- mapping to a list and then calling `String.join(...)` instead of using `Collectors.joining(...)`;
- using boxed `reduce(...)` where a primitive stream terminal operation is clearer;
- building nested sets or lists inside a `map(...)`, then flattening afterward;
- using `toMap(...)` without a merge function when duplicate keys are possible;
- forgetting that natural sorting throws when `null` reaches the comparator;
- making casual `parallelStream()` changes without checking data size, CPU cost, shared state,
  ordering, or blocking IO.

The goal is not to force every loop into a stream. The goal is to use streams and collectors when
they make the operation clearer, safer, or easier to verify.

## What It Helps With

Good fit:

- replacing collect-then-inspect, count-for-existence, or sort-then-first patterns;
- choosing `findFirst()` or `findAny()` without changing ordering semantics;
- using `flatMap` for nested collections and `Optional::stream` for `Stream<Optional<T>>`;
- using `Collectors.joining`, `groupingBy`, `mapping`, `counting`, `summing*`,
  `summarizing*`, `partitioningBy`, `toMap`, and `teeing` correctly;
- selecting primitive streams and primitive stream terminal operations for primitive aggregation;
- avoiding null-sensitive sorting and duplicate-key `toMap` failures;
- deciding whether `parallelStream()` is actually appropriate;
- choosing Java-version-compatible APIs such as `takeWhile`, `mapMulti`, `Stream.toList()`, and
  gatherers.

Poor fit:

- broad Java style enforcement unrelated to streams or collectors;
- replacing straightforward stateful loops with hard-to-read stream tricks;
- large API redesigns or new dependencies without maintainer agreement;
- changing business behavior just to make code look more functional.

## How It's Evaluated

The headline eval suite focuses on stream implementation, review, and cleanup tasks where the
stream-specific context should make the agent better than the same agent without the skill. It
includes natural activation prompts and explicit `Use $java-streams` prompts, with criteria weighted
toward stream quality rather than just artifact creation.

Reference evals cover the rest of the stream pattern catalog from the source material. Those
scenarios are useful for regression and review, but they are not automatically promoted into the
headline benchmark when the baseline model already solves them.

## Origin

The stream examples and pattern catalog are based on the public JFokus 2026 Java streams examples:
<https://github.com/martinfrancois/jfokus-2026/blob/main/code.md>.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local validation, eval design rules, commit-message
format, and release workflow details.

AI-assisted contributions are welcome when they are transparent, reviewed, and owned by a human. See
[AI_CONTRIBUTION_POLICY.md](AI_CONTRIBUTION_POLICY.md).

For suspected vulnerabilities, use the private reporting path in [SECURITY.md](SECURITY.md).

## License

MIT. See [LICENSE](LICENSE).
