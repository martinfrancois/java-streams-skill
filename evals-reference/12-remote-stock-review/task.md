# Review remote stock stream change

Assume Java 24 with preview features enabled.

Use `$java-streams` to review this proposed change. Create `review.md` with a short review decision
and a safer recommendation.

The product service calls a remote inventory API inside `isInStock(product)`.

Before:

```java
import java.util.Comparator;
import java.util.List;

final class FavoriteProducts {
    List<Product> favoriteProducts(User user) {
        return user.favoriteProducts().stream()
                .filter(this::isInStock)
                .sorted(Comparator.comparing(Product::name))
                .toList();
    }

    boolean isInStock(Product product) {
        return InventoryApi.check(product.sku());
    }

    record User(List<Product> favoriteProducts) {}
    record Product(String sku, String name) {}
}
```

Proposed:

```java
import java.util.Comparator;
import java.util.List;

final class FavoriteProducts {
    List<Product> favoriteProducts(User user) {
        return user.favoriteProducts().parallelStream()
                .filter(this::isInStock)
                .sorted(Comparator.comparing(Product::name))
                .toList();
    }

    boolean isInStock(Product product) {
        return InventoryApi.check(product.sku());
    }

    record User(List<Product> favoriteProducts) {}
    record Product(String sku, String name) {}
}
```
