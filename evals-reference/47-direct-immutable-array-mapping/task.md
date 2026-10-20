# Simplify manuscript keyword lookups

Create `ManuscriptKeywords.java` with the revised class. Assume Java 17.

The publishing team's manuscript parser stores each draft's keywords as a `String[]`, or `null`
when the draft has no keyword block. The class below works, but a reviewer flagged the keyword
conversion as more ceremony than it needs. Simplify it without changing behavior.

```java
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

final class ManuscriptKeywords {
    private final Map<String, ManuscriptDraft> draftsById;

    ManuscriptKeywords(Map<String, ManuscriptDraft> draftsById) {
        this.draftsById = Map.copyOf(draftsById);
    }

    Optional<List<String>> keywordsFor(String draftId) {
        return Optional.ofNullable(draftsById.get(draftId))
                .map(ManuscriptDraft::keywords)
                .map(words -> List.copyOf(Arrays.asList(words)));
    }

    List<List<String>> keywordSets(List<ManuscriptDraft> drafts) {
        return drafts.stream()
                .map(ManuscriptDraft::keywords)
                .filter(words -> words != null)
                .map(words -> List.copyOf(Arrays.asList(words)))
                .toList();
    }

    record ManuscriptDraft(String draftId, String title, String[] keywords) {}
}
```

Callers rely on this contract, so keep all of it:

- `keywordsFor` returns an empty `Optional` for an unknown draft id and for a draft whose
  `keywords` array is `null`.
- `keywordSets` skips drafts whose `keywords` array is `null` and keeps the order of `drafts`.
- Each returned keyword list keeps the array's order and is unmodifiable.
- A returned list must not change when the parser later overwrites entries in the source array.
- A `null` entry inside a keywords array must still fail with `NullPointerException`.
- An empty keywords array produces an empty list, not an empty `Optional` and not a skipped draft.

After the code, state in a few sentences why the revised version keeps each of these rules.
