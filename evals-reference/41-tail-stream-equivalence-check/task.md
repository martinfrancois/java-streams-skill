# Avoid eager work before allMatch

Refactor `DeclarationConflict.java`. Assume Java 17.

Return the revised Java code only.

```java
import java.util.ArrayList;
import java.util.List;

final class DeclarationConflict {
    RepositorySourceSelection explicitSource(List<Declaration> declarations) {
        if (declarations.isEmpty()) {
            return RepositorySourceSelection.none();
        }
        if (declarations.size() == 1) {
            Declaration declaration = declarations.get(0);
            return parse(declaration.value(), declaration.mode());
        }
        List<RepositorySourceSelection> parsed = new ArrayList<>(declarations.size());
        for (Declaration declaration : declarations) {
            parsed.add(parse(declaration.value(), declaration.mode()));
        }
        RepositorySourceSelection first = parsed.get(0);
        if (first.selected()
                && parsed.stream().allMatch(selection -> equivalent(first, selection))) {
            return first;
        }
        return RepositorySourceSelection.invalid("repository_source_conflict");
    }

    private RepositorySourceSelection parse(String value, SourceMode mode) {
        return new RepositorySourceSelection(value, mode, value != null && !value.isBlank());
    }

    private static boolean equivalent(RepositorySourceSelection expected, RepositorySourceSelection actual) {
        return actual.selected()
                && expected.value().equals(actual.value())
                && expected.mode() == actual.mode();
    }

    enum SourceMode { REMOTE, LOCAL }
    record Declaration(String value, SourceMode mode) {}
    record RepositorySourceSelection(String value, SourceMode mode, boolean selected) {
        static RepositorySourceSelection none() { return new RepositorySourceSelection("", SourceMode.REMOTE, false); }
        static RepositorySourceSelection invalid(String code) { return new RepositorySourceSelection(code, SourceMode.REMOTE, false); }
    }
}
```

Multiple declarations are valid only when the first parses to a selected source and every remaining
declaration parses to an equivalent selected source. Preserve fail-closed conflict behavior.
