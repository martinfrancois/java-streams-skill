# Review route lookup

Assume Java 17.

Use `$java-optionals` to review whether this Optional-returning lookup should change. Create
`review.md` with a short review decision and rationale. Do not modify the Java code.

```java
import java.util.List;
import java.util.Optional;

final class RouteSelector {
    Optional<Route> firstEnabledRoute(List<Route> routes) {
        return routes.stream()
                .filter(Route::enabled)
                .findFirst();
    }

    record Route(String name, boolean enabled) {}
}
```
