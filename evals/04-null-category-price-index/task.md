# Convert price index loops

Create `PriceIndex.java` with the revised class. Assume Java 17.

The current implementation uses manual maps. Convert the obvious parts to streams where that stays
clear, but preserve all edge-case behavior.

```java
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class PriceIndex {
    Map<String, Product> cheapestByCategory(List<Product> products) {
        Map<String, Product> result = new HashMap<>();
        for (Product product : products) {
            if (product.category() == null) {
                continue;
            }
            Product current = result.get(product.category());
            if (current == null || product.price().compareTo(current.price()) < 0) {
                result.put(product.category(), product);
            }
        }
        return result;
    }

    Map<String, List<String>> namesByCategory(List<Product> products) {
        Map<String, List<String>> result = new HashMap<>();
        for (Product product : products) {
            if (product.category() == null) {
                continue;
            }
            result.computeIfAbsent(product.category(), ignored -> new ArrayList<>()).add(product.name());
        }
        return result;
    }

    record Product(String name, String category, BigDecimal price) {}
}
```

Requirements:

- Products with `null` category must be skipped.
- Duplicate categories are expected.
- `cheapestByCategory` keeps the cheapest product for each non-null category.
- `namesByCategory` preserves encounter order of product names inside each category list.
