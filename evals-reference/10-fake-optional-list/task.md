# Refactor greeting fallback

Assume Java 17.

Use `$java-optionals` to improve this Optional-based fallback:

```java
import java.util.Optional;

final class GreetingService {
    String greeting(Optional<String> name) {
        for (String value : name.stream().toList()) {
            return "Hello " + value;
        }
        return "Hello guest";
    }
}
```
