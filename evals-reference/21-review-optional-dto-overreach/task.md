# Review proposed DTO Optional overreach

Assume Java 17.

Use `$java-optionals` to review this proposed cleanup. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.Optional;

final class LegacyAdapter {
    LegacyRequest toLegacy(Optional<String> comment) {
        return new LegacyRequest(comment.orElse(null));
    }

    record LegacyRequest(String nullableComment) {}
}
```

Proposed:

```java
import java.util.Optional;

final class LegacyAdapter {
    LegacyRequest toLegacy(Optional<String> comment) {
        return new LegacyRequest(comment);
    }

    record LegacyRequest(Optional<String> comment) {}
}
```
