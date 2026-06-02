# Refactor report output

Assume Java 17.

Use `$java-optionals` to improve this output handling. Create `ReportCommand.java` containing the
revised class:

```java
import java.nio.file.Path;
import java.util.Optional;

final class ReportCommand {
    void finish(Optional<Path> output, String report) {
        if (output.isPresent()) {
            write(output.orElseThrow(), report);
        } else {
            print(report);
        }
    }

    void write(Path path, String report) {}
    void print(String report) {}
}
```
