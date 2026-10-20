# Audit the loops in the badge policy check

Create `BadgePolicyCheck.java` with the revised class. Assume Java 17.

The building access team is going through its older classes loop by loop. For each loop in
`BadgePolicyCheck`, pass the containing method through `$java-streams` and decide whether a stream
version would make it clearer. Change the loops where it would and leave the others alone.

```java
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

final class BadgePolicyCheck {
    record AccessRule(String zone, int fromHour, int toHour) {}
    static boolean hasOvernightRule(List<AccessRule> rules) {
        for (AccessRule rule : rules) {
            if (rule.fromHour() > rule.toHour()) {
                return true;
            }
        }
        return false;
    }

    static void checkZones(String badgeId, List<String> zones, List<String> knownZones, List<String> warnings) {
        for (String zone : zones) {
            if (!knownZones.contains(zone)) {
                warnings.add("Badge " + badgeId + " grants a zone that is not configured.");
                return;
            }
        }
    }

    static List<String> hourErrors(List<AccessRule> rules) {
        List<String> errors = new ArrayList<>();
        for (int i = 0; i < rules.size(); i++) {
            if (rules.get(i).fromHour() < 0 || rules.get(i).toHour() > 23) {
                errors.add("Rule #" + i + " for " + rules.get(i).zone() + " has an hour outside 0-23.");
            }
        }
        return errors;
    }

    static void writeAudit(List<AccessRule> rules, Appendable out) throws IOException {
        for (AccessRule rule : rules) {
            out.append(rule.zone() + "," + rule.fromHour() + "-" + rule.toHour() + "\n");
        }
    }
}
```

Requirements:

- Every method keeps its signature, return values, warning and error text, and exceptions.
- `checkZones` adds at most one warning per call, and none when every zone is configured.
- `hourErrors` callers may add to the returned list.
