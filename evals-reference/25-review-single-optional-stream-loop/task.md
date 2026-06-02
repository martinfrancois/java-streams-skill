# Review proposed single Optional stream loop

Assume Java 17.

Use `$java-optionals` to review this proposed cleanup. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.Optional;

final class AssigneeFormatter {
    String label(Optional<User> assignee) {
        if (assignee.isPresent()) {
            return assignee.get().displayName();
        }
        return "unassigned";
    }

    record User(String displayName) {}
}
```

Proposed:

```java
import java.util.Optional;

final class AssigneeFormatter {
    String label(Optional<User> assignee) {
        for (User user : assignee.stream().toList()) {
            return user.displayName();
        }
        return "unassigned";
    }

    record User(String displayName) {}
}
```

