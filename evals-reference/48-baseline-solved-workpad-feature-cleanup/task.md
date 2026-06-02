# Add workpad safeguards while cleaning up the implementation

Use `$java-optionals` to create `WorkpadService.java` with the revised class.
Assume Java 17.

The current implementation was written during an AI-assisted maintainability pass. It works for the
happy path, but the new feature needs two safeguards and the method should be left maintainable.

Current code:

```java
import java.util.List;
import java.util.Optional;

final class WorkpadService {
    Result upsertWorkpad(Card card, String text) {
        Optional<Comment> existing = card.comments().stream()
                .filter(this::isWorkpadComment)
                .findFirst();

        if (existing.isPresent()) {
            return updateExistingWorkpad(existing.get(), text);
        }
        return createWorkpad(card, text);
    }

    boolean isWorkpadComment(Comment comment) {
        return comment.text() != null && comment.text().startsWith("<!-- workpad -->");
    }

    Result updateExistingWorkpad(Comment workpad, String text) {
        return Result.success("updated:" + workpad.id() + ":" + text);
    }

    Result createWorkpad(Card card, String text) {
        return Result.success("created:" + card.id() + ":" + text);
    }

    record Card(String id, List<Comment> comments) {}
    record Comment(String id, String text) {}
    record Result(boolean ok, String status) {
        static Result success(String status) { return new Result(true, status); }
        static Result failure(String status) { return new Result(false, status); }
    }
}
```

Required changes:

- If an existing workpad comment has a `null` or blank id, return `Result.failure("missing_action_id")`.
- If no workpad comment exists and `card.comments().size() >= 1000`, return `Result.failure("comment_window_incomplete")`.
- Preserve the existing updated/created success status formats.
- Keep create-side checks and creation lazy; they must not run when an existing workpad comment is present.
