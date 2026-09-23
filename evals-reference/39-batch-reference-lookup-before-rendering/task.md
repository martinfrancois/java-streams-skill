# Separate batch lookup from rendering

Refactor `ReferenceRenderer.java` to avoid hidden repeated lookups while keeping writes explicit.
Assume Java 17.

Return the revised Java snippets only.

```java
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

final class ReferenceRenderer {
    List<Card> enrich(List<Card> cards, boolean includeReferenceContext) {
        Map<String, Plan> plans = new LinkedHashMap<>();
        for (Card card : cards) {
            plans.put(card.id(), plan(card));
        }
        List<Card> enriched = new ArrayList<>();
        for (Card card : cards) {
            Plan plan = plans.get(card.id());
            List<RenderedReference> references =
                    includeReferenceContext ? promptReferences(card, plan, Map.of()) : List.of();
            syncChecklist(card, plan);
            enriched.add(card.withReferences(references));
        }
        return enriched;
    }

    private List<RenderedReference> promptReferences(Card card, Plan plan, Map<String, LookupResult> known) {
        Map<String, ReferenceText> references = referenceTexts(card, plan);
        List<String> missing = references.values().stream()
                .map(ReferenceText::lookupId)
                .filter(id -> !known.containsKey(id))
                .distinct()
                .toList();
        Map<String, LookupResult> lookupResults = new LinkedHashMap<>(known);
        lookupResults.putAll(fetchCardStatesByIds(missing));
        return references.values().stream()
                .map(reference -> render(reference, lookupResults.get(reference.lookupId())))
                .toList();
    }

    private Plan plan(Card card) { return new Plan(card.references()); }
    private Map<String, ReferenceText> referenceTexts(Card card, Plan plan) { return Map.of(); }
    private Map<String, LookupResult> fetchCardStatesByIds(List<String> ids) { return Map.of(); }
    private RenderedReference render(ReferenceText reference, LookupResult result) { return new RenderedReference(); }
    private void syncChecklist(Card card, Plan plan) {}

    record Card(String id, List<ReferenceText> references) {
        Card withReferences(List<RenderedReference> references) { return this; }
    }
    record Plan(List<ReferenceText> references) {}
    record ReferenceText(String key, String lookupId) {}
    record LookupResult(String state) {}
    record RenderedReference() {}
}
```

The lookup method is a network boundary. Keep checklist synchronization explicit and outside stream
pipelines.
