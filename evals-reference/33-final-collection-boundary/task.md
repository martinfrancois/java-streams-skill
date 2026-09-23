# Clean up final collection boundaries

Refactor `ReservationDiscovery.java` where a stream can own the final result. Assume Java 17.

Return the revised Java code only.

```java
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

final class ReservationDiscovery {
    Set<Integer> localWorkflowFilePortReservations(Path configDir, ConnectedBoard ignoredBoard) {
        Set<Integer> reserved = new HashSet<>();
        if (configDir == null || !Files.isDirectory(configDir)) {
            return reserved;
        }
        try (var files = Files.list(configDir)) {
            List<Integer> workflowPorts = files.filter(Files::isRegularFile)
                    .filter(file -> file.getFileName().toString().endsWith(".md"))
                    .filter(file -> ignoredBoard.workflowPath() == null
                            || !file.equals(ignoredBoard.workflowPath()))
                    .map(this::serverPort)
                    .flatMap(Optional::stream)
                    .toList();
            reserved.addAll(workflowPorts);
        } catch (IOException ignored) {
            // Leave only manifest and probe checks.
        }
        return reserved;
    }

    void extendCleanupList(List<String> boardIds, Trello trello, String workspaceId, String runId) {
        try {
            List<String> openDisposableBoardIds = trello.openBoardIdsByNamePrefix(workspaceId, runId).stream()
                    .filter(boardId -> !boardIds.contains(boardId))
                    .toList();
            boardIds.addAll(openDisposableBoardIds);
        } catch (RuntimeException ignored) {
            // Cleanup is best effort.
        }
    }

    private Optional<Integer> serverPort(Path workflow) {
        return Optional.empty();
    }

    record ConnectedBoard(Path workflowPath) {}

    interface Trello {
        List<String> openBoardIdsByNamePrefix(String workspaceId, String runId);
    }
}
```

Preserve empty and unreadable-directory behavior. The cleanup list method intentionally extends an
existing mutable accumulator; avoid creating a temporary stream result whose only purpose is to be
copied into that accumulator.
