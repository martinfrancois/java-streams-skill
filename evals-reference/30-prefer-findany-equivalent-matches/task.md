# Audit Optional stream terminals

Refactor `LookupTerminals.java` only where the terminal operation's contract is clearer. Assume Java 17.

Return the revised Java code and one brief comment beside each retained `findFirst()` explaining
why the first match is semantically required.

```java
import java.nio.file.Path;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

final class LookupTerminals {
    static Optional<String> detectedList(List<String> openListNames, String expectedName) {
        return openListNames.stream()
                .filter(name -> name.equalsIgnoreCase(expectedName))
                .findFirst();
    }

    static Optional<BoardList> targetList(List<BoardList> lists, String configuredName) {
        String expected = normalize(configuredName);
        return lists.stream()
                .filter(list -> !list.closed())
                .filter(list -> normalize(list.name()).equals(expected))
                .findFirst();
    }

    static Optional<Path> firstExistingPath(List<Path> searchPath, String commandName) {
        return searchPath.stream()
                .map(path -> path.resolve(commandName))
                .filter(path -> path.toFile().exists())
                .findFirst();
    }

    static Optional<String> firstVersionLine(String output) {
        return output.lines()
                .map(String::stripLeading)
                .filter(line -> line.startsWith("java "))
                .findFirst();
    }

    private static String normalize(String value) {
        return value.toLowerCase(Locale.ROOT).replaceAll("\\s+", " ").strip();
    }

    record BoardList(String id, String name, boolean closed) {}
}
```
