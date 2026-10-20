# Clean up the library search query builder

Create `LibrarySearchQuery.java` with the revised class. Assume Java 17.

The library's search front end turns each facet into a clause such as
`subject:("whales" OR "sea stories")`. The query-building code below produces the right output,
but the team finds it harder to read than it should be. Clean it up while keeping the output
byte-for-byte identical.

```java
import java.util.List;

final class LibrarySearchQuery {
    String facetClause(SearchFacet facet) {
        return facet.field() + ":(" + anyOf(facet.terms()) + ")";
    }

    String anyOf(List<String> searchTerms) {
        return searchTerms.stream()
                .map(LibrarySearchQuery::quoteTerm)
                .reduce("", (query, term) -> {
                    if (query.isEmpty()) {
                        return term;
                    }
                    return query + " OR " + term;
                });
    }

    private static String quoteTerm(String term) {
        return '"' + term.replace("\"", "\\\"") + '"';
    }

    record SearchFacet(String field, List<String> terms) {}
}
```

Behavior to keep:

- An empty term list produces `""`, so `facetClause` returns `field:()`.
- Terms appear in list order, each wrapped in double quotes with inner double quotes escaped.
- An empty search term is legal and must still appear in the query as `""`, with the separators
  around it, wherever it sits in the list, including first.
- A `null` term must still fail with `NullPointerException`.

After the code, state in a few sentences why the revised version produces the same string for
every input, including a list whose first term is empty.
