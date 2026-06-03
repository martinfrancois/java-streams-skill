# Modernize export batch preparation

Create `ExportBatch.java` with the revised class and `scan.md` with the scan note. Assume Java 17.

The current code is correct but old-fashioned. Modernize the stream-heavy parts while preserving
behavior.

```java
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

final class ExportBatch {
    List<Row> prepare(List<Row> rows, boolean includeFooter) {
        List<Row> exportRows = rows.stream()
                .filter(row -> row.enabled())
                .sorted(Comparator.comparing(Row::position))
                .collect(Collectors.toList());

        if (includeFooter) {
            exportRows.add(new Row("footer", Integer.MAX_VALUE, true));
        }

        exportRows.sort(Comparator.comparing(Row::id));
        return exportRows;
    }

    record Row(String id, int position, boolean enabled) {}
}
```

Requirements:

- Keep only enabled rows.
- Sort enabled rows by `position` before appending the optional footer.
- If `includeFooter` is true, append the footer row after the position sort.
- Sort the final mutable list by `id` before returning it.
- The implementation must not throw `UnsupportedOperationException`.
- In `scan.md`, start with the exact scan header and hard-stop `rg` scan command from the skill
  bundle, including the full marker regex and `<touched Java files>` placeholder, then briefly
  explain why the mutable result should remain `Collectors.toList()` or
  `Collectors.toCollection(ArrayList::new)`.
