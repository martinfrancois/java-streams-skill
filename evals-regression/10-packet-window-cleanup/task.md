# Refactor packet window code

Use `$java-streams` to create `PacketWindow.java` with the revised class. Assume Java 17.

The current loop is verbose. Refactor it, but keep the chronological window semantics exactly.

```java
import java.util.ArrayList;
import java.util.List;

final class PacketWindow {
    List<Packet> beforeFirstLossSpike(List<Packet> packets, double threshold) {
        List<Packet> result = new ArrayList<>();
        for (Packet packet : packets) {
            if (packet.loss() > threshold) {
                break;
            }
            result.add(packet);
        }
        return result;
    }

    List<Packet> afterInitialHealthyPrefix(List<Packet> packets, double threshold) {
        List<Packet> result = new ArrayList<>();
        boolean spikeSeen = false;
        for (Packet packet : packets) {
            if (!spikeSeen && packet.loss() <= threshold) {
                continue;
            }
            spikeSeen = true;
            result.add(packet);
        }
        return result;
    }

    record Packet(long sequence, double loss) {}
}
```

Requirements:

- `beforeFirstLossSpike` returns only the initial chronological prefix where `loss <= threshold`.
- `afterInitialHealthyPrefix` drops only that initial healthy prefix and returns every later packet,
  including later healthy packets.
- These methods must not behave like a general `filter`.
