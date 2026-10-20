# Tidy depot lookups before they move to a shared library

Create `DepotLookups.java` with the revised class. Assume Java 17.

The dispatch team is moving this class into a library that other depots will call. People reading
the library will see the method bodies, not this page, so each method should say in code what the
data guarantees about its result. Revise the class with that in mind. All current callers use the
methods sequentially, and their results must not change.

```java
import java.util.List;
import java.util.Optional;

final class DepotLookups {
    record LoadingDock(String code, boolean closed) {}
    record HaulRoute(String routeId, boolean open) {}
    record TelemetryPing(String vehicleTag, long epochSecond) {}

    Optional<LoadingDock> dockByCode(List<LoadingDock> docks, String code) {
        return docks.stream()
                .filter(dock -> !dock.closed())
                .filter(dock -> dock.code().equalsIgnoreCase(code))
                .findFirst();
    }

    Optional<String> registeredTag(List<String> registeredTags, String scannedTag) {
        return registeredTags.stream()
                .filter(tag -> tag.equalsIgnoreCase(scannedTag.strip()))
                .findFirst();
    }

    Optional<HaulRoute> fallbackRoute(List<HaulRoute> routesInPreferenceOrder) {
        return routesInPreferenceOrder.stream().filter(HaulRoute::open).findFirst();
    }

    Optional<TelemetryPing> newestPing(List<TelemetryPing> pingsNewestFirst, String vehicleTag) {
        return pingsNewestFirst.stream()
                .filter(ping -> ping.vehicleTag().equals(vehicleTag))
                .findFirst();
    }

    Optional<String> headline(String dispatchNote) {
        return dispatchNote.lines().filter(line -> !line.isBlank()).findFirst();
    }
}
```

What the data guarantees:

- Dock codes are unique within a depot, compared without case. Two open docks never share a code.
- The tag registry is imported from two systems and can hold the same vehicle tag twice in
  different casing. Both entries name the same vehicle, and callers accept either spelling.
- `routesInPreferenceOrder` is sorted by the dispatcher's preference. The most preferred open route
  must win.
- `pingsNewestFirst` is sorted newest first. The newest ping for the vehicle must win.
- A dispatch note's headline is its first non-blank line.

Keep the method signatures and records as they are, and do not add dependencies.
