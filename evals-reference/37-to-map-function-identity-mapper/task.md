# Clean up toMap identity mappers

Refactor `StateIndexes.java`. Assume Java 17.

Return the revised Java code only.

```java
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

final class StateIndexes {
    Map<String, Integer> runningCountsByState(List<String> normalizedStates) {
        return normalizedStates.stream()
                .collect(Collectors.toMap(state -> state, state -> 1, Integer::sum, HashMap::new));
    }

    List<Card> dedupeById(List<Card> normalized) {
        return normalized.stream()
                .collect(Collectors.toMap(Card::id, card -> card, (left, right) -> left, LinkedHashMap::new))
                .values()
                .stream()
                .toList();
    }

    Map<String, String> displayNameById(List<Card> cards) {
        return cards.stream()
                .collect(Collectors.toMap(Card::id, card -> card.displayName(), (left, right) -> left));
    }

    record Card(String id, String displayName) {}
}
```

Preserve duplicate-key merge behavior, explicit map suppliers, and the non-identity display-name
mapper.
