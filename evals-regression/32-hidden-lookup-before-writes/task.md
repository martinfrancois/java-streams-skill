# Clean up route sheet publishing

Create `RouteSheetPublisher.java` with the revised class. Assume Java 17.

The dispatch service below publishes route sheets for a regional courier fleet: it resolves depot
codes to display names through the depot directory, posts each sheet's handover captions to the
dispatch board, and returns what it posted. It works, but it is hard to follow. Clean it up while
keeping what gets posted and returned.

Each `DepotDirectory.fetch` call is one remote round trip, whatever the number of codes it asks for.

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

final class RouteSheetPublisher {
    private final DepotDirectory directory;
    private final DispatchBoard board;
    RouteSheetPublisher(DepotDirectory directory, DispatchBoard board) {
        this.directory = directory;
        this.board = board;
    }

    List<PublishedSheet> publish(List<RouteSheet> sheets) {
        List<String> stopCodes = sheets.stream().flatMap(sheet -> sheet.stopDepots().stream()).distinct().toList();
        Map<String, DepotInfo> depots = stopCodes.isEmpty() ? new HashMap<>() : directory.fetch(stopCodes);
        List<PublishedSheet> published = new ArrayList<>();
        for (RouteSheet sheet : sheets) {
            List<String> captions = handoverCaptions(sheet, depots);
            board.post(sheet.id(), captions);
            published.add(new PublishedSheet(sheet.id(), captions));
        }
        return published;
    }
    private List<String> handoverCaptions(RouteSheet sheet, Map<String, DepotInfo> known) {
        Map<String, DepotInfo> depots = new LinkedHashMap<>(known);
        List<String> missing = sheet.handoverDepots().stream().filter(code -> !depots.containsKey(code)).distinct().toList();
        if (!missing.isEmpty()) {
            depots.putAll(directory.fetch(missing));
        }
        return sheet.handoverDepots().stream().map(code -> code + " (" + depots.get(code).displayName() + ")").toList();
    }

    interface DepotDirectory { Map<String, DepotInfo> fetch(List<String> codes); }
    interface DispatchBoard { void post(String sheetId, List<String> captions); }
    record DepotInfo(String code, String displayName) {}
    record RouteSheet(String id, List<String> stopDepots, List<String> handoverDepots) {}
    record PublishedSheet(String sheetId, List<String> handoverCaptions) {}
}
```

Rules:

- The directory returns an entry for every code it is asked about.
- Post exactly one board update per sheet, in input order, with that sheet's captions.
- Captions follow the order of `handoverDepots`, one per entry, duplicates included, formatted as
  `CODE (Display Name)`.
- Return one `PublishedSheet` per sheet in input order, with the same captions that were posted.
- Keep the constructor, `publish`, and the nested types unchanged.
