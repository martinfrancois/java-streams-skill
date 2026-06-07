# Review parallel stream cache warmup

Assume Java 17.

Use `$java-streams` to review this proposed change. Create `review.md` with a short decision and a
safer stream chain if the change should not be accepted.

Before:

```java
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class ProductCache {
    Map<String, Product> warm(List<Product> products) {
        Map<String, Product> cache = new HashMap<>();
        for (Product product : products) {
            if (product.enabled()) {
                cache.put(product.id(), product);
            }
        }
        return cache;
    }

    record Product(String id, boolean enabled) {}
}
```

Proposed:

```java
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class ProductCache {
    Map<String, Product> warm(List<Product> products) {
        Map<String, Product> cache = new HashMap<>();
        products.parallelStream()
                .filter(Product::enabled)
                .forEach(product -> cache.put(product.id(), product));
        return cache;
    }

    record Product(String id, boolean enabled) {}
}
```
