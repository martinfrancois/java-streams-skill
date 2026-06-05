# Implement favorite product stock checks

Create `FavoriteProducts.java`. Assume Java 24.

Implement:

```java
List<Product> favoriteProducts(User user)
```

Rules:

- `user.favoriteProducts()` returns products in user preference order.
- `InventoryApi.check(product.sku())` is a blocking remote call.
- Users can have hundreds of favorite products, and checking stock one product at a time is too slow in production.
- The concurrency limit is per `favoriteProducts(user)` call: during one call, run at most 8
  in-flight `InventoryApi.check(...)` calls at the same time.
- Return only products that are in stock.
- Sort the returned products by `Product::name`.
- Use Java stream APIs for the pipeline.

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
