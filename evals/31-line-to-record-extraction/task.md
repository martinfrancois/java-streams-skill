# Improve defect extraction from inspection reports

Create `InspectionDefectExtractor.java` with the revised class. Assume Java 21.

The workshop app below pulls defect notes out of vehicle inspection reports. A defect note is any
line in the summary, the findings, or a mechanic remark that starts with a defect label. Is this
the best way to write it in a Java 21 codebase, for both readability and performance? Rewrite the
class to be clearer and faster where you can, using any API available in Java 21, and keep its
behavior.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class InspectionDefectExtractor {
    private static final Pattern DEFECT_LINE = Pattern.compile("(?i)^[\\t ]*(urgent[\\t ]+defect|defect)[\\t ]*:[\\t ]*(.*)$");

    static List<DefectNote> defects(InspectionReport report) {
        List<DefectNote> defects = new ArrayList<>();
        addDefects(defects, report.summary());
        addDefects(defects, report.findings());
        report.remarks().stream().map(MechanicRemark::text).forEach(text -> addDefects(defects, text));
        return List.copyOf(defects);
    }

    private static void addDefects(List<DefectNote> defects, String text) {
        if (text == null || text.isBlank()) {
            return;
        }
        for (String line : text.split("\\R", -1)) {
            Matcher matcher = DEFECT_LINE.matcher(line);
            if (matcher.matches()) {
                defects.add(new DefectNote(matcher.group(2).strip(), severity(matcher.group(1))));
            }
        }
    }

    private static Severity severity(String kind) {
        return kind.toLowerCase(Locale.ROOT).startsWith("urgent") ? Severity.URGENT : Severity.MAJOR;
    }

    enum Severity { URGENT, MAJOR }
    record MechanicRemark(String mechanic, String text) {}
    record InspectionReport(String summary, String findings, List<MechanicRemark> remarks) {}
    record DefectNote(String component, Severity severity) {}
}
```

Rules:

- Search the summary first, then the findings, then each remark in list order, and keep the notes
  in that order.
- The summary, the findings, and any remark text can be `null` or blank; those contribute nothing.
- Report text only ever uses `\n` or `\r\n` line breaks.
- A line counts only when the whole line matches `DEFECT_LINE`.
- `defects` returns an unmodifiable list.
- Keep `DEFECT_LINE`, `severity`, and the nested types unchanged.
