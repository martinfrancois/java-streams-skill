# Review proposed eager fallback regression

Assume Java 17.

Use `$java-optionals` to review this proposed cleanup. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.Optional;

final class DocumentCache {
    Document document(String key) {
        Optional<Document> cached = find(key);
        if (cached.isPresent()) {
            return cached.get();
        }
        return createAndStore(key);
    }

    Optional<Document> find(String key) { return Optional.empty(); }
    Document createAndStore(String key) { return new Document(key); }
    record Document(String key) {}
}
```

Proposed:

```java
import java.util.Optional;

final class DocumentCache {
    Document document(String key) {
        return find(key).orElse(createAndStore(key));
    }

    Optional<Document> find(String key) { return Optional.empty(); }
    Document createAndStore(String key) { return new Document(key); }
    record Document(String key) {}
}
```

