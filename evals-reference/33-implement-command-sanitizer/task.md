# Implement command sanitizer

Assume Java 17.

Use `$java-optionals` to create `CommandSanitizer.java`.

Implement:

```java
String sanitize(List<String> args)
```

The sanitizer should redact secret-bearing command options.

Rules:

- These options carry secret values: `"--token"`, `"--key"`, `"--workflow"`, `"--config-dir"`, `"--state-home"`, `"--output"`.
- If an argument exactly equals a secret option, keep the option itself and replace the following argument with `"<redacted>"`.
- If an argument starts with `option + "="`, replace it with `option + "=<redacted>"`.
- Non-secret arguments are preserved.
- Return the sanitized command as `String.join(" ", sanitizedArgs)`.

Examples:

- `["run", "--token", "abc", "--verbose"]` becomes `"run --token <redacted> --verbose"`.
- `["run", "--key=abc", "file"]` becomes `"run --key=<redacted> file"`.

