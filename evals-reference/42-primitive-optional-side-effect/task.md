# Apply positive priority labels

Assume Java 17.

Use `$java-optionals` to improve this Java code without changing behavior. Create
`PriorityLabelConfig.java` with the revised class.

```java
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.OptionalInt;

final class PriorityLabelConfig {
    Map<String, Integer> labels(Map<String, Object> configured) {
        Map<String, Integer> values = new LinkedHashMap<>();
        configured.forEach((key, value) -> {
            OptionalInt priority = positiveInteger(value);
            if (priority.isPresent()) {
                values.put(normalize(key), priority.getAsInt());
            }
        });
        return Map.copyOf(values);
    }

    private static OptionalInt positiveInteger(Object value) {
        try {
            int parsed = value instanceof Number number ? number.intValue() : Integer.parseInt(value.toString());
            return parsed > 0 ? OptionalInt.of(parsed) : OptionalInt.empty();
        } catch (NumberFormatException e) {
            return OptionalInt.empty();
        }
    }

    private static String normalize(String value) {
        return value.trim().toLowerCase();
    }
}
```

Keep ignoring missing, malformed, zero, and negative priorities.
