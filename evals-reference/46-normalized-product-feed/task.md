# Finish product feed cleanup

Assume Java 17.

Use `$java-optionals` to create `CatalogFeed.java` with the revised class.

This is adapted from a real AI-written Java method that normalized raw records before filtering
them. The code works, but the product feed now needs one extra rule and the stream should be left
easy to maintain.

Current code:

```java
import java.util.List;
import java.util.Map;
import java.util.Optional;

final class CatalogFeed {
    List<ProductCard> visibleCards(List<Map<String, Object>> payloads, StoreContext context) {
        return payloads.stream()
                .map(payload -> normalize(payload, context))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .filter(card -> card.active() && !card.discontinued())
                .toList();
    }

    Optional<ProductCard> normalize(Map<String, Object> payload, StoreContext context) {
        String id = text(payload.get("id"));
        String title = text(payload.get("title"));
        String categoryId = text(payload.get("categoryId"));
        if (blank(id) || blank(title) || blank(categoryId)) {
            return Optional.empty();
        }
        return Optional.of(new ProductCard(
                id,
                title,
                categoryId,
                context.activeCategoryIds().contains(categoryId),
                Boolean.TRUE.equals(payload.get("discontinued"))));
    }

    private static String text(Object value) {
        return value == null ? null : value.toString();
    }

    private static boolean blank(String value) {
        return value == null || value.isBlank();
    }

    record StoreContext(List<String> activeCategoryIds, List<String> allowedCategoryIds) {}
    record ProductCard(String id, String title, String categoryId, boolean active, boolean discontinued) {}
}
```

Required changes:

- Keep `normalize(...)` returning `Optional<ProductCard>`.
- Keep skipping payloads that `normalize(...)` can't convert.
- Keep returning only active, non-discontinued cards.
- Add this rule: if `context.allowedCategoryIds()` isn't empty, return only cards in one of those categories.
- Keep the normalized-card stream readable.
