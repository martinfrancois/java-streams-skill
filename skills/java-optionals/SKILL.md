---
name: java-optionals
license: MIT
description: Write, review, and refactor Java Optional code using best practices, improving readability, and preventing common Optional antipatterns such as null-style control flow and readability regressions. Use whenever writing, reviewing, or refactoring Java code that introduces, changes, or reasons about Optional; handles absent, missing, nullable, fallback, or default values where Optional may be appropriate; or touches isPresent/isEmpty, get/orElseThrow, orElse(null), optional.stream(), findFirst/findAny, checked exceptions inside Optional chains, or nullable control flow.
---

# Java Optional Skill

Use this skill before writing Java code that may introduce `Optional`, and when reviewing or
refactoring existing Optional code. Preserve behavior, exception contracts, public output, laziness,
and readability.

## Reference Bundle

| File | Purpose |
|---|---|
| [hard-stops.md](references/hard-stops.md) | Replacement antipatterns and the marker scan to run |
| [optional-examples.md](references/optional-examples.md) | Worked before/after examples |
| [java-optional-api.md](references/java-optional-api.md) | Java-version compatibility for Optional APIs |

## Hard Stops

Before finalizing touched Optional flow, check these quick rules (see
[hard-stops.md](references/hard-stops.md) for the full antipattern list and marker scan):

- No presence check plus value read for ordinary value flow; use value-binding Optional operations.
- No eager fallback computation before checking the Optional; keep non-trivial fallback work lazy.
- No fake one-Optional collection, iterable, loop, local `orElse(null)` branch, or generic helper.
- For checked IO, prompt, or parser branches, use the Step 6 shape and run the final scan.

## Core Workflow

0. Check the Java baseline before choosing APIs. Read build/toolchain docs; if unclear, use Java
   8-compatible code or state the assumption. Don't add Java 9+ Optional APIs, Java 11 `isEmpty()`,
   Java 16 `Stream.toList()`, or Java 21 sequenced collections to older projects.
1. For ordinary value flow, replace guard/read code with one Optional result. Start nullable input
   with `Optional.ofNullable(...)`; don't reopen the value with `get()`.

   ```java
   // avoid
   if (cart.isPresent()) return summarize(cart.get());
   return createSummary(cartId);

   // prefer
   return cart.map(this::summarize).orElseGet(() -> createSummary(cartId));
   ```

2. Match the API to the operation: `map` for transforms, `flatMap` for Optional-returning calls,
   `orElseGet` for non-trivial fallback work, and `orElseThrow` only when absence is an error. Keep
   fallback computation inside the supplier; don't assign or return it before checking the Optional.

   ```java
   return Optional.ofNullable(source)
       .map(Source::rawValue)
       .flatMap(this::parseValue)
       .orElseGet(() -> computeFallback(request));
   ```

3. Keep real streams readable. Preserve `findFirst()` when order matters; use
   `findAny()` only when all matches are equivalent. Flatten `Stream<Optional<T>>` with
   `flatMap(Optional::stream)` on Java 9+.
4. Bind selectors once and keep fallback lazy. Treat `Optional<Boolean>` as three states when
   absence differs from `false`. Predicate-only presence checks are fine when the value isn't read.
   Use `ifPresent` or Java 9+ `ifPresentOrElse` for side-effect boundaries.
5. Keep primitive Optionals primitive. Use `OptionalInt`, `OptionalLong`, or `OptionalDouble`
   directly; don't box or use `isPresent()` plus `getAsInt()`/`getAsLong()`/`getAsDouble()`.
6. Use a plain branch only at a real checked IO, prompt, checked parser, or null-based API boundary.
   Before checked prompts, select any non-IO Optional value first. At the checked branch, use the
   baseline-compatible empty-guard shape:

   ```java
   // Java 11+; use !value.isPresent() on Java 8.
   if (value.isEmpty()) return readCheckedFallback();
   // Checked fallback is handled above; read the present value once.
   return value.get();
   ```

7. Verify each changed branch. Run focused tests or trace present/absent/fallback cases. Confirm
   return values, exceptions, prompts, side effects, laziness, output, and branch order. Run the
   marker scan from [hard-stops.md](references/hard-stops.md); fix relevant hits and re-scan.
