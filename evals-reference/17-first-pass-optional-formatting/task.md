# Write first-pass Optional formatting code

Assume Java 17.

Use `$java-optionals` to create `AssigneeFormatter.java`.

Implement a small Java class `AssigneeFormatter` with:

```java
String label(Optional<User> assignee)
```

Rules:

- If an assignee is present and `handle()` is not blank, return `"@" + handle`.
- If an assignee is present but `handle()` is blank, return the user's `displayName()`.
- If no assignee is present, return `"unassigned"`.

Include this nested record:

```java
record User(String handle, String displayName) {}
```
