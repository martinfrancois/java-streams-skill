# Check matching customer session

Assume Java 17.

Use `$java-optionals` to improve this Java code without changing behavior. Create
`CustomerSessionCheck.java` with the revised class.

```java
import java.util.Optional;

final class CustomerSessionCheck {
    boolean belongsToCustomer(Optional<String> sessionCustomerId, String expectedCustomerId) {
        if (sessionCustomerId.isPresent() && sessionCustomerId.orElseThrow().equals(expectedCustomerId)) {
            return true;
        }
        return false;
    }
}
```

Keep returning `true` only when the optional session customer id exists and equals the expected id.
