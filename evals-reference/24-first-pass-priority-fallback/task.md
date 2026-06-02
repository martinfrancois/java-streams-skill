# Write first-pass priority fallback code

Assume Java 17.

Use `$java-optionals` to create `WorkspaceResolver.java`.

Implement:

```java
String resolve(Optional<String> cliWorkspace, Optional<String> environmentWorkspace, String defaultWorkspace)
```

Rules:

- Return the CLI workspace when it is present.
- Otherwise return the environment workspace when it is present.
- Otherwise return `defaultWorkspace`.

