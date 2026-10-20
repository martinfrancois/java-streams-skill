# Revisit the mutable lists in the broadcast schedule

Create `BroadcastSchedule.java` with the revised record. Assume Java 17.

The radio station's scheduling service has agreed to use immutable collections by default and
mutable ones only where they make the code easier to read. Review `BroadcastSchedule` against that
rule and refactor where it makes sense.

```java
import java.util.ArrayList;
import java.util.List;

record BroadcastSchedule(String station, List<AirSegment> segments) {
    record AirSegment(String segmentId, String slot, int minutes, boolean live) {}

    BroadcastSchedule {
        segments = List.copyOf(segments);
    }

    BroadcastSchedule withSegment(AirSegment segment) {
        List<AirSegment> updated = new ArrayList<>(segments.stream()
                .filter(existing -> !sameSlotOrId(existing, segment))
                .toList());
        updated.add(segment);
        return new BroadcastSchedule(station, updated);
    }

    BroadcastSchedule withNewsBreaks(AirSegment newsBreak, int everyMinutes) {
        List<AirSegment> updated = new ArrayList<>();
        int sinceBreak = 0;
        for (AirSegment current : segments) {
            if (current.live() && sinceBreak >= everyMinutes) {
                updated.add(newsBreak);
                sinceBreak = 0;
            }
            updated.add(current);
            sinceBreak += current.minutes();
        }
        return new BroadcastSchedule(station, updated);
    }

    private static boolean sameSlotOrId(AirSegment left, AirSegment right) {
        return left.slot().equals(right.slot()) || left.segmentId().equals(right.segmentId());
    }
}
```

Requirements:

- `withSegment` returns a schedule with every existing segment that shares neither slot nor id with
  `segment`, in their current order, followed by `segment`.
- `withNewsBreaks` must produce exactly the same segment list as today.
- Keep the record components, the compact constructor's copy, and both method signatures
  unchanged.
