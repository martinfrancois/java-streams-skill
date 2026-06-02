# Write first-pass redacted option matcher

Assume Java 17.

Use `$java-optionals` to create `CommandOptionMatcher.java`.

Implement:

```java
static Optional<String> redactedValueOption(String arg)
```

The class should contain this option set:

```java
private static final Set<String> REDACTED_VALUE_OPTIONS = Set.of(
        "--token", "--key", "--workflow", "--config-dir", "--state-home", "--output");
```

Return the matching option when `arg` equals the option or starts with `option + "="`. Return
`Optional.empty()` otherwise.
