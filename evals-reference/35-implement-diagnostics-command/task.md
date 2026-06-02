# Implement diagnostics command helpers

Assume Java 17.

Use `$java-optionals` to create `DiagnosticsCommand.java`.

Implement two methods:

```java
Selection select(Manifest manifest, Optional<String> board, Optional<Path> workflow, Path configDir)
void finish(Optional<Path> output, String report)
```

Rules for `select`:

- If both `board` and `workflow` are present, throw `IllegalArgumentException("--board and --workflow cannot be used together.")`.
- If `board` is present, return `new Selection("board", List.of(boardValue), Optional.empty())`.
- If `workflow` is present, return `new Selection("workflow", List.of(), Optional.of(configDir.resolve(workflowValue)))`.
- If neither is present, return `new Selection("all", manifest.boards(), Optional.empty())`.

Rules for `finish`:

- If `output` is present, call `write(outputPath, report)`.
- If `output` is absent, call `print(report)`.

Include:

```java
void write(Path path, String report) {}
void print(String report) {}
record Manifest(List<String> boards) {}
record Selection(String kind, List<String> boards, Optional<Path> workflow) {}
```

