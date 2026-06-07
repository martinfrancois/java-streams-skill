# Implement product list transforms

Create `ProductListTransforms.java`. Assume Java 17.

Implement:

```java
List<Product> favoriteProductsInStock(User user)
List<Product> topThreeRated(List<Product> homepageProducts)
Set<String> uniqueDiscountCodes(List<Order> orders)
Map<Boolean, List<Product>> productsByAvailability(List<Product> products)
```

Rules:

- Favorite products should include only in-stock products and be sorted by product name.
- Top-three products should be the three highest-rated products, or fewer if fewer are available.
- Unique discount codes should include the codes from orders as a set.
- Product availability should be partitioned by `stock > 0`, with both boolean keys present.

Use nested records:

```java
record User(List<Product> favoriteProducts) {}
record Product(String name, double rating, int stock) {
    boolean inStock() { return stock > 0; }
}
record Order(String discountCode) {}
```
