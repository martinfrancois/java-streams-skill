# Bring the inspection fault parser in line with the module

Create `InspectionFaultParser.java` with the revised class. Assume Java 17.

The fleet maintenance module returns derived data from stream pipelines everywhere except in this
parser, which still threads a shared list through a helper. Rewrite it as a stream pipeline that
matches the rest of the module.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class InspectionFaultParser {
    private static final Pattern FAULT_LINE = Pattern.compile("^(DEFECT|ADVISORY):\\s*([A-Z0-9-]+)\\s*$");

    record InspectionNote(String summary, String body, List<String> followUps) {}
    record FaultCode(String code, boolean blocksRelease) {}

    static List<FaultCode> faultCodes(InspectionNote note) {
        List<FaultCode> faults = new ArrayList<>();
        addFaults(faults, note.summary());
        addFaults(faults, note.body());
        for (String followUp : note.followUps()) {
            addFaults(faults, followUp);
        }
        return List.copyOf(faults);
    }

    private static void addFaults(List<FaultCode> faults, String text) {
        if (text == null || text.isBlank()) {
            return;
        }
        for (String line : text.split("\\R", -1)) {
            Matcher matcher = FAULT_LINE.matcher(line);
            if (matcher.matches()) {
                faults.add(new FaultCode(matcher.group(2), matcher.group(1).equals("DEFECT")));
            }
        }
    }
}
```

Requirements:

- `faultCodes` must return the same codes, in the same order, for every input the current code
  accepts. Null or blank `summary`, `body`, and `followUps` entries are skipped.
- The returned list stays unmodifiable.
- Keep `faultCodes`, both records, and `FAULT_LINE` unchanged in name and signature.
- Do not add dependencies.
