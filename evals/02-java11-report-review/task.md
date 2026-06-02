# Review Java 11 report refactor

Use `$java-streams` to review this proposed change. Create `review.md` with a short decision and a
corrected stream shape if the change should not be accepted.

Assume Java 11.

Before:

```java
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

final class ReportRows {
    List<Row> build(List<Row> rows, boolean includeSummary) {
        List<Row> out = rows.stream()
                .filter(Row::visible)
                .sorted(Comparator.comparing(Row::rank))
                .collect(Collectors.toList());
        if (includeSummary) {
            out.add(new Row("summary", Integer.MAX_VALUE, true));
        }
        out.sort(Comparator.comparing(Row::id));
        return out;
    }

    record Row(String id, int rank, boolean visible) {}
}
```

Proposed:

```java
import java.util.Comparator;
import java.util.List;

final class ReportRows {
    List<Row> build(List<Row> rows, boolean includeSummary) {
        List<Row> out = rows.stream()
                .filter(Row::visible)
                .sorted(Comparator.comparing(Row::rank))
                .toList();
        if (includeSummary) {
            out.add(new Row("summary", Integer.MAX_VALUE, true));
        }
        out.sort(Comparator.comparing(Row::id));
        return out;
    }

    record Row(String id, int rank, boolean visible) {}
}
```
