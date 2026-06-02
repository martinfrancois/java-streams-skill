# Review proposed repeated get cleanup

Assume Java 17.

Use `$java-optionals` to review this proposed cleanup. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.Optional;

final class CardMover {
    Card moveIfNeeded(Optional<ListRef> target, Card card) {
        if (target.isEmpty()) {
            return card;
        }
        if (card.listId().equals(target.get().id())) {
            return card;
        }
        return new Card(card.id(), target.get().id());
    }

    record Card(String id, String listId) {}
    record ListRef(String id) {}
}
```

Proposed:

```java
import java.util.Optional;

final class CardMover {
    Card moveIfNeeded(Optional<ListRef> target, Card card) {
        if (target.isPresent()) {
            if (!card.listId().equals(target.get().id())) {
                return new Card(card.id(), target.get().id());
            }
        }
        return card;
    }

    record Card(String id, String listId) {}
    record ListRef(String id) {}
}
```

