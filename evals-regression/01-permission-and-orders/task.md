# Implement stream helper methods

Use `$java-streams` to create `StreamHelpers.java`. Assume Java 17.

Implement:

```java
void requirePermission(User user, String requiredPermission)
List<Order> createOrders()
BigDecimal totalOrderAmount(List<Order> orders)
double totalCircleRadius(List<Shape> shapes)
```

Rules:

- `requirePermission` should return normally when any role has the required permission and throw
  `AccessDeniedException` otherwise.
- `createOrders` should create 50 orders named `Order #0` through `Order #49`.
- `totalOrderAmount` should sum `Order.totalAmount`.
- `totalCircleRadius` should sum radii only for `Circle` instances.

Use nested types:

```java
record User(List<Role> roles) {}
record Role(List<String> permissions) {}
record Order(String name, BigDecimal totalAmount) {
    Order(String name) { this(name, BigDecimal.ZERO); }
}
interface Shape {}
record Circle(double radius) implements Shape {}
record Rectangle(double width, double height) implements Shape {}
static final class AccessDeniedException extends RuntimeException {}
```
