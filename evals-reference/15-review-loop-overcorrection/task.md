# Review proposed lookup rewrite

Assume Java 17.

Use `$java-optionals` to review this proposed rewrite. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.Optional;
import java.util.Set;

final class CommandOptionMatcher {
    private static final Set<String> REDACTED_VALUE_OPTIONS = Set.of(
            "--token", "--key", "--workflow", "--config-dir", "--state-home", "--output");

    static Optional<String> redactedCommandValueOption(String arg) {
        return REDACTED_VALUE_OPTIONS.stream()
                .filter(option -> arg.equals(option) || arg.startsWith(option + "="))
                .findAny();
    }
}
```

Proposed:

```java
import java.util.Optional;
import java.util.Set;

final class CommandOptionMatcher {
    private static final Set<String> REDACTED_VALUE_OPTIONS = Set.of(
            "--token", "--key", "--workflow", "--config-dir", "--state-home", "--output");

    static Optional<String> redactedCommandValueOption(String arg) {
        for (String option : REDACTED_VALUE_OPTIONS) {
            if (arg.equals(option) || arg.startsWith(option + "=")) {
                return Optional.of(option);
            }
        }
        return Optional.empty();
    }
}
```
