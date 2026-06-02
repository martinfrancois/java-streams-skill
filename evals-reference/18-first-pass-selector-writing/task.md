# Write first-pass selector code

Assume Java 17.

Use `$java-optionals` to create `DiagnosticSelector.java`.

Implement:

```java
Selection select(Optional<String> board, Optional<Path> workflow, List<String> allBoards)
```

Rules:

- If both selectors are present, throw `IllegalArgumentException("--board and --workflow cannot be used together.")`.
- If `board` is present, return `new Selection("board", board, Optional.empty())`.
- If `workflow` is present, return `new Selection("workflow", Optional.empty(), workflow)`.
- If neither selector is present, return `new Selection("all", Optional.empty(), Optional.empty())`.

Include imports and this nested record:

```java
record Selection(String kind, Optional<String> board, Optional<Path> workflow) {}
```
