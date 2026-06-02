# Implement workspace resolution

Assume Java 17.

Use `$java-optionals` to create `WorkspaceResolver.java`.

Implement:

```java
String workspaceId(Options options, Terminal terminal) throws IOException
```

Rules:

- If `options.workspaceId()` is present, return it.
- Otherwise prompt with `terminal.readLine("Workspace: ")` and return the result.
- Preserve the checked `IOException` contract.
- Do not add helper types or dependencies.

Include:

```java
interface Options { Optional<String> workspaceId(); }
interface Terminal { String readLine(String prompt) throws IOException; }
```

