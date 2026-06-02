# Review proposed Optional cleanup

Assume Java 17.

Use `$java-optionals` to review this proposed cleanup. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.Optional;

final class UserService {
    String displayName(Optional<User> user) {
        if (user.isPresent()) {
            return user.get().displayName();
        }
        return "Anonymous";
    }

    record User(String displayName) {}
}
```

Proposed:

```java
import java.util.Optional;

final class UserService {
    String displayName(Optional<User> user) {
        User value = user.orElse(null);
        if (value != null) {
            return value.displayName();
        }
        return "Anonymous";
    }

    record User(String displayName) {}
}
```
