# Refactor duplicate-aware lookups

Refactor `ChecklistLookup.java` with a stream-based implementation. Assume Java 21.

Return the revised Java code only.

```java
import java.util.List;
import java.util.Objects;

final class ChecklistLookup {
    static Card.Checklist singleChecklistByName(List<Card.Checklist> checklists, String checklistName) {
        Card.Checklist match = null;
        for (Card.Checklist checklist : checklists) {
            if (!Objects.equals(checklist.name(), checklistName)) {
                continue;
            }
            if (match != null) {
                throw new TrelloException(
                        "trello_checklist_ambiguous",
                        "Multiple Trello checklists match the requested checklist_name.");
            }
            match = checklist;
        }
        return match;
    }

    static Card.ChecklistItem singleCheckItemByName(Card.Checklist checklist, String itemName) {
        Card.ChecklistItem match = null;
        for (Card.ChecklistItem item : checklist.items()) {
            if (!Objects.equals(item.text(), itemName)) {
                continue;
            }
            if (match != null) {
                throw new TrelloException(
                        "trello_check_item_ambiguous",
                        "Multiple Trello checklist items match the requested item_name.");
            }
            match = item;
        }
        return match;
    }

    record Card(List<Checklist> checklists) {
        record Checklist(String name, List<ChecklistItem> items) {}
        record ChecklistItem(String text) {}
    }

    static final class TrelloException extends RuntimeException {
        private final String code;

        TrelloException(String code, String message) {
            super(message);
            this.code = code;
        }

        String code() {
            return code;
        }
    }
}
```

Preserve null-safe name matching, no-match `null` behavior, encounter order for the single returned
match, and the existing exception codes and messages. The lookup only needs to distinguish zero
matches, exactly one match, and at least two matches, so do not scan or retain matches after
ambiguity is already proven. If both lookup methods need the same zero, one, or ambiguous branch,
extract that branch into a small shared helper while keeping the predicates and error contracts
domain-specific. Keep the code small.
