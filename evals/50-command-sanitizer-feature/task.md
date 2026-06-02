# Extend command sanitization

Create `CommandSanitizer.java` with the revised class. Assume Java 17.

Current code:

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

final class CommandSanitizer {
    private static final Set<String> SECRET_OPTIONS = Set.of("--token", "--key", "--workflow", "--config-dir", "--state-home", "--output");

    String sanitize(List<String> args) {
        List<String> sanitized = new ArrayList<>();
        boolean redactNext = false;
        for (String arg : args) {
            if (redactNext) {
                sanitized.add("<redacted>");
                redactNext = false;
                continue;
            }
            Optional<String> option = SECRET_OPTIONS.stream()
                    .filter(secret -> arg.equals(secret))
                    .findFirst();
            if (option.isPresent()) {
                sanitized.add(option.orElseThrow());
                redactNext = true;
            } else {
                sanitized.add(arg);
            }
        }
        return String.join(" ", sanitized);
    }
}
```

Required changes:

- Preserve exact-option behavior: `--token abc` becomes `--token <redacted>`.
- Add `option=value` behavior: `--key=abc` becomes `--key=<redacted>`.
- Preserve non-secret arguments.
- Keep the real option-set lookup readable and centralized.
- Return `String.join(" ", sanitized)`.
