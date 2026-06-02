# Refactor display name

Assume Java 17.

Use `$java-optionals` to improve this Java code without changing behavior:

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
