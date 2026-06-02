# Add environment fallback to workspace prompt

Use `$java-optionals` to create `WorkspaceResolver.java` with the revised class.
Assume Java 17.

Current code:

```java
import java.io.IOException;
import java.util.Optional;

final class WorkspaceResolver {
    String workspaceId(Options options, Terminal terminal) throws IOException {
        Optional<String> configured = options.workspaceId();
        if (configured.isPresent()) {
            return configured.get();
        }
        return terminal.readLine("Workspace: ");
    }

    interface Options {
        Optional<String> workspaceId();
        Optional<String> environmentWorkspaceId();
    }

    interface Terminal {
        String readLine(String prompt) throws IOException;
    }
}
```

Required changes:

- Return `options.workspaceId()` when present.
- Otherwise return `options.environmentWorkspaceId()` when present.
- Otherwise prompt with `terminal.readLine("Workspace: ")`.
- Preserve `throws IOException`.
- Do not add helper types or dependencies.
