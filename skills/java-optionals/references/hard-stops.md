# Java Optional hard stops

Use this reference before finalizing a Java Optional cleanup or first-pass implementation when the
code touches value reads, fallbacks, checked IO, prompts, or stream/collection boundaries.

## Replacement antipatterns

Fix these before finalizing:

- `isPresent()` or `isEmpty()` followed by `get()`, `getAsInt()`, `getAsLong()`, `getAsDouble()`, or
  `orElseThrow()` for ordinary value flow.
- `isEmpty()` followed later by `orElseThrow()` just to read the present value after absence was
  already handled.
- `orElse(null)` followed by local null branching, except at a real legacy null-based API boundary.
- One Optional turned into a collection or iterable just to avoid a value read:
  `optional.stream().toList()`, `optional.stream()::iterator`, `optionalValues(optional)`,
  `presentValues(optional)`, or a `for` loop over one Optional.
- Generic checked-Optional helpers whose main job is to hide checked exceptions inside Optional
  chains, such as `OptionalSupport`, `OptionalIo`, `CheckedOptionals`, `OptionalBoundaries`,
  throwing suppliers/functions, `mapThrowing(...)`, `orElseGetThrowing(...)`, or supplier `.get()`
  tricks.

## Checked boundaries

If checked IO, prompting, or a checked parser blocks a fluent Optional chain:

1. Reduce every non-checked Optional branch first.
2. Keep only the branch that actually performs checked IO, prompting, or checked parsing.
3. If Java's checked-exception rules force an explicit branch, prefer an empty guard:

   ```java
   // Java 11+
   if (value.isEmpty()) {
       return readCheckedFallback();
   }
   return value.get();
   ```

   ```java
   // Java 8
   if (!value.isPresent()) {
       return readCheckedFallback();
   }
   return value.get();
   ```

   This keeps the checked branch local and avoids the weaker shape:

   ```java
   if (value.isPresent()) {
       return value.orElseThrow();
   }
   return readCheckedFallback();
   ```

   Keep the present read local and read the value once.
   Apply the same rule to checked parsers:

   ```java
   // Java 11+
   if (text.isEmpty()) {
       return Optional.empty();
   }
   return Optional.of(parser.readValue(text.get()));
   ```

   ```java
   // Java 8
   if (!text.isPresent()) {
       return Optional.empty();
   }
   return Optional.of(parser.readValue(text.get()));
   ```
4. Do not replace the branch with a generic helper, fake iterable, or `orElse(null)` workaround.

Named helpers are fine when they name domain work, such as `validateRequestedPort(...)` or
`promptForWorkspace(...)`. They are not fine when they are generic `<T>` helpers that exist only to
unwrap `Optional<T>` or route checked exceptions through Optional.

## Scan command

Run a hard-stop scan over touched Java files before finalizing:

```bash
rg -n "orElse\\(null\\)|getAsInt\\(\\)|getAsLong\\(\\)|getAsDouble\\(\\)|stream\\(\\)\\.toList\\(\\)|stream\\(\\)::iterator|optionalValues|presentValues|OptionalSupport|OptionalValues|OptionalIo|CheckedOptionals|OptionalBoundaries|UncheckedIOException|ThrowingSupplier|ThrowingFunction|mapThrowing|orElseGetThrowing" <touched Java files>
```

For each hit, decide whether it is part of Optional value flow, fake Optional iteration, fallback
handling, stream flattening, or checked-exception tunneling. Fix those hits. If a marker remains
because it is legitimate and outside the Optional issue, state why.
