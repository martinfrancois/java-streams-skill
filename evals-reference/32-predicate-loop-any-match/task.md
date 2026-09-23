# Clean up predicate-only loops

Refactor `ManifestChecks.java` where a stream terminal makes the intent clearer. Assume Java 17.

Return the revised Java code only.

```java
import com.fasterxml.jackson.databind.JsonNode;
import java.util.List;

final class ManifestChecks {
    static boolean hasNonObjectBoardRow(JsonNode root) {
        JsonNode boards = root.path("boards");
        for (JsonNode board : boards) {
            if (!board.isObject()) {
                return true;
            }
        }
        return false;
    }

    static void requireWritableRoots(JsonNode board, String label, List<String> warnings) {
        JsonNode roots = board.get("additionalWritableRoots");
        if (roots == null) {
            return;
        }
        if (!roots.isArray()) {
            warnings.add("Entry " + label + " field additionalWritableRoots must be an array.");
            return;
        }
        for (JsonNode root : roots) {
            if (!root.isTextual() || root.asText().isBlank()) {
                warnings.add("Entry " + label + " field additionalWritableRoots must contain non-blank strings.");
                return;
            }
        }
    }

    static void writeRows(List<String> rows, JsonNode boards) {
        int index = 0;
        for (JsonNode board : boards) {
            rows.add(index + ":" + board.path("name").asText());
            index++;
        }
    }
}
```

Preserve warning text, short-circuit behavior, and index-sensitive row output.
