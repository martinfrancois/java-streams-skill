# Remove unnecessary temporary mutability

Refactor `ManifestUpdate.java` where doing so improves readability without changing behavior.
Assume Java 17.

Return the revised Java code only.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

record ConnectedBoardManifest(List<ConnectedBoard> boards) {
    ConnectedBoardManifest {
        boards = List.copyOf(boards);
    }

    ConnectedBoardManifest withBoard(ConnectedBoard board) {
        List<ConnectedBoard> updated = new ArrayList<>(boards.stream()
                .filter(existing -> !sameBoardOrWorkflow(existing, board))
                .toList());
        updated.add(board);
        return new ConnectedBoardManifest(updated);
    }

    ConnectedBoardManifest withOptionalSections(List<ConnectedBoard> selected, boolean includeArchived) {
        List<ConnectedBoard> updated = new ArrayList<>();
        for (ConnectedBoard board : selected) {
            if (!board.archived() || includeArchived) {
                updated.add(board);
            }
        }
        if (includeArchived) {
            updated.add(new ConnectedBoard("archive-summary", null, true));
        }
        return new ConnectedBoardManifest(updated);
    }

    private static boolean sameBoardOrWorkflow(ConnectedBoard left, ConnectedBoard right) {
        return left.boardId().equals(right.boardId())
                || left.workflowPath() != null && left.workflowPath().equals(right.workflowPath());
    }
}

record ConnectedBoard(String boardId, String workflowPath, boolean archived) {}
```

The manifest constructor copies its input. Preserve encounter order, filtering, duplicate handling,
and public API shape. Only refactor the simple temporary append-buffer case when the stream result
stays readable; leave the conditional builder method imperative if the current loop is clearer than a
dense stream expression.
