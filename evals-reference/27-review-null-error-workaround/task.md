# Review proposed null error workaround

Assume Java 17.

Use `$java-optionals` to review this proposed cleanup. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.Map;
import java.util.Optional;

final class ConfigLookup {
    String required(Map<String, String> values, String key) {
        return Optional.ofNullable(values.get(key))
                .orElseThrow(() -> new IllegalArgumentException("Missing config: " + key));
    }
}
```

Proposed:

```java
import java.util.Map;
import java.util.Optional;

final class ConfigLookup {
    String required(Map<String, String> values, String key) {
        String value = Optional.ofNullable(values.get(key)).orElse(null);
        if (value == null) {
            throw new IllegalArgumentException("Missing config: " + key);
        }
        return value;
    }
}
```

