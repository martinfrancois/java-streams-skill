# Refactor comment upsert

Assume Java 17.

Use `$java-optionals` to make this upsert method easier to maintain without changing when
`update(...)` or `create(...)` are called:

```java
import java.util.Optional;

final class WorkpadService {
    Result upsert(Optional<Comment> existing, String text) {
        if (existing.isPresent()) {
            return update(existing.get(), text);
        }
        return create(text);
    }

    Result update(Comment comment, String text) { return new Result("updated"); }
    Result create(String text) { return new Result("created"); }

    record Comment(String id) {}
    record Result(String status) {}
}
```
