# Java Optional Examples

Use these examples for non-trivial Optional refactors. They are reusable runtime guidance, not
scenario answers.
Some examples use modern Java features such as records, `Set.of`, `List.of`, `Optional.stream()`,
`Stream.toList()`, or `ifPresentOrElse()` for brevity. Check the project Java baseline before using
those APIs; see [java-optional-api.md](java-optional-api.md).

## Table Of Contents

- [Observed Production Failure Patterns](#observed-production-failure-patterns)
- [Iteration Histories](#iteration-histories)

## Observed Production Failure Patterns

The skill guards against patterns agents have actually written or preserved in production Java code:

- `existing.isPresent()` followed by `existing.get()` in an update-or-create flow. The final shape
  used `findFirst().map(...).orElseGet(...)` with named update/create helpers so the create branch
  stayed lazy.
- `target.isEmpty()` followed by repeated `target.get()` reads after a successful guard. The final
  shape bound the selected value once before using it.
- `options.workspaceId().isPresent()` followed by `options.workspaceId().orElseThrow()` before a
  prompting fallback. The final shape kept a narrow explicit branch because the fallback performs
  checked IO.
- `frontMatter.isEmpty()` followed by multiple `frontMatter.get()` reads. The final shape moved the
  map access into a helper or Optional boundary so the value wasn't repeatedly reopened.
- `optional.orElse(null)` in mixed contexts. Some instances were acceptable nullable interop with an
  existing record or API boundary; others invited local null-control-flow branching.
- A real collection stream ending in an Optional result was first handled with
  `isPresent()`/`orElseThrow()`, then overcorrected into a loop. The final shape kept the readable
  collection stream and handled the Optional result directly.
- A real stream mapped each payload to `Optional<Card>` and then used
  `filter(Optional::isPresent).map(Optional::get)`. The final shape used
  `flatMap(Optional::stream)`. This is the good use of `Optional::stream`, unlike making one
  Optional into a fake list.
- `OptionalInt` values were guarded with `isPresent()` and then reopened with `getAsInt()`. The
  final shape used `ifPresent(...)` for the side-effecting map update.
- `Optional<Boolean>` mode flags were used as three-state settings: explicit `false`, explicit
  `true`, and absent all had different behavior. The final shape avoided reading the value with
  `orElseThrow()` and didn't collapse absent to `false`.
- Predicate-only Optional checks used `isPresent()` plus `orElseThrow()` only to compare the value.
  The final shape used `filter(...).isPresent()` because no value needed to be returned.

## Iteration Histories

### 1. Upsert Should Use Optional As The Decision Boundary

Starting point:

```java
import java.util.List;
import java.util.Optional;

final class WorkpadService {
    Result upsertWorkpad(Card card, String text) {
        Optional<Comment> existing = card.comments().stream()
                .filter(this::isWorkpadComment)
                .findFirst();

        if (existing.isPresent()) {
            Comment workpad = existing.get();
            if (workpad.id() == null || workpad.id().isBlank()) {
                return Result.failure("missing_action_id");
            }
            return updateExistingWorkpad(workpad, text);
        }

        if (card.comments().size() >= 1000) {
            return Result.failure("comment_window_incomplete");
        }
        return createWorkpad(card, text);
    }

    boolean isWorkpadComment(Comment comment) {
        return comment.text() != null && comment.text().startsWith("<!-- workpad -->");
    }

    Result updateExistingWorkpad(Comment workpad, String text) { return Result.success("updated"); }
    Result createWorkpad(Card card, String text) { return Result.success("created"); }

    record Card(List<Comment> comments) {}
    record Comment(String id, String text) {}
    record Result(boolean ok, String status) {
        static Result success(String status) { return new Result(true, status); }
        static Result failure(String status) { return new Result(false, status); }
    }
}
```

Bad attempted fix:

```java
Comment workpad = card.comments().stream()
        .filter(this::isWorkpadComment)
        .findFirst()
        .orElse(null);

if (workpad != null) {
    return updateExistingWorkpad(workpad, text);
}
return createWorkpad(card, text);
```

Better final shape:

```java
Result upsertWorkpad(Card card, String text) {
    return card.comments().stream()
            .filter(this::isWorkpadComment)
            .findFirst()
            .map(workpad -> updateExistingWorkpad(card, workpad, text))
            .orElseGet(() -> createWorkpad(card, text));
}

private Result updateExistingWorkpad(Card card, Comment workpad, String text) {
    if (workpad.id() == null || workpad.id().isBlank()) {
        return Result.failure("missing_action_id");
    }
    return Result.success("updated");
}

private Result createWorkpad(Card card, String text) {
    if (card.comments().size() >= 1000) {
        return Result.failure("comment_window_incomplete");
    }
    return Result.success("created");
}
```

Why good: the Optional remains the update-or-create boundary, and `orElseGet(...)` keeps create
lazy.

### 1a. Optional-Returning APIs Should Use `flatMap`

Bad:

```java
return Optional.ofNullable(response)
        .map(r -> r.headers().firstValue("Retry-After").orElse(null))
        .flatMap(this::parseRetryAfter)
        .orElseGet(this::fallbackDelay);
```

Better:

```java
return Optional.ofNullable(response)
        .flatMap(r -> r.headers().firstValue("Retry-After"))
        .flatMap(this::parseRetryAfter)
        .orElseGet(this::fallbackDelay);
```

Why good: `firstValue` already returns an `Optional<String>`, so `flatMap` keeps absence in the
Optional flow without a temporary `null`.

### 2. Real Collection Stream Shouldn't Become A Labeled Loop

Starting point:

```java
import java.util.Optional;
import java.util.Set;

final class CommandRedactor {
    private static final Set<String> SECRET_OPTIONS = Set.of("--token", "--api-key");

    Optional<String> secretOption(String arg) {
        return SECRET_OPTIONS.stream()
                .filter(option -> arg.equals(option) || arg.startsWith(option + "="))
                .findFirst();
    }
}
```

Bad attempted fix:

```java
arguments:
for (String arg : args) {
    for (String option : SECRET_OPTIONS) {
        if (arg.equals(option)) {
            redactNext = true;
            continue arguments;
        }
        if (arg.startsWith(option + "=")) {
            sanitizedArgs.add(option + "=<redacted>");
            continue arguments;
        }
    }
    sanitizedArgs.add(arg);
}
```

Better final shape:

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

final class CommandRedactor {
    private static final Set<String> SECRET_OPTIONS = Set.of("--token", "--api-key");

    private static Optional<String> secretOption(String arg) {
        return SECRET_OPTIONS.stream()
                .filter(option -> arg.equals(option) || arg.startsWith(option + "="))
                .findAny();
    }

    String sanitizeCommand(List<String> args) {
        List<String> sanitizedArgs = new ArrayList<>();
        boolean redactNext = false;

        for (String arg : args) {
            if (redactNext) {
                sanitizedArgs.add("<redacted>");
                redactNext = false;
            } else {
                Optional<String> option = secretOption(arg);
                sanitizedArgs.add(option
                        .map(match -> arg.equals(match) ? arg : match + "=<redacted>")
                        .orElse(arg));
                redactNext = option.map(arg::equals).orElse(false);
            }
        }

        return String.join(" ", sanitizedArgs);
    }
}
```

Why good: matching is centralized in a real collection stream, `findAny()` is correct because any
match is equivalent, and the remaining loop only tracks real sequence state.

### 2a. Stream Of Optionals Should Flatten Directly

Starting point:

```java
import java.util.List;
import java.util.Map;
import java.util.Optional;

final class ProductFeed {
    List<ProductCard> visibleCards(List<Map<String, Object>> payloads, StoreContext context) {
        return payloads.stream()
                .map(payload -> normalize(payload, context))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .filter(card -> card.active() && !card.discontinued())
                .toList();
    }

    Optional<ProductCard> normalize(Map<String, Object> payload, StoreContext context) {
        return Optional.empty();
    }

    record StoreContext(List<String> activeCategoryIds) {}
    record ProductCard(String id, boolean active, boolean discontinued) {}
}
```

Better final shape:

```java
List<ProductCard> visibleCards(List<Map<String, Object>> payloads, StoreContext context) {
    return payloads.stream()
            .map(payload -> normalize(payload, context))
            .flatMap(Optional::stream)
            .filter(card -> card.active() && !card.discontinued())
            .toList();
}
```

Why good: `payloads` is a real collection, and each element may or may not normalize to a card.
`flatMap(Optional::stream)` is the standard flattening boundary for that shape. Don't confuse this
with `oneOptional.stream().toList()`, which creates a fake collection around a single value.

### 2b. Primitive Optionals Should Use Their Terminals

Starting point:

```java
import java.util.Map;
import java.util.OptionalInt;

final class PriorityLabels {
    void apply(Map<String, Integer> values, String key, Object rawValue) {
        OptionalInt priority = positiveInteger(rawValue);
        if (priority.isPresent()) {
            values.put(normalize(key), priority.getAsInt());
        }
    }

    OptionalInt positiveInteger(Object value) { return OptionalInt.empty(); }
    String normalize(String value) { return value.trim().toLowerCase(); }
}
```

Better final shape:

```java
void apply(Map<String, Integer> values, String key, Object rawValue) {
    positiveInteger(rawValue).ifPresent(priority -> values.put(normalize(key), priority));
}
```

Why good: `OptionalInt` has its own terminal operations. Use those instead of reopening the value
with `getAsInt()` after a presence guard.

### 2c. Optional Boolean Mode Flags May Have Three States

Starting point:

```java
import java.io.IOException;
import java.util.Optional;

final class GiftWrapConfigurator {
    GiftWrapIntegration resolve(Options options, Prerequisites prerequisites, Terminal terminal)
            throws IOException {
        if (options.giftWrapMode().isPresent()) {
            boolean enabled = options.giftWrapMode().orElseThrow();
            if (!enabled) {
                terminal.info("Gift wrap skipped");
                return GiftWrapIntegration.DISABLED;
            }
            if (options.nonInteractive() && !prerequisites.giftWrapServiceAvailable()) {
                throw new IllegalStateException("Gift wrap service is required");
            }
            return GiftWrapIntegration.ENABLED;
        }
        if (prerequisites.accountAlreadyConfigured()) {
            return GiftWrapIntegration.ENABLED;
        }
        if (options.nonInteractive()) {
            return GiftWrapIntegration.DISABLED;
        }
        return terminal.confirm("Enable gift wrap? ")
                ? GiftWrapIntegration.ENABLED
                : GiftWrapIntegration.DISABLED;
    }

    interface Options { Optional<Boolean> giftWrapMode(); boolean nonInteractive(); }
    interface Prerequisites { boolean giftWrapServiceAvailable(); boolean accountAlreadyConfigured(); }
    interface Terminal { void info(String message); boolean confirm(String prompt) throws IOException; }
    enum GiftWrapIntegration { ENABLED, DISABLED }
}
```

Better final shape:

```java
GiftWrapIntegration resolve(Options options, Prerequisites prerequisites, Terminal terminal)
        throws IOException {
    Optional<Boolean> mode = options.giftWrapMode();
    if (mode.filter(enabled -> !enabled).isPresent()) {
        terminal.info("Gift wrap skipped");
        return GiftWrapIntegration.DISABLED;
    }
    if (mode.filter(Boolean::booleanValue).isPresent()) {
        if (options.nonInteractive() && !prerequisites.giftWrapServiceAvailable()) {
            throw new IllegalStateException("Gift wrap service is required");
        }
        return GiftWrapIntegration.ENABLED;
    }
    if (prerequisites.accountAlreadyConfigured()) {
        return GiftWrapIntegration.ENABLED;
    }
    if (options.nonInteractive()) {
        return GiftWrapIntegration.DISABLED;
    }
    return terminal.confirm("Enable gift wrap? ")
            ? GiftWrapIntegration.ENABLED
            : GiftWrapIntegration.DISABLED;
}
```

Why good: `Optional.empty()` isn't the same as `Optional.of(false)` here. Empty means continue to
auto-detect or prompt. Don't use `orElse(false)` before that fallback logic.

### 2d. Predicate-Only Checks Shouldn't Open The Optional

Starting point:

```java
import java.util.Optional;

final class CustomerSessionCheck {
    boolean belongsToCustomer(Optional<String> sessionCustomerId, String expectedCustomerId) {
        if (sessionCustomerId.isPresent() && sessionCustomerId.orElseThrow().equals(expectedCustomerId)) {
            return true;
        }
        return false;
    }
}
```

Better final shape:

```java
boolean belongsToCustomer(Optional<String> sessionCustomerId, String expectedCustomerId) {
    return sessionCustomerId.filter(id -> id.equals(expectedCustomerId)).isPresent();
}
```

Also acceptable:

```java
boolean belongsToCustomer(Optional<String> sessionCustomerId, String expectedCustomerId) {
    return sessionCustomerId.map(id -> id.equals(expectedCustomerId)).orElse(false);
}
```

Why good: the code only needs a boolean answer. It doesn't need to read the optional value into a
local variable or throw when the value is absent.

### 3. Checked Prompting Fallback Should Use Plain Branching

Starting point:

```java
import java.io.IOException;
import java.util.Optional;

final class WorkspaceSelector {
    String workspaceId(Options options, Terminal terminal) throws IOException {
        Optional<String> configured = options.workspaceId();
        if (configured.isPresent()) {
            return configured.get();
        }
        return promptForWorkspace(terminal);
    }

    String promptForWorkspace(Terminal terminal) throws IOException {
        return terminal.readLine("Workspace: ");
    }

    interface Options { Optional<String> workspaceId(); }
    interface Terminal { String readLine(String prompt) throws IOException; }
}
```

Rejected helper approach:

```java
return CheckedOptionals.mapOrElseGet(
        options.workspaceId(),
        id -> id,
        () -> promptForWorkspace(terminal));
```

Don't replace `CheckedOptionals` with the same idea under another name such as `OptionalSupport`,
`OptionalIo`, `OptionalBoundaries`, `mapThrowing(...)`, `orElseGetThrowing(...)`, or a
throwing-supplier utility. The problem is the abstraction, not the name.

Rejected helper internals:

```java
import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.Optional;
import java.util.function.Function;

final class CheckedOptionals {
    static <T, R> R mapOrElseGet(Optional<T> value, Function<T, R> present, CheckedSupplier<R> absent)
            throws IOException {
        try {
            return value.map(present).orElseGet(() -> unchecked(absent));
        } catch (UncheckedIOException e) {
            throw e.getCause();
        }
    }

    private static <R> R unchecked(CheckedSupplier<R> supplier) {
        try {
            return supplier.get();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    @FunctionalInterface
    interface CheckedSupplier<T> {
        T get() throws IOException;
    }
}
```

Better final shape:

```java
import java.io.IOException;
import java.util.Optional;

final class WorkspaceSelector {
    String workspaceId(Options options, Terminal terminal) throws IOException {
        Optional<String> configured = options.workspaceId();
        if (!configured.isPresent()) {
            // Empty branch performs checked IO, so the branch is intentional.
            return promptForWorkspace(terminal);
        }
        return configured.orElseThrow(() -> new IllegalStateException("workspace id disappeared"));
    }

    String promptForWorkspace(Terminal terminal) throws IOException {
        return terminal.readLine("Workspace: ");
    }

    interface Options { Optional<String> workspaceId(); }
    interface Terminal { String readLine(String prompt) throws IOException; }
}
```

Why good: the checked exception remains visible, and the branch is a narrow checked-IO boundary.
This example uses Java 8-compatible syntax. On Java 11+, `configured.isEmpty()` is also available;
on Java 10+, no-arg `orElseThrow()` is a clearer value read than `get()` when absence would be a
logic error after the branch.

If there are multiple non-IO Optional sources before the checked prompt, don't add one presence
branch per source. Select the value first, then keep the plain branch at the prompt boundary:

```java
Optional<String> selected = options.workspaceId()
        .map(Optional::of)
        .orElseGet(options::environmentWorkspaceId);

if (selected.isPresent()) {
    return selected.orElseThrow(() -> new IllegalStateException("workspace id disappeared"));
}
return promptForWorkspace(terminal);
```

On Java 9+, `options.workspaceId().or(options::environmentWorkspaceId)` is the direct Optional
fallback API for the first line.

If a prompt, checked IO call, or checked parser forces a branch, keep the branch narrow. Do not turn
the Optional into a one-item list or iterable to avoid the branch:

```java
Optional<String> configured = options.workspaceId();
if (configured.isEmpty()) {
    // Empty branch performs checked IO, so the branch is intentional.
    return promptForWorkspace(terminal);
}
return configured.orElseThrow();
```

Why acceptable: the empty branch is the checked prompt boundary. A narrow checked-boundary branch is
clearer than a fake `for` loop over `configured.stream().toList()`. If both branches are ordinary
value flow, prefer `map(...)`, `flatMap(...)`, or `orElseGet(...)` instead.

If the prompt says the final code must remove all presence-read shapes, but the only alternatives
are a generic checked-Optional helper, a fake iterable, or local `orElse(null)` control flow, keep
the narrow checked-boundary branch and say why. Preserving checked exception behavior is more
important than satisfying the wording by creating a different Optional antipattern.

### 4. Selector And Output Optionals Need Different Boundaries

Starting selector code:

```java
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;

final class DiagnosticSelector {
    Selection select(Manifest manifest, Optional<String> board, Optional<Path> workflow, Path configDir) {
        if (board.isPresent() && workflow.isPresent()) {
            throw new IllegalArgumentException("--board and --workflow cannot be used together.");
        }
        if (board.isPresent()) {
            return byBoard(manifest, board.orElseThrow());
        }
        if (workflow.isPresent()) {
            return byWorkflow(manifest, workflow.orElseThrow(), configDir);
        }
        return new Selection("none", manifest.boards(), Optional.empty());
    }

    Selection byBoard(Manifest manifest, String board) { return new Selection("board", List.of(), Optional.empty()); }
    Selection byWorkflow(Manifest manifest, Path workflow, Path configDir) { return new Selection("workflow", List.of(), Optional.of(workflow)); }
    record Manifest(List<String> boards) {}
    record Selection(String kind, List<String> boards, Optional<Path> workflow) {}
}
```

Bad attempted fix:

```java
List<String> boards = board.stream().toList();
if (!boards.isEmpty()) {
    return byBoard(manifest, boards.get(0));
}
```

Also bad:

```java
for (String selector : board.stream().toList()) {
    return byBoard(manifest, selector);
}
```

Also bad for checked or prompting fallbacks:

```java
for (String workspaceId : options.workspaceId().stream().toList()) {
    return workspaceId;
}
return promptForWorkspace(terminal);
```

Still bad under a helper name:

```java
for (String selector : optionalValues(board)) {
    return byBoard(manifest, selector);
}

private static <T> Iterable<T> optionalValues(Optional<T> optional) {
    return optional.stream()::iterator;
}
```

The same helper is still bad under a softer name such as `presentValues(...)`.

Also bad as a generic Optional-unwrapping helper:

```java
private static <T> Iterable<T> presentValues(Optional<T> optional) {
    return optional.stream()::iterator;
}
```

Small helpers are fine when they name domain work:

```java
return options.serverPort()
        .map(port -> validateRequestedPort(port, reservedPorts))
        .orElseGet(() -> nextAvailablePort(reservedPorts));
```

Why good: `validateRequestedPort(...)` and `nextAvailablePort(...)` name the domain behavior. They
do not make `Optional<T>` iterable and do not hide checked exceptions inside a generic Optional
utility.

Before finalizing a cleanup like this, run a hard-stop scan in the touched files:

```bash
rg -n "stream\\(\\)\\.toList\\(\\)|stream\\(\\)::iterator|optionalValues|presentValues|OptionalSupport|OptionalValues|CheckedOptionals|OptionalBoundaries|UncheckedIOException|ThrowingSupplier|ThrowingFunction|mapThrowing|orElseGetThrowing" src/main/java
```

The broader project may have unrelated matches. Any match introduced in the touched cleanup is a
failure unless it is a real collection stream or `Stream<Optional<T>>` flattening pipeline.

Better final shape:

```java
Selection select(Manifest manifest, Optional<String> board, Optional<Path> workflow, Path configDir) {
    if (board.isPresent() && workflow.isPresent()) {
        throw new IllegalArgumentException("--board and --workflow cannot be used together.");
    }
    return board
            .map(selector -> byBoard(manifest, selector))
            .orElseGet(() -> workflow
                    .map(path -> byWorkflow(manifest, path, configDir))
                    .orElseGet(() -> new Selection("none", manifest.boards(), Optional.empty())));
}
```

Why good: the mutual-exclusion check stays a boolean-only presence check, but each value-reading
branch uses the Optional as the selector boundary. The no-selector branch stays lazy, and no fake
collection or null workaround is introduced. If cleanup produces `optional.stream().toList()` around
one Optional, `optional.stream()::iterator`, or an `optionalValues(...)` helper, stop and rewrite it
before finalizing. Do the same for renamed variants such as `presentValues(...)`.

Related output-sink starting code:

```java
import java.nio.file.Path;
import java.util.Optional;

final class ReportCommand {
    void finish(Optional<Path> output, String report) {
        if (output.isPresent()) {
            write(output.orElseThrow(), report);
        } else {
            print(report);
        }
    }

    void write(Path path, String report) {}
    void print(String report) {}
}
```

Better final shape:

```java
void finish(Optional<Path> output, String report) {
    output.ifPresentOrElse(
            path -> write(path, report),
            () -> print(report));
}
```

Why good: the Optional directly chooses between two side-effect branches. If either branch has
checked-exception friction, reconsider whether explicit branching is clearer.
