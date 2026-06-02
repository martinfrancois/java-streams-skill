# Review legacy adapter

Assume Java 17.

Use `$java-optionals` to review this adapter. Create `review.md` with a short review decision and
rationale. Do not modify the Java code.

```java
import java.util.Optional;

final class LegacyAdapter {
    LegacyRequest toLegacy(Optional<String> comment) {
        return new LegacyRequest(comment.orElse(null));
    }

    record LegacyRequest(String nullableComment) {}
}
```
