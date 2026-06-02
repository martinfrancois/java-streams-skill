# Implement front matter port lookup

Assume Java 17.

Use `$java-optionals` to create `WorkflowPortLookup.java`.

Implement:

```java
Optional<Integer> workflowServerPortReservation(Optional<Map<String, Object>> frontMatter, Path workflowPath)
```

Rules:

- If `frontMatter` is absent, return `Optional.empty()`.
- Read the `"server_port"` value from the map.
- Accept `Number` values directly via `intValue()`.
- Accept `String` values that parse as an integer after trimming.
- For missing, blank, or non-numeric values, return `Optional.empty()`.
- Do not throw for malformed values.
- `workflowPath` is included for parity with the real method; no output should expose it.

