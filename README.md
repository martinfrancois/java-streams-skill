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

## Contents

- [Getting Started](#getting-started)
- [Why This Exists](#why-this-exists)
- [Common Stream Mistakes](#common-stream-mistakes)
- [What It Helps With](#what-it-helps-with)
- [How It's Evaluated](#how-its-evaluated)
- [Origin](#origin)
- [Contributing](#contributing)
- [License](#license)

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
Use $java-streams to clean up this Java stream chain without changing behavior.
```

For reviews:

```text
Use $java-streams to review this Java stream code and suggest any fixes.
```

## Why This Exists

AI can write Java code that looks modern because it uses streams. If you do not know streams very
well, that code can look plausible in review. But looking plausible is not enough: the code can
still use the wrong kind of concurrency, build lists it does not need, use `null` as a hidden signal,
fail when keys are duplicated, or choose a terminal operation that does not match the real intent.

This skill helps the agent write stream code that is easier to read, safer to change, and often more
efficient. It pushes the agent toward the stream operation that matches the job, such as `anyMatch`
instead of collecting a list just to check if a match exists. It also helps the agent review existing
stream code and explain what should be fixed.

For example, imagine code that checks a user's favorite products against a remote inventory API.
That API call blocks while it waits for the remote service. The code should:

- check products in the user's favorite order;
- run at most 8 stock checks at the same time;
- keep only products that are in stock;
- sort the final result by product name.

Without the skill, the generated code used two different approaches. Both looked reasonable at
first, but both had important problems.

### Version 1: `parallelStream()`

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

This keeps the basic filter and sort behavior, but it is still not a good solution:

- `parallelStream()` uses Java's common fork-join pool. The
  [`ForkJoinPool` Javadoc](https://docs.oracle.com/en/java/javase/24/docs/api/java.base/java/util/concurrent/ForkJoinPool.html)
  says blocked I/O is not guaranteed to be compensated for, so that pool is a poor default for
  remote API calls.
- In this example, the limit is per call to `favoriteProducts(user)`. The static semaphore is shared
  by every call to the method, so two users calling it at the same time can block each other even
  though each call is allowed to run up to 8 stock checks.
- The concurrency limit is separate from the stream chain, which makes the code harder to reason
  about.

### Version 2: Virtual Threads And A Semaphore

```java
List<Product> favoriteProducts(User user) {
    try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
        var permits = new Semaphore(8);

        return user.favoriteProducts().stream()
                .map(product -> executor.submit(() -> {
                    permits.acquire();
                    try {
                        return InventoryApi.check(product.sku()) ? product : null;
                    } finally {
                        permits.release();
                    }
                }))
                .map(FavoriteProducts::getUnchecked)
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(Product::name))
                .toList();
    }
}

private static Product getUnchecked(Future<Product> future) {
    try {
        return future.get();
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new RuntimeException(e);
    } catch (ExecutionException e) {
        throw new RuntimeException(e.getCause());
    }
}
```

This avoids `parallelStream()`, and it limits how many checks are active at once. But it still has
problems:

- It submits one task for every product before it starts collecting results. With a large list, that
  can create a large backlog of queued tasks even though only 8 checks run at once.
- It uses `null` as a hidden signal for "not in stock." A reader has to remember that special
  meaning until the later `filter(Objects::nonNull)`. If someone changes the stream chain before
  that filter, the code can easily break.

### With The Skill: `Gatherers.mapConcurrent`

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

This version is clearer:

- It keeps the limit of 8 checks inside the stream chain.
- It uses bounded concurrency with backpressure: keep only a limited amount of work in flight, then
  start more work as earlier checks finish.
- It keeps each product together with its stock-check result.
- It filters and sorts in a clear order.

## Common Stream Mistakes

The skill also helps with mistakes such as:

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

The goal is not to turn every loop into a stream. The goal is to use streams and collectors when
they make the code clearer, safer, or easier to check.

## What It Helps With

Good fit:

- replacing collect-then-inspect, count-for-existence, or sort-then-first patterns;
- choosing `findFirst()` or `findAny()` without changing ordering semantics;
- using `flatMap` for nested collections and `Optional::stream` for `Stream<Optional<T>>`;
- using `Collectors.joining`, `groupingBy`, `mapping`, `counting`, `summingInt` /
  `summingLong` / `summingDouble`, `summarizingInt` / `summarizingLong` /
  `summarizingDouble`, `partitioningBy`, `toMap`, and `teeing` correctly;
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

The skill is tested on Java stream implementation, review, and cleanup tasks. Each task is run
without the skill and with the skill, then scored mainly on stream-specific quality, with compile and
behavior checks included as safety checks.

The evals check that agents:

- produce coherent Java for the stated Java version;
- preserve outputs, ordering, null handling, duplicate-key behavior, and error behavior;
- choose direct terminal operations such as `anyMatch`, `findFirst`, `min`, `max`, and primitive
  `sum` instead of doing extra work first;
- use collectors such as `joining`, `groupingBy`, `toMap`, `teeing`, and `partitioningBy` with the
  right null and duplicate-key behavior;
- keep `findFirst()` when order or priority matters, and use `findAny()` only when matches are
  equivalent;
- avoid casual `parallelStream()` changes for blocking calls or shared mutable state;
- use bounded concurrent stream work for remote checks when the Java version supports it;
- respect Java-version differences such as `Optional::stream`, `takeWhile`, `mapMulti`,
  `Stream.toList()`, gatherers, and `Collectors.teeing`.

Compile and behavior checks make regressions visible in the score, but the headline score is
intentionally weighted toward stream quality: whether the agent keeps the same behavior while
choosing the stream operation that best matches the job.

Results should be read by subset:

- natural activation scenarios do not name the skill;
- explicit invocation scenarios directly ask for `$java-streams`;
- stream-quality subtotal shows the skill-specific effect;
- the focused headline suite reports the representative mix;
- `evals-reference/` keeps broader regression cases, including scenarios a strong baseline may
  already solve.

## Origin

The stream examples and pattern catalog are based on the code examples from François Martin's conference
talk ["I didn't know you could do that with Java Streams"](https://fmartin.ch/session/i-didnt-know-you-could-do-that-with-java-streams),
with the public example source here:
<https://github.com/martinfrancois/jfokus-2026/blob/main/code.md>.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local validation, eval design rules, commit-message
format, and release workflow details.

AI-assisted contributions are welcome when they are transparent, reviewed, and owned by a human. See
[AI_CONTRIBUTION_POLICY.md](AI_CONTRIBUTION_POLICY.md).

For suspected vulnerabilities, use the private reporting path in [SECURITY.md](SECURITY.md).

## License

MIT. See [LICENSE](LICENSE).
