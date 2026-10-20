# Tidy the harbour call index

Create `HarbourCallIndex.java` with the revised class. Assume Java 17.

The port operations team keeps lookup tables for vessels, berths, and port calls in the class
below. It is correct, but the team wants it tidied for readability before more indexes are added.
Clean up all four methods and keep their behavior.

```java
import static java.util.stream.Collectors.*;

import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

final class HarbourCallIndex {
    Map<String, Vessel> vesselsByImo(List<Vessel> vessels) {
        return vessels.stream()
                .collect(toMap(Vessel::imo, vessel -> vessel, (kept, ignored) -> kept, LinkedHashMap::new));
    }

    Map<String, PortCall> latestCallByBerth(List<PortCall> calls) {
        return calls.stream()
                .collect(toMap(PortCall::berth, portCall -> portCall, HarbourCallIndex::later, TreeMap::new));
    }

    Map<String, String> berthCodesByLabel(List<String> berthLabels) {
        return berthLabels.stream()
                .collect(toMap(berthLabel -> berthLabel, berthLabel -> berthLabel.strip().toUpperCase(Locale.ROOT), (kept, ignored) -> kept, TreeMap::new));
    }

    Map<String, Integer> callsPerFlag(List<PortCall> calls) {
        Map<String, Integer> tally = new TreeMap<>();
        calls.stream()
                .map(portCall -> portCall.vessel().flag().toUpperCase(Locale.ROOT))
                .forEach(flag -> tally.merge(flag, 1, Integer::sum));
        return tally;
    }

    private static PortCall later(PortCall kept, PortCall candidate) {
        return candidate.arrival().isAfter(kept.arrival()) ? candidate : kept;
    }

    record Vessel(String imo, String name, String flag) {}
    record PortCall(Vessel vessel, String berth, OffsetDateTime arrival) {}
}
```

Rules:

- On duplicate keys, keep the same winner as today: the first vessel per IMO number, the first
  label, and the call with the later arrival per berth.
- Keep each returned map's iteration order: insertion order for vessels, sorted keys for the other
  three.
- Callers may add entries to any returned map.
- Berth codes keep their current derivation from labels, and each flag count starts at one per
  call.
- Keep the method signatures, `later`, and the records unchanged.
