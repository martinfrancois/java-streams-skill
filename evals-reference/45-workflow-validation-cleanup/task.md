# Finish workflow validation cleanup

Assume Java 17.

Use `$java-optionals` to create `WorkflowConfigValidation.java` with the revised class.

This is adapted from a real AI-assisted maintainability cleanup. The original task was a broad
readability/refactor pass that had to preserve the same behavior. The code below works, but the
validation method should be easier to maintain.

Current code:

```java
import java.nio.file.Path;
import java.util.Map;
import java.util.Optional;

final class WorkflowConfigValidation {
    WorkflowValidation validate(ConnectedBoard board, Map<String, Object> yaml) {
        Optional<String> configuredBoardId = boardId(yaml);
        if (configuredBoardId.isEmpty()) {
            return WorkflowValidation.warn("Workflow file is missing tracker.board_id for \""
                    + board.boardName() + "\": " + board.workflowPath());
        }
        String boardId = configuredBoardId.orElseThrow();
        if (!boardId.equals(board.boardId()) && !boardId.equals(board.boardKey())) {
            return WorkflowValidation.warn("Workflow tracker.board_id does not match the connected board for \""
                    + board.boardName() + "\": expected " + board.boardId() + " or " + board.boardKey()
                    + " but found " + boardId);
        }
        Optional<Integer> configuredServerPort = serverPort(yaml);
        if (configuredServerPort.isEmpty()) {
            return WorkflowValidation.warn("Workflow file is missing server.port for \""
                    + board.boardName() + "\": " + board.workflowPath());
        }
        if (configuredServerPort.orElseThrow() != board.serverPort()) {
            return WorkflowValidation.warn("Workflow server.port does not match the connected board for \""
                    + board.boardName() + "\": expected " + board.serverPort() + " but found "
                    + configuredServerPort.orElseThrow());
        }
        return WorkflowValidation.valid();
    }

    Optional<String> boardId(Map<String, Object> yaml) {
        Object trackerValue = yaml.get("tracker");
        if (!(trackerValue instanceof Map<?, ?> tracker)) {
            return Optional.empty();
        }
        Object value = tracker.get("board_id");
        String text = value == null ? null : String.valueOf(value);
        return text == null || text.isBlank() ? Optional.empty() : Optional.of(text);
    }

    Optional<Integer> serverPort(Map<String, Object> yaml) {
        Object serverValue = yaml.get("server");
        if (!(serverValue instanceof Map<?, ?> server)) {
            return Optional.empty();
        }
        Object value = server.get("port");
        if (value instanceof Number number) {
            return Optional.of(number.intValue());
        }
        if (value instanceof String text && !text.isBlank()) {
            try {
                return Optional.of(Integer.parseInt(text.trim()));
            } catch (NumberFormatException ignored) {
                return Optional.empty();
            }
        }
        return Optional.empty();
    }

    record ConnectedBoard(String boardName, String boardId, String boardKey, int serverPort, Path workflowPath) {}

    record WorkflowValidation(boolean ok, String message) {
        static WorkflowValidation valid() { return new WorkflowValidation(true, ""); }
        static WorkflowValidation warn(String message) { return new WorkflowValidation(false, message); }
    }
}
```

Required changes:

- Keep the same warning messages and successful `WorkflowValidation.valid()` result.
- Keep accepting `board.boardId()` and `board.boardKey()` as matching tracker board ids.
- Keep accepting numeric server ports and trimmed numeric string server ports.
- Return the missing-board warning when `tracker.board_id` is absent or blank.
- Return the missing-port warning when `server.port` is absent, blank, malformed, or unsupported.
- Leave `boardId(...)` and `serverPort(...)` returning `Optional`.
- You may extract private helpers if that makes the validation flow clearer.
