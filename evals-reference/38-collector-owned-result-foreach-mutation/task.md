# Replace misleading stream mutation

Refactor `WritableRoots.java` where stream pipelines should own returned results. Assume Java 17.

Return the revised Java code only.

```java
import java.io.File;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

final class WritableRoots {
    List<Path> additionalWritableRoots(Path workflowDirectory, Map<String, Object> codex) {
        List<Path> roots = new ArrayList<>();
        list(codex, "additional_writable_roots", List.of()).stream()
                .map(value -> workflowDirectory.resolve(value))
                .forEach(roots::add);
        environmentValue("ADDITIONAL_WRITABLE_ROOTS").stream()
                .flatMap(value -> Arrays.stream(value.split(java.util.regex.Pattern.quote(File.pathSeparator))))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(workflowDirectory::resolve)
                .forEach(roots::add);
        return roots.stream().distinct().toList();
    }

    Map<String, Integer> runningCountsByState(List<String> normalizedStates) {
        Map<String, Integer> counts = new HashMap<>();
        normalizedStates.stream().forEach(state -> counts.merge(state, 1, Integer::sum));
        return counts;
    }

    private static List<String> list(Map<String, Object> map, String key, List<String> defaultValue) {
        Object value = map.get(key);
        return value instanceof List<?> values ? values.stream().map(Object::toString).toList() : defaultValue;
    }

    private static Optional<String> environmentValue(String name) {
        return Optional.empty();
    }
}
```

Preserve configured-root precedence over environment roots, first-occurrence duplicate removal, and
mutable `HashMap` result behavior.
