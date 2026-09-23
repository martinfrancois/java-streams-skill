# Clarify concrete collector choices

Review and clean up `CollectorChoices.java`. Assume Java 17.

Return the revised Java code only. Keep concrete collection collectors only where the concrete type
is part of the method's behavior. When a later operation requires mutability or encounter-order
preserving de-duplication, keep that concrete collector and make the reason visible in the code.

```java
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.SequencedSet;
import java.util.Set;
import java.util.stream.Collectors;

final class CollectorChoices {
    static List<Card> terminalCards(List<Card> boardCards) {
        List<Card> normalized = boardCards.stream()
                .filter(Card::terminal)
                .collect(Collectors.toCollection(ArrayList::new));
        normalized.add(new Card("archive-summary", true));
        return List.copyOf(normalized);
    }

    static Set<String> archivedListIds(List<BoardList> lists) {
        return lists.stream()
                .filter(BoardList::closed)
                .map(BoardList::id)
                .collect(Collectors.toCollection(HashSet::new));
    }

    static SequencedSet<String> unconnectedWorkflowPaths(List<String> reported, Set<String> selected) {
        return reported.stream()
                .filter(path -> !selected.contains(path))
                .collect(Collectors.toCollection(LinkedHashSet::new));
    }

    record Card(String id, boolean terminal) {}
    record BoardList(String id, boolean closed) {}
}
```
