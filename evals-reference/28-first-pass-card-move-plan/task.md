# Write first-pass card move plan

Assume Java 17.

Use `$java-optionals` to create `CardMovePlanner.java`.

Implement:

```java
Card moveIfNeeded(Optional<ListRef> target, Card card)
```

Rules:

- If `target` is absent, return `card`.
- If the target list id equals `card.listId()`, return `card`.
- Otherwise return `new Card(card.id(), targetList.id())`.

Include these nested records:

```java
record Card(String id, String listId) {}
record ListRef(String id) {}
```

