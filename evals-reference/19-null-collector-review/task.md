# Review nullable collector refactor

Use `$java-streams` to review this proposed change. Create `review.md` with a short decision and a
safer collector shape if the change should not be accepted.

Assume Java 17.

Before:

```java
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class CategoryIndex {
    Map<String, Product> cheapest(List<Product> products) {
        Map<String, Product> out = new HashMap<>();
        for (Product product : products) {
            if (product.category() == null) {
                continue;
            }
            Product current = out.get(product.category());
            if (current == null || product.price().compareTo(current.price()) < 0) {
                out.put(product.category(), product);
            }
        }
        return out;
    }

    record Product(String id, String category, BigDecimal price) {}
}
```

Proposed:

```java
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

final class CategoryIndex {
    Map<String, Product> cheapest(List<Product> products) {
        return products.stream()
                .collect(Collectors.toMap(Product::category, product -> product));
    }

    record Product(String id, String category, BigDecimal price) {}
}
```

Product categories may be null, and duplicate non-null categories are expected.
