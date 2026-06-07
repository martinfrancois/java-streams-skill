# Review parallel stream accumulator refactor

Use `$java-streams` to review this proposed change. Create `review.md` with a short decision and a
safer stream chain if the change should not be accepted.

Assume Java 17.

Before:

```java
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class ShipmentIndex {
    Map<String, Shipment> index(List<Shipment> shipments) {
        Map<String, Shipment> out = new HashMap<>();
        for (Shipment shipment : shipments) {
            if (shipment.active()) {
                out.put(shipment.id(), shipment);
            }
        }
        return out;
    }

    record Shipment(String id, boolean active) {}
}
```

Proposed:

```java
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class ShipmentIndex {
    Map<String, Shipment> index(List<Shipment> shipments) {
        Map<String, Shipment> out = new HashMap<>();
        shipments.parallelStream()
                .filter(Shipment::active)
                .forEach(shipment -> out.put(shipment.id(), shipment));
        return out;
    }

    record Shipment(String id, boolean active) {}
}
```
