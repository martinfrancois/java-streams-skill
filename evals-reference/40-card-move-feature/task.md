# Add no-op handling to configured card move

Assume Java 17.

Use `$java-optionals` to create `CardMover.java` with the revised class.

Current code:

```java
import java.util.List;
import java.util.Optional;

final class CardMover {
    Move moveToTargetIfConfigured(Card card, BoardContext context, Config config) {
        Optional<BoardList> target = config.targetListName()
                .flatMap(name -> context.lists().stream()
                        .filter(list -> list.name().equals(name))
                        .findFirst());
        if (target.isEmpty()) {
            return Move.none(card.id());
        }
        return Move.toList(card.id(), target.get().id());
    }

    record Card(String id, String listId) {}
    record BoardList(String id, String name) {}
    record BoardContext(List<BoardList> lists) {}
    record Config(Optional<String> targetListName) {}
    record Move(String cardId, Optional<String> targetListId) {
        static Move none(String cardId) { return new Move(cardId, Optional.empty()); }
        static Move toList(String cardId, String listId) { return new Move(cardId, Optional.of(listId)); }
    }
}
```

Required changes:

- Keep returning no move when no target is configured or no list matches.
- Add no-op behavior when the card is already in the target list.
- Return `Move.toList(card.id(), targetList.id())` only when the configured target exists and differs from `card.listId()`.
- Leave the target Optional easy to review.

