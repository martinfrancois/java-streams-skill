# Clean up Optional list flow

Refactor `StoreSetup.java`. The current cleanup cheated by doing `stream().toList()` in a bunch of
places on `Optional` values instead of using `isPresent()` and `orElseThrow()` or similar. Solve it
properly. Assume Java 17.

Current code:

```java
import java.io.IOException;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

final class StoreSetup {
    private final Yaml yaml;

    StoreSetup(Yaml yaml) {
        this.yaml = yaml;
    }

    String warehouseId(Options options, Terminal terminal) throws IOException {
        for (String warehouseId : options.warehouseId().stream().toList()) {
            return warehouseId;
        }
        return terminal.readLine("Warehouse: ");
    }

    int serverPort(Options options, Set<Integer> reservedPorts) {
        for (Integer port : options.serverPort().stream().toList()) {
            return validateRequestedPort(port, reservedPorts);
        }
        return nextAvailablePort(reservedPorts);
    }

    Optional<Map<String, Object>> readYamlFrontMatter(Optional<String> frontMatter) throws IOException {
        for (String yamlText : frontMatter.stream().toList()) {
            return Optional.of(yaml.readValue(yamlText));
        }
        return Optional.empty();
    }

    private int validateRequestedPort(int port, Set<Integer> reservedPorts) {
        if (reservedPorts.contains(port)) {
            throw new IllegalArgumentException("reserved port: " + port);
        }
        return port;
    }

    private int nextAvailablePort(Set<Integer> reservedPorts) {
        for (int port = 18081; port <= 18100; port++) {
            if (!reservedPorts.contains(port)) {
                return port;
            }
        }
        throw new IllegalStateException("no port available");
    }

    interface Options {
        Optional<String> warehouseId();
        Optional<Integer> serverPort();
    }

    interface Terminal {
        String readLine(String prompt) throws IOException;
    }

    interface Yaml {
        Map<String, Object> readValue(String text) throws IOException;
    }
}
```

Requirements:

- Keep the same public class, constructor, interfaces, method names, return types, prompts, and
  exception behavior.
- `warehouseId(...)` must return `options.warehouseId()` when present without prompting. It must
  prompt with `terminal.readLine("Warehouse: ")` only when absent.
- `serverPort(...)` must validate a requested port when present. It must search for the next
  available port only when absent.
- `readYamlFrontMatter(...)` must return `Optional.empty()` when absent and parse present YAML with
  `yaml.readValue(...)`.
- Preserve the checked `IOException` behavior from `terminal.readLine(...)` and
  `yaml.readValue(...)`.
