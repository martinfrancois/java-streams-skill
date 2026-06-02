# Add validation to setup defaults

Assume Java 17.

Use `$java-optionals` to create `SetupOptions.java` with the revised class.

Current code:

```java
import java.util.Optional;

final class SetupOptions {
    SetupPlan plan(Request request, Defaults defaults) {
        boolean githubMode = request.githubMode().isPresent()
                ? request.githubMode().get()
                : defaults.githubMode().orElse(false);
        String boardName = request.boardName().isPresent()
                ? request.boardName().get()
                : defaults.boardName().orElse("Symphony");
        int serverPort = request.serverPort().isPresent()
                ? request.serverPort().get()
                : defaults.serverPort().orElse(18080);
        return new SetupPlan(githubMode, boardName, serverPort);
    }

    record Request(Optional<Boolean> githubMode, Optional<String> boardName, Optional<Integer> serverPort) {}
    record Defaults(Optional<Boolean> githubMode, Optional<String> boardName, Optional<Integer> serverPort) {}
    record SetupPlan(boolean githubMode, String boardName, int serverPort) {}
}
```

Required changes:

- Keep request values taking priority over defaults, and defaults over literals.
- If an explicit request server port is present and less than `1`, throw `IllegalArgumentException("server_port must be positive")`.
- If an explicit request board name is present and blank after trimming, throw `IllegalArgumentException("board name must not be blank")`.
- Trim the selected board name in the resulting `SetupPlan`.

