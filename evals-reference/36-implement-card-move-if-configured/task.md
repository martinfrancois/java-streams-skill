# Implement card move if configured

Assume Java 17.

Use `$java-optionals` to create `CardMover.java`.

Implement:

```java
Move moveToTargetIfConfigured(Card card, BoardContext context, Config config)
```

Rules:

- Find the target list by matching `config.targetListName()` against `BoardList.name()` in `context.lists()`.
- If no target list is configured or no matching list exists, return `Move.none(card.id())`.
- If the card is already in the target list, return `Move.none(card.id())`.
- Otherwise return `Move.toList(card.id(), targetList.id())`.

Include:

```java
record Card(String id, String listId) {}
record BoardList(String id, String name) {}
record BoardContext(List<BoardList> lists) {}
record Config(Optional<String> targetListName) {}
record Move(String cardId, Optional<String> targetListId) {
    static Move none(String cardId) { return new Move(cardId, Optional.empty()); }
    static Move toList(String cardId, String listId) { return new Move(cardId, Optional.of(listId)); }
}
```

