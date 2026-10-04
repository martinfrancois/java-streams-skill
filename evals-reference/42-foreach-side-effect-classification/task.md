# Review stream forEach side effects

Review `ForEachReview.java`. Assume Java 17.

Create `review.md` with concrete recommendations for each marked method. Do not rewrite the whole
class; classify which `forEach` uses should become result-producing stream operations, which should
be plain loops, and which can remain terminal side effects with caveats. Include ordering and
exception-propagation caveats where they matter.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

final class ForEachReview {
    private static final Logger LOG = Logger.getLogger(ForEachReview.class.getName());

    List<String> displayNames(List<User> users) {
        List<String> names = new ArrayList<>();
        users.stream()
                .filter(User::active)
                .map(User::displayName)
                .forEach(names::add);
        return List.copyOf(names);
    }

    void applyHeaders(RequestBuilder builder, Map<String, String> headers) {
        headers.entrySet().stream()
                .filter(entry -> !entry.getValue().isBlank())
                .forEach(entry -> builder.header(entry.getKey(), entry.getValue()));
    }

    void logDebugProperties(List<String> properties) {
        if (LOG.isLoggable(java.util.logging.Level.FINE)) {
            properties.stream().forEach(LOG::fine);
        }
    }

    int countErrors(List<Result> results) {
        int[] count = {0};
        results.parallelStream()
                .filter(Result::failed)
                .forEach(result -> count[0]++);
        return count[0];
    }

    record User(String displayName, boolean active) {}
    record Result(boolean failed) {}
    interface RequestBuilder {
        void header(String name, String value);
    }
}
```
