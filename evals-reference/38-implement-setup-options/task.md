# Implement setup option selection

Assume Java 17.

Use `$java-optionals` to create `SetupOptions.java`.

Implement:

```java
SetupPlan plan(Request request, Defaults defaults)
```

Rules:

- `githubMode` should be `request.githubMode()` if present, otherwise `defaults.githubMode()`, otherwise `false`.
- `boardName` should be `request.boardName()` if present, otherwise `defaults.boardName()`, otherwise `"Symphony"`.
- `serverPort` should be `request.serverPort()` if present, otherwise `defaults.serverPort()`, otherwise `18080`.
- If `request.serverPort()` is present and less than `1`, throw `IllegalArgumentException("server_port must be positive")`.
- If `request.boardName()` is present and blank after trimming, throw `IllegalArgumentException("board name must not be blank")`.

Include:

```java
record Request(Optional<Boolean> githubMode, Optional<String> boardName, Optional<Integer> serverPort) {}
record Defaults(Optional<Boolean> githubMode, Optional<String> boardName, Optional<Integer> serverPort) {}
record SetupPlan(boolean githubMode, String boardName, int serverPort) {}
```

