# Review command option lookup

Assume Java 17.

Use `$java-optionals` to review this lookup. Create `review.md` with a short review decision and
rationale. Do not modify the Java code.

```java
import java.util.Optional;
import java.util.Set;

final class CommandRedactor {
    private static final Set<String> SECRET_OPTIONS = Set.of("--token", "--api-key");

    Optional<String> secretOption(String arg) {
        return SECRET_OPTIONS.stream()
                .filter(option -> arg.equals(option) || arg.startsWith(option + "="))
                .findAny();
    }
}
```
