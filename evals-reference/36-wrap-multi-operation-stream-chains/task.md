# Format stream chains

Format `StreamFormattingSample.java` for readability without changing behavior. Assume Java 17.

Return the revised Java code only.

```java
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

final class StreamFormattingSample {
    Set<String> normalizedLabels(Card card) {
        return card.labels().stream().map(StreamFormattingSample::normalize).collect(Collectors.toSet());
    }

    String firstLabel(Card card) {
        return card.labels().stream().findFirst().orElse("none");
    }

    void addCardFields(Card card, java.util.Map<String, Object> values) {
        values.put("checklists", card.checklists().stream().map(Checklist::asMap).toList());
        values.put("attachments", card.attachments().stream().map(Attachment::asMap).toList());
    }

    private static String normalize(String value) {
        return value.toLowerCase(java.util.Locale.ROOT).strip();
    }

    record Card(List<String> labels, List<Checklist> checklists, List<Attachment> attachments) {}
    record Checklist(String name) {
        java.util.Map<String, Object> asMap() {
            return java.util.Map.of("name", name);
        }
    }
    record Attachment(String name) {
        java.util.Map<String, Object> asMap() {
            return java.util.Map.of("name", name);
        }
    }
}
```

Keep `.stream()` on the source line. One-operation chains may stay on one line when readable.
