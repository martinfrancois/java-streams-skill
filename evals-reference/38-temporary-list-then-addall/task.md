# Simplify the drone sector claim lookup

Create `SectorClaims.java` with the revised class. Assume Java 17.

The drone fleet planner calls `sectorsClaimedByOtherPlans` before it re-plans a flight, so it can
avoid airspace sectors that other saved flight plans already claim. A previous cleanup pass already
touched this method, but it still reads as more work than it does. Simplify it without changing
behavior.

```java
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

final class SectorClaims {
    interface FlightPlanReader {
        List<String> claimedSectors(Path planFile);
    }

    private final FlightPlanReader planReader;

    SectorClaims(FlightPlanReader planReader) {
        this.planReader = planReader;
    }

    Set<String> sectorsClaimedByOtherPlans(Path planDir, Path replannedFile) {
        Set<String> claimed = new HashSet<>();
        if (planDir == null || !Files.isDirectory(planDir)) {
            return claimed;
        }
        try (var entries = Files.list(planDir)) {
            List<String> sectors = entries.filter(Files::isRegularFile)
                    .filter(file -> file.getFileName().toString().endsWith(".plan"))
                    .filter(file -> !file.equals(replannedFile))
                    .map(planReader::claimedSectors)
                    .flatMap(List::stream)
                    .toList();
            claimed.addAll(sectors);
        } catch (IOException ignored) {
            // An unreadable plan directory leaves only the radar-based conflict checks.
        }
        return claimed;
    }
}
```

What you need to know:

- The only caller copies the returned sectors into its own set and checks membership. It never
  modifies the returned set and does not depend on iteration order.
- A missing directory, a path that is not a directory, or a directory that cannot be listed must
  still produce an empty result, not an exception.
- Keep the class, constructor, nested interface, and method signature unchanged.
