# Java Stream Examples

Use these examples for non-trivial stream refactors. They are reusable runtime guidance, not
scenario answers. Examples cover the full reference set; check the project Java baseline before
using APIs from [java-stream-api.md](java-stream-api.md).

## Direct Terminals

- Primary address when order does not matter:

  ```java
  Address primaryAddress = account.getAddresses().stream()
          .filter(Address::isPrimary)
          .findAny()
          .orElse(null);
  ```

- First fallback when order matters:

  ```java
  Optional<String> baseUrl = Stream.of(envUrl, systemPropertyUrl, configUrl)
          .filter(Objects::nonNull)
          .findFirst();
  ```

- Existence and permission checks:

  ```java
  boolean anyOutOfStock = order.getItems().stream()
          .anyMatch(item -> item.getStock() == 0);

  user.getRoles().stream()
          .flatMap(role -> role.getPermissions().stream())
          .filter(requiredPermission::equals)
          .findAny()
          .orElseThrow(AccessDeniedException::new);
  ```

- Flatten present optionals on Java 9+:

  ```java
  List<String> results = optionals.stream()
          .flatMap(Optional::stream)
          .collect(Collectors.toList());
  ```

## Mapping, Joining, Ranges, And Reductions

```java
String categories = products.stream()
        .map(Product::getCategory)
        .collect(Collectors.joining(", "));

Optional<Order> newestOrder = orders.stream()
        .max(Comparator.comparing(Order::getCreationDate));

List<Order> ordersList = IntStream.range(0, 50)
        .mapToObj(i -> new Order("Order #" + i))
        .collect(Collectors.toList());

BigDecimal total = orders.stream()
        .map(Order::getTotalAmount)
        .reduce(BigDecimal.ZERO, BigDecimal::add);
```

Use primitive streams for primitive totals:

```java
double totalRadius = shapes.stream()
        .filter(Circle.class::isInstance)
        .map(Circle.class::cast)
        .mapToDouble(Circle::getRadius)
        .sum();
```

Filter and cast to the subtype before primitive mapping. Do not map unrelated elements to `0` as a
sentinel just to make a primitive sum work.

## Sorting, Limiting, Counting, Distinct

```java
List<Product> favoriteProducts = user.getFavoriteProducts().stream()
        .filter(Product::isInStock)
        .sorted(Comparator.comparing(Product::getName))
        .collect(Collectors.toList());

List<Product> topThree = homepageProducts.stream()
        .sorted(Comparator.comparing(Product::getRating).reversed())
        .limit(3)
        .collect(Collectors.toList());

long unread = messageService.getMessages(customer).stream()
        .filter(Predicate.not(Message::isRead))
        .count();

List<String> discountCodes = orders.stream()
        .map(Order::getDiscountCode)
        .filter(Objects::nonNull)
        .distinct()
        .sorted()
        .toList();
```

Pitfall: natural sorting throws if null reaches the comparator. Filter nulls first or use
`Comparator.nullsFirst(...)` / `Comparator.nullsLast(...)`.

Pitfall: `Stream.toList()` returns an unmodifiable list. Keep `Collectors.toList()` or use
`Collectors.toCollection(ArrayList::new)` when the result is sorted, appended to, or otherwise
mutated later.

## Collectors

```java
Set<String> uniqueCodes = orders.stream()
        .map(Order::getDiscountCode)
        .collect(Collectors.toSet());

Map<String, Product> cheapestByCategory = products.stream()
        .filter(product -> product.getCategory() != null)
        .collect(Collectors.toMap(
                Product::getCategory,
                Function.identity(),
                BinaryOperator.minBy(Comparator.comparing(Product::getPrice))));

Map<String, List<Order>> ordersByCustomer = orders.stream()
        .collect(Collectors.groupingBy(Order::getCustomerId));

Map<String, List<String>> productNamesByCategory = products.stream()
        .collect(Collectors.groupingBy(
                Product::getCategory,
                Collectors.mapping(Product::getName, Collectors.toList())));

Map<String, Long> salesByItemName = orders.stream()
        .flatMap(order -> order.getItems().stream())
        .collect(Collectors.groupingBy(Item::getName, Collectors.counting()));

int totalQuantity = orders.stream()
        .flatMap(order -> order.getItems().stream())
        .collect(Collectors.summingInt(Item::getQuantity));

IntSummaryStatistics stats = orders.stream()
        .flatMap(order -> order.getItems().stream())
        .collect(Collectors.summarizingInt(Item::getQuantity));

Map<Boolean, List<Product>> partitionedProducts = products.stream()
        .collect(Collectors.partitioningBy(product -> product.getStock() > 0));
```

Java 12+ `teeing` can combine two reductions:

```java
Pair<Product, Product> priceRange = products.stream()
        .collect(Collectors.teeing(
                Collectors.minBy(Comparator.comparing(Product::getPrice)),
                Collectors.maxBy(Comparator.comparing(Product::getPrice)),
                (minOpt, maxOpt) -> new Pair<>(minOpt.orElse(null), maxOpt.orElse(null))));
```

## `mapMulti`, `takeWhile`, Parallel Streams, And Gatherers

Java 16+ `mapMulti` can be clearer for small conditional emission:

```java
Set<String> emailsWithoutTraining = companies.stream()
        .flatMap(company -> company.getEmployees().stream())
        .<String>mapMulti((employee, consumer) -> {
            if (employee instanceof Developer developer
                    && !developer.getSecureCodingTraining().isCompleted()) {
                consumer.accept(developer.getEmail());
            }
        })
        .collect(Collectors.toSet());
```

Java 9+ `takeWhile` is a prefix operation:

```java
List<Packet> beforeFirstSpike = packets.stream()
        .takeWhile(packet -> packet.getLoss() <= threshold)
        .collect(Collectors.toList());
```

Parallel streams can help CPU-heavy stateless work, but they remain blocking and use the common
fork-join pool by default. Recommend measuring or benchmarking the pipeline because split/merge
overhead and common-pool contention can outweigh the benefit:

```java
long result = LongStream.rangeClosed(1, 100_000)
        .parallel()
        .map(ParallelStreamDemo::heavyComputation)
        .sum();
```

For Java 24+ blocking per-element calls, `Gatherers.mapConcurrent` can be more appropriate than
`parallelStream` when the project intentionally uses virtual-thread concurrency. Keep concurrency
bounded and call out timeout/error handling for remote API failures:

```java
List<Product> favoriteProducts = user.getFavoriteProducts().stream()
        .gather(Gatherers.mapConcurrent(
                100,
                product -> Map.entry(product, product.isInStock())))
        .filter(Map.Entry::getValue)
        .map(Map.Entry::getKey)
        .sorted(Comparator.comparing(Product::getName))
        .toList();
```

`Map.entry` is appropriate in this example because the baseline is Java 24 and neither side of the
entry is null. If nulls can reach the carrier or the baseline is Java 8, use a null-tolerant project
type or `AbstractMap.SimpleImmutableEntry`.
