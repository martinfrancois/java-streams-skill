# Write first-pass clean label code

Assume Java 17.

Use `$java-optionals` to create `LabelFormatter.java`.

Implement:

```java
String label(Optional<String> rawLabel)
```

Rules:

- Trim a present label.
- If the trimmed label is not blank, return it.
- If the Optional is absent or the trimmed label is blank, return `"untitled"`.

