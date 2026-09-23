# Preserve parser line splitting

Refactor `SourceDeclarations.java` to make the declaration extraction more stream-oriented without
changing the parser contract. Assume Java 17.

Return the revised Java code only.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class SourceDeclarations {
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
        for (String line : text.split("\\R", -1)) {
            Matcher labeled = LABELED_SOURCE.matcher(line);
            if (labeled.matches()) {
                declarations.add(new Declaration(labeled.group(1)));
            }
        }
    }

    record Card(String title, String description, List<Comment> comments) {}
    record Comment(String text) {}
    record Declaration(String value) {}
}
```

The existing parser recognizes Java regex `\R` line breaks. Preserve null and blank text behavior,
title/description/comment coverage, and unmodifiable returned-list behavior.
