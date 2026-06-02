# Review proposed checked Optional helper

Assume Java 17.

Use `$java-optionals` to review this proposed helper-based refactor. Create `review.md` with a short
review decision and rationale.

Before:

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

Proposed:

```java
import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.Optional;
import java.util.function.Function;

final class WorkspaceSelector {
    String workspaceId(Options options, Terminal terminal) throws IOException {
        return CheckedOptionals.mapOrElseGet(
                options.workspaceId(),
                id -> id,
                () -> promptForWorkspace(terminal));
    }

    String promptForWorkspace(Terminal terminal) throws IOException {
        return terminal.readLine("Workspace: ");
    }

    interface Options { Optional<String> workspaceId(); }
    interface Terminal { String readLine(String prompt) throws IOException; }
}

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
