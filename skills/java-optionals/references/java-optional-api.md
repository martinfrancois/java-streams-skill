# Java Optional-Family API Compatibility

Always infer the project Java baseline before choosing APIs. Check `pom.xml`, Maven compiler
settings, Gradle toolchains, `sourceCompatibility`, `targetCompatibility`, `.github/workflows/*`,
`Dockerfile`, `.sdkmanrc`, `.java-version`, and project docs.

If the baseline is unclear, prefer Java 8-compatible Optional code or state the assumption
explicitly. Don't use newer APIs just because the current JDK supports them.

## Optional Family

| API or feature | Minimum Java | Notes |
| --- | ---: | --- |
| `Optional<T>` | 8 | Value-based class, mainly useful as a return type for possible absence. |
| `Optional.empty()` | 8 | Don't compare to `Optional.empty()` by identity. |
| `Optional.of(T)` | 8 | Rejects `null`. |
| `Optional.ofNullable(T)` | 8 | Boundary conversion from nullable value. |
| `Optional.get()` | 8 | Discouraged for ordinary flow; prefer value-binding operations or `orElseThrow`. |
| `Optional.isPresent()` | 8 | Predicate-only use can be fine; avoid presence-check plus `get()` value reopening. |
| `Optional.ifPresent(Consumer)` | 8 | Side-effect terminal for present values. |
| `Optional.filter(Predicate)` | 8 | Keep only matching present values. |
| `Optional.map(Function)` | 8 | Transform a present value. |
| `Optional.flatMap(Function<T, Optional<U>>)` | 8 | Chain Optional-returning lookups. |
| `Optional.orElse(T)` | 8 | Fallback expression is evaluated before the call; use only when cheap and side-effect free. |
| `Optional.orElseGet(Supplier)` | 8 | Lazy fallback; prefer for non-trivial, stateful, IO, or side-effecting fallback work. |
| `Optional.orElseThrow(Supplier)` | 8 | Absence-as-error with explicit exception supplier. |
| `Optional.ifPresentOrElse(Consumer, Runnable)` | 9 | Present and empty side-effect branches. |
| `Optional.or(Supplier<Optional<T>>)` | 9 | Lazy Optional-to-Optional fallback chain. |
| `Optional.stream()` | 9 | Flatten `Stream<Optional<T>>` with `flatMap(Optional::stream)`. |
| no-arg `Optional.orElseThrow()` | 10 | Throws `NoSuchElementException`; clearer than `get()` when absence should throw. |
| `Optional.isEmpty()` | 11 | Empty predicate; avoid `isEmpty()` plus later value reopening. |
| `OptionalInt`, `OptionalLong`, `OptionalDouble` | 8 | Primitive Optional classes; don't box only to reuse generic Optional examples. |
| primitive `empty`, `of`, `getAsInt`, `getAsLong`, `getAsDouble` | 8 | Prefer safer terminals to `getAs*` for ordinary absence-safe value flow. |
| primitive `isPresent`, `ifPresent` | 8 | Uses primitive consumers. |
| primitive `orElse`, `orElseGet`, `orElseThrow(Supplier)` | 8 | Uses primitive values and suppliers. |
| primitive `ifPresentOrElse` | 9 | Present and empty branches without boxing. |
| primitive `stream()` | 9 | Produces `IntStream`, `LongStream`, or `DoubleStream`. |
| no-arg primitive `orElseThrow()` | 10 | Java 10+. |
| primitive `isEmpty()` | 11 | Java 11+. |

No `OptionalBoolean` exists in the JDK. Use `Optional<Boolean>` only when absence is semantically
different from `false`; don't collapse absent to false unless the domain says to.

Primitive Optional classes aren't drop-in replacements for `Optional<T>`. They don't have the same
`map`, `flatMap`, `filter`, `or`, or `ofNullable` API surface. Use their primitive methods and
streams deliberately.

## Stream And Collector APIs Returning Optional Values

| API or feature | Minimum Java | Notes |
| --- | ---: | --- |
| `Stream.findFirst`, `Stream.findAny` | 8 | Return `Optional<T>`; preserve `findFirst` when encounter order matters. |
| `Stream.min`, `Stream.max`, `Stream.reduce(BinaryOperator)` | 8 | Return `Optional<T>`. |
| `IntStream.findFirst`, `findAny`, `min`, `max`, `reduce(IntBinaryOperator)` | 8 | Return `OptionalInt`. |
| `LongStream.findFirst`, `findAny`, `min`, `max`, `reduce(LongBinaryOperator)` | 8 | Return `OptionalLong`. |
| `DoubleStream.findFirst`, `findAny`, `min`, `max`, `reduce(DoubleBinaryOperator)` | 8 | Return `OptionalDouble`. |
| primitive stream `average()` | 8 | Returns `OptionalDouble`. |
| `Collectors.minBy`, `Collectors.maxBy`, `Collectors.reducing(BinaryOperator)` | 8 | Collectors whose result is `Optional<T>`. |
| `Stream.ofNullable(T)` | 9 | Nullable-to-stream bridge; useful at boundaries, not a replacement for Optional everywhere. |
| `Collectors.flatMapping` | 9 | Can flatten `Optional.stream()` downstream on Java 9+. |

When flattening streams of primitive optionals on Java 9+, use primitive stream bridges:
`flatMapToInt(OptionalInt::stream)`, `flatMapToLong(OptionalLong::stream)`, and
`flatMapToDouble(OptionalDouble::stream)`.

## Adjacent APIs Used In Examples

| API or feature | Minimum Java | Notes |
| --- | ---: | --- |
| `List.of`, `Set.of`, `Map.of` | 9 | Adjacent examples only; not Optional-specific. |
| `List.copyOf`, `Set.copyOf`, `Map.copyOf` | 10 | Adjacent examples only; not Optional-specific. |
| `Stream.mapMulti` and primitive `mapMulti` variants | 16 | Adjacent stream-heavy alternative in some code. |
| `Stream.toList()` | 16 | Returns an unmodifiable list. It isn't a drop-in replacement for `Collectors.toList()` when later code mutates the list. Don't use in Java 8-15 examples. |
| records | 16 | Adjacent examples only. |
| `SequencedCollection`, `List.getFirst()`, `List.getLast()`, `List.reversed()` | 21 | Don't use in generic examples unless Java 21+ is stated. |
| `Stream.gather(Gatherer)` | 24 | Adjacent stream extension point; don't use for Optional cleanup unless the project baseline supports it and it is clearly simpler. |
| `List.ofLazy(int, IntFunction)` | 26 preview | Adjacent only; requires preview features, so don't use in generic examples. |
| Java 24, 25, and 26 Optional-family additions | none found | Checked Java 26 Optional-family Javadocs; no new Optional-family methods were found after Java 11. |

Collection Javadocs also use the phrase "optional operation". That means a collection operation may
throw `UnsupportedOperationException`; it isn't the `java.util.Optional` API this skill teaches.

When using APIs outside this table, or when the project baseline is unclear, inspect the relevant
Javadocs and build files first.
