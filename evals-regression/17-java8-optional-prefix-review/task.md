# Review Java 8 optional and prefix refactor

Use `$java-streams` to review this proposed change. Create `review.md` with a short decision and a
Java 8-compatible alternative if the change should not be accepted.

Assume Java 8.

Before:

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

final class AuditTrail {
    List<Event> visiblePrefix(Optional<List<Event>> maybeEvents) {
        List<Event> out = new ArrayList<>();
        if (!maybeEvents.isPresent()) {
            return out;
        }
        for (Event event : maybeEvents.get()) {
            if (!event.visible()) {
                break;
            }
            out.add(event);
        }
        return out;
    }

    static final class Event {
        private final String id;
        private final boolean visible;

        Event(String id, boolean visible) {
            this.id = id;
            this.visible = visible;
        }

        String id() { return id; }
        boolean visible() { return visible; }
    }
}
```

Proposed:

```java
import java.util.List;
import java.util.Optional;

final class AuditTrail {
    List<Event> visiblePrefix(Optional<List<Event>> maybeEvents) {
        return maybeEvents.stream()
                .flatMap(List::stream)
                .takeWhile(Event::visible)
                .toList();
    }

    static final class Event {
        private final String id;
        private final boolean visible;

        Event(String id, boolean visible) {
            this.id = id;
            this.visible = visible;
        }

        String id() { return id; }
        boolean visible() { return visible; }
    }
}
```
