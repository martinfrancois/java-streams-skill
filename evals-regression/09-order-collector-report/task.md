# Implement order collector report

Use `$java-streams` to create `OrderCollectorReport.java`. Assume Java 17.

Implement:

```java
Report build(List<Order> orders, List<Product> products)
```

Rules:

- `cheapestByCategory` maps each category to the cheapest product in that category.
- `productNamesByCategory` maps each category to the product names in input encounter order.
- `salesByItemName` counts how many order line items have each item name.
- `quantityStats` contains count, sum, min, max, and average for all line item quantities.
- Return empty maps where inputs are empty. For an empty item stream, Java's normal
  `IntSummaryStatistics` empty values are acceptable.
- Keep the code concise and collector-oriented.

Use these nested records:

```java
record Product(String name, String category, BigDecimal price) {}
record Item(String name, int quantity) {}
record Order(String customerId, List<Item> items) {}
record Report(
        Map<String, Product> cheapestByCategory,
        Map<String, List<String>> productNamesByCategory,
        Map<String, Long> salesByItemName,
        IntSummaryStatistics quantityStats) {}
```
