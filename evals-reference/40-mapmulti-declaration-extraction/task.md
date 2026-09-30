# Improve declaration extraction

Refactor `DeclarationExtractor.java` for a Java 25 codebase. Assume Java 25.

Return the revised Java code only.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class DeclarationExtractor {
    private static final Pattern LABELED_SOURCE = Pattern.compile("(?i)^source[\\t ]*:[\\t ]*(.*)$");

    static List<Declaration> declarations(Card card) {
        List<Declaration> declarations = new ArrayList<>();
        addDeclarations(declarations, card.title());
        addDeclarations(declarations, card.description());
        card.comments().stream()
                .map(Comment::text)
                .forEach(text -> addDeclarations(declarations, text));
        return List.copyOf(declarations);
    }

    private static void addDeclarations(List<Declaration> declarations, String text) {
        if (text == null || text.isBlank()) {
            return;
        }
        text.lines().forEach(line -> addDeclaration(declarations, line));
    }

    private static void addDeclaration(List<Declaration> declarations, String line) {
        Matcher labeled = LABELED_SOURCE.matcher(line);
        if (labeled.matches()) {
            declarations.add(new Declaration(labeled.group(1)));
        }
    }

    record Card(String title, String description, List<Comment> comments) {}
    record Comment(String text) {}
    record Declaration(String value) {}
}
```

Each nonblank text block can contain zero or more declaration lines. Preserve title, description,
comments, matching with `matches()`, and the unmodifiable result.

For the line-to-zero-or-one declaration transformation, prefer a Java 25 stream shape using
`mapMulti` or a small `Consumer` emitter helper rather than a side-effecting `forEach`, `filter`
plus `map`, or tiny `Stream.of`/`Stream.empty` helpers.
