# Implement favorite product stock checks

Create `FavoriteProducts.java`. Assume Java 24.

Implement:

```java
List<Product> favoriteProducts(User user)
```

Rules:

- `user.favoriteProducts()` returns products in user preference order.
- `InventoryApi.check(product.sku())` is a blocking remote call.
- Return only products that are in stock.
- Sort the returned products by `Product::name`.
- Use Java stream APIs for the pipeline.
- Avoid `parallelStream()` and avoid unbounded concurrency.
- Keep the concurrency limit explicit in code.

Use these nested types:

```java
record User(List<Product> favoriteProducts) {}
record Product(String sku, String name) {}
static final class InventoryApi {
    static boolean check(String sku) {
        throw new UnsupportedOperationException("provided by production");
    }
}
```
