# Add diagnostics selection and output behavior

Assume Java 17.

Use `$java-optionals` to create `DiagnosticsCommand.java` with the revised class.

Current code:

```java
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;

final class DiagnosticsCommand {
    Selection select(Manifest manifest, Optional<String> board, Optional<Path> workflow, Path configDir) {
        if (board.isPresent() && workflow.isPresent()) {
            throw new IllegalArgumentException("--board and --workflow cannot be used together.");
        }
        if (board.isPresent()) {
            return new Selection("board", List.of(board.orElseThrow()), Optional.empty());
        }
        if (workflow.isPresent()) {
            return new Selection("workflow", List.of(), Optional.of(workflow.orElseThrow()));
        }
        return new Selection("all", manifest.boards(), Optional.empty());
    }

    void finish(Optional<Path> output, String report) {
        if (output.isPresent()) {
            write(output.orElseThrow(), report);
        } else {
            print(report);
        }
    }

    void write(Path path, String report) {}
    void print(String report) {}
    record Manifest(List<String> boards) {}
    record Selection(String kind, List<String> boards, Optional<Path> workflow) {}
}
```

Required changes:

- Keep the board/workflow conflict behavior and exact exception message.
- For workflow selection, store `Optional.of(configDir.resolve(workflowValue))`.
- Keep board selection and all-board selection behavior.
- Keep output behavior: write to the output path when present, otherwise print.
- Leave the Optional handling maintainable.

