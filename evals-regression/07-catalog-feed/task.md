# Clean up catalog feed

Use `$java-streams` to create `CatalogFeed.java` with the revised class. Assume Java 17.

The current code works for the happy path, but it is clumsy and has edge cases. Preserve the public
method names and behavior where specified.

```java
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

final class CatalogFeed {
    List<Card> visibleCards(List<Map<String, Object>> payloads) {
        return payloads.stream()
                .map(this::normalize)
                .filter(Optional::isPresent)
                .map(Optional::get)
                .filter(card -> card.active() && !card.discontinued())
                .collect(Collectors.toList());
    }

    List<String> sortedDiscountCodes(List<Order> orders) {
        Set<String> codes = new HashSet<>();
        for (Order order : orders) {
            codes.add(order.discountCode());
        }
        List<String> list = new ArrayList<>(codes);
        list.sort(Comparator.naturalOrder());
        return list;
    }

    Map<String, Product> cheapestByCategory(List<Product> products) {
        Map<String, Product> result = new HashMap<>();
        for (Product product : products) {
            if (!result.containsKey(product.category())
                    || product.price().compareTo(result.get(product.category()).price()) < 0) {
                result.put(product.category(), product);
            }
        }
        return result;
    }

    Optional<Card> normalize(Map<String, Object> payload) {
        Object id = payload.get("id");
        Object active = payload.get("active");
        Object discontinued = payload.get("discontinued");
        if (id instanceof String && active instanceof Boolean && discontinued instanceof Boolean) {
            return Optional.of(new Card((String) id, (Boolean) active, (Boolean) discontinued));
        }
        return Optional.empty();
    }

    record Card(String id, boolean active, boolean discontinued) {}
    record Order(String discountCode) {}
    record Product(String name, String category, BigDecimal price) {}
}
```

Requirements:

- `visibleCards` should skip payloads that cannot normalize and keep only active, not discontinued cards.
- `sortedDiscountCodes` should return unique non-null discount codes in natural sorted order.
- `cheapestByCategory` should keep the cheapest product for each category and must not fail for
  duplicate categories.
