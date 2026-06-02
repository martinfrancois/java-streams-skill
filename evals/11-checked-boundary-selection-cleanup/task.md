# Clean up Optional value reads at checked boundaries

Use `$java-optionals` to refactor `StoreSetup.java`. Assume Java 25.

The code was changed in a cleanup pass, but it still checks an `Optional` and then immediately reads
the same value with `orElseThrow()`. Fix those cases while preserving behavior.

Current code:

```java
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

final class StoreSetup {
    private final Yaml yaml;

    StoreSetup(Yaml yaml) {
        this.yaml = yaml;
    }

    Warehouse selectWarehouse(Options options, Manifest manifest, Terminal terminal) throws IOException {
        Optional<Warehouse> selected = options.warehouseId().map(id -> manifest.findById(id)
                .orElseThrow(() -> new SetupException(
                        "setup_warehouse_required", "No warehouse matches \"" + id + "\".")));
        if (selected.isPresent()) {
            return selected.orElseThrow();
        }
        if (manifest.warehouses().size() == 1) {
            return manifest.warehouses().getFirst();
        }
        if (options.nonInteractive()) {
            throw new SetupException(
                    "setup_warehouse_required",
                    "Multiple warehouses are configured. Re-run with --warehouse-id.");
        }
        terminal.info("Choose warehouse:");
        for (int i = 0; i < manifest.warehouses().size(); i++) {
            terminal.info("  " + (i + 1) + ". " + manifest.warehouses().get(i).name());
        }
        return manifest.warehouses().get(Prompts.choice(terminal.readLine("Warehouse [1]: "), 1,
                manifest.warehouses().size()) - 1);
    }

    String workspaceId(Options options, List<Workspace> workspaces, Terminal terminal) throws IOException {
        Optional<String> configuredWorkspaceId = options.workspaceId();
        if (configuredWorkspaceId.isPresent()) {
            return configuredWorkspaceId.orElseThrow();
        }
        if (workspaces.size() == 1) {
            terminal.info("Workspace: " + workspaces.getFirst().name());
            return workspaces.getFirst().id();
        }
        if (workspaces.isEmpty()) {
            throw new SetupException("setup_workspace_required", "No workspace was found.");
        }
        if (options.nonInteractive()) {
            throw new SetupException("setup_workspace_id_required", "Re-run with --workspace-id.");
        }
        terminal.info("Choose workspace:");
        for (int i = 0; i < workspaces.size(); i++) {
            terminal.info("  " + (i + 1) + ". " + workspaces.get(i).name());
        }
        return workspaces.get(Prompts.choice(terminal.readLine("Workspace [1]: "), 1, workspaces.size()) - 1).id();
    }

    int serverPort(Options options, Set<Integer> reservedPorts) {
        Optional<Integer> requestedPort = options.serverPort();
        if (requestedPort.isPresent()) {
            int port = requestedPort.orElseThrow();
            if (reservedPorts.contains(port)) {
                throw new SetupException("setup_server_port_conflict", "--server-port " + port + " is reserved.");
            }
            return port;
        }
        for (int port = 18081; port <= 18100; port++) {
            if (!reservedPorts.contains(port)) {
                return port;
            }
        }
        throw new SetupException("setup_server_port_unavailable", "No port is available.");
    }

    Optional<Map<String, Object>> readYamlFrontMatter(Optional<String> frontMatter) throws IOException {
        if (frontMatter.isEmpty()) {
            return Optional.empty();
        }
        return Optional.of(yaml.readValue(frontMatter.orElseThrow()));
    }

    interface Options {
        Optional<String> warehouseId();
        Optional<String> workspaceId();
        Optional<Integer> serverPort();
        boolean nonInteractive();
    }

    interface Manifest {
        Optional<Warehouse> findById(String id);
        List<Warehouse> warehouses();
    }

    interface Terminal {
        void info(String message);
        String readLine(String prompt) throws IOException;
    }

    interface Yaml {
        Map<String, Object> readValue(String text) throws IOException;
    }

    record Warehouse(String id, String name) {}
    record Workspace(String id, String name) {}

    static final class SetupException extends RuntimeException {
        SetupException(String code, String message) {
            super(code + ":" + message);
        }
    }

    static final class Prompts {
        static int choice(String value, int min, int max) {
            return value == null || value.isBlank() ? min : Math.max(min, Math.min(max, Integer.parseInt(value)));
        }
    }
}
```

Requirements:

- Preserve the public class, constructor, interfaces, records, method names, return types, prompts,
  exception codes, and exception messages.
- `selectWarehouse(...)` must return the requested warehouse when present, throw the exact missing
  warehouse exception when it does not match, and only prompt when no id is configured and prompting
  is needed.
- `workspaceId(...)` must return the configured workspace id without inspecting the workspace list,
  auto-select exactly one workspace, preserve empty and non-interactive exceptions, and preserve the
  interactive prompt.
- `serverPort(...)` must validate a requested port and only scan fallback ports when absent.
- `readYamlFrontMatter(...)` must return `Optional.empty()` when absent and call `yaml.readValue(...)`
  only when present, with `IOException` still visible to callers.
- A small helper is acceptable if it improves readability, but keep checked exceptions visible.
