# Implement price range and packet windows

Use `$java-streams` to create `PriceRangeAndPackets.java`. Assume Java 17.

Implement:

```java
Pair<Product, Product> priceRange(List<Product> products)
List<Packet> packetsBeforeFirstLossSpike(List<Packet> packets, double threshold)
List<Packet> packetsAfterInitialHealthyPrefix(List<Packet> packets, double threshold)
```

Rules:

- `priceRange` should return the cheapest and most expensive products. For an empty product list,
  both pair values should be `null`.
- `packetsBeforeFirstLossSpike` returns the chronological prefix where `loss <= threshold`.
- `packetsAfterInitialHealthyPrefix` skips the initial chronological prefix where `loss <= threshold`
  and returns the rest.

Use nested records:

```java
record Product(String name, BigDecimal price) {}
record Packet(long sequence, double loss) {}
record Pair<L, R>(L left, R right) {}
```
