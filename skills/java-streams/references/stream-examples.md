# Java Stream Examples

Use these examples for non-trivial stream refactors. They are reusable runtime guidance, not
scenario answers. Examples cover the full reference set; check the project Java baseline before
using APIs from [java-stream-api.md](java-stream-api.md).

## Direct Terminals

- Arbitrary match only when the domain explicitly says all matching domain values, such as
  primary/default/preferred values, are equivalent and encounter order does not matter:

  ```java
  Address selectedAddress = account.getAddresses().stream()
          .filter(Address::isEligible)
          .findAny()
          .orElse(null);
  ```

When a review asks whether to use `findFirst` or `findAny`, answer the semantic question first:
`findAny` is valid only if the domain explicitly says all matching domain values, such as
`primary`, `default`, or `preferred` values, are equivalent and encounter order does not select the
winner. For those names, write the exception with the code's noun, such as "all matching primary
addresses are equivalent." Do not infer equivalence from the name; if existing code takes element
`0`, preserve encounter order with `findFirst()`. Do not lead with performance or parallel-stream
wording for `findAny`.

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

  boolean allowed = user.getRoles().stream()
          .flatMap(role -> role.getPermissions().stream())
          .anyMatch(requiredPermission::equals);
  if (!allowed) {
      throw new AccessDeniedException();
  }
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

Pitfall: when de-duplication and sorting are both required, run `distinct()` before `sorted()`
unless the code depends on sorting before removing duplicates. In scan audits, treat
`sorted().distinct()` as a fix when `distinct().sorted()` preserves the result.

Pitfall: `Stream.toList()` returns an unmodifiable list. Keep `Collectors.toList()` or use
`Collectors.toCollection(ArrayList::new)` when the result is sorted, appended to, or otherwise
mutated later. If a task says `Stream.toList()` is not valid for that mutable result, do not wrap it
in `new ArrayList<>(...)`; use the mutable collector directly.

## External Mutation And Lambda Purity

Keep lambdas as short glue. If a stream operation needs branching, loops, temporary variables,
formatting, a merge rule, or a nested stream chain that would continue after the lambda line,
extract that work into a named method and pass a method reference or a concise one-expression
lambda whose body stays on the same line as `->`.

For predicate lambdas, any multi-check filter condition should be extracted to a named helper before
the stream boundary if readability is at stake:

```java
List<ShipmentNotice> overdueNotices(List<Shipment> shipments, Clock clock) {
    LocalDate today = LocalDate.now(clock);
    return shipments.stream()
            .filter(shipment -> isOverdue(shipment, today))
            .map(shipment -> toNotice(shipment, today))
            .toList();
}

private static boolean isOverdue(Shipment shipment, LocalDate today) {
    return shipment.deliveredAt().isEmpty() && shipment.dueDate().isBefore(today);
}

private static ShipmentNotice toNotice(Shipment shipment, LocalDate today) {
    long daysLate = ChronoUnit.DAYS.between(shipment.dueDate(), today);
    return new ShipmentNotice(
            shipment.id(),
            shipment.customerEmail(),
            daysLate,
            daysLate >= 14 ? "critical" : "late");
}
```

Avoid burying derivation logic in a block lambda:

```java
List<TicketEscalation> escalations = tickets.stream()
        .filter(Ticket::isOpen)
        .map(ticket -> {
            Duration age = Duration.between(ticket.openedAt(), now);
            EscalationLevel level = levelFor(ticket.priority(), age);
            return new TicketEscalation(ticket.id(), ticket.assignee(), level, age);
        })
        .toList();
```

Extract the logic so the stream chain stays readable and the helper can be tested directly:

```java
List<TicketEscalation> escalations = tickets.stream()
        .filter(Ticket::isOpen)
        .map(ticket -> escalationFor(ticket, now))
        .toList();

private static TicketEscalation escalationFor(Ticket ticket, Instant now) {
    Duration age = Duration.between(ticket.openedAt(), now);
    EscalationLevel level = levelFor(ticket.priority(), age);
    return new TicketEscalation(ticket.id(), ticket.assignee(), level, age);
}
```

This is required even when the helper only builds one output record: temporary values and branching
inside `map(x -> { ... })` are not glue.

Avoid wrapping a nested stream body inside a collector callback:

```java
Map<String, List<String>> openCaseIdsByOwner = accounts.stream()
        .collect(Collectors.groupingBy(
                Account::ownerTeam,
                Collectors.flatMapping(
                        account -> account.supportCases().stream()
                                .filter(SupportCase::isOpen)
                                .map(SupportCase::caseId),
                        Collectors.toList())));
```

Extract the nested stream so the collector reads as composition:

```java
Map<String, List<String>> openCaseIdsByOwner = accounts.stream()
        .collect(Collectors.groupingBy(
                Account::ownerTeam,
                Collectors.flatMapping(
                        AccountCaseReports::openCaseIds,
                        Collectors.toList())));

private static Stream<String> openCaseIds(Account account) {
    return account.supportCases().stream()
            .filter(SupportCase::isOpen)
            .map(SupportCase::caseId);
}
```

The same rule applies to downstream `flatMapping` for sorted or de-duplicated nested data. Keep the
collector callback as a method reference:

```java
Map<String, List<String>> emailsByTrack = conferences.stream()
        .flatMap(conference -> conference.sessions().stream())
        .filter(session -> session.track() != null)
        .collect(Collectors.groupingBy(
                Session::track,
                Collectors.flatMapping(
                        SessionReports::optedInEmails,
                        Collectors.collectingAndThen(
                                Collectors.toCollection(TreeSet::new),
                                ArrayList::new))));

private static Stream<String> optedInEmails(Session session) {
    return session.registrations().stream()
            .filter(Registration::optedIn)
            .map(Registration::email)
            .filter(Objects::nonNull);
}
```

Do not build ordinary stream results by mutating external state from `forEach`:

```java
List<String> labels = new ArrayList<>();
orders.stream()
        .map(Order::label)
        .forEach(labels::add);
```

Make the stream produce the result directly:

```java
List<String> labels = orders.stream()
        .map(Order::label)
        .toList();
```

Use `collect(Collectors.toList())` instead when the Java baseline is below 16 or the result must be
mutable. The direct collector/toList form is the default correctness and readability fix, not a
guaranteed throughput win. It may only marginally affect throughput by itself, but it removes shared
mutation and gives a safe baseline for benchmarking. Explain the rewrite in terms of ownership and
correctness first; discuss low-level allocation details only when measurements make them relevant.
Do not claim the original `ArrayList` resizing is `O(N^2)`; ordinary growth is amortized O(N) total.

This parallel version is broken because it mutates a shared `ArrayList` from multiple workers:

```java
List<String> labels = new ArrayList<>();
orders.parallelStream()
        .map(Order::label)
        .forEach(labels::add);
```

In reviews, make the snippet the sequential direct-collection form unless the user explicitly asks
for parallel code. This removes shared mutation and creates a safe baseline; it is not proof that
the pipeline is faster. Keep the performance decision separate: for large CPU-bound transformations,
recommend benchmarking a side-effect-free parallel stream in prose before relying on it for speed.
Put that benchmark requirement next to the parallel mention, and warn that small lists or
mostly-small call paths can be slower because splitting, merging, ordering, and common-pool
contention can outweigh the benefit. Do not call the speedup expected, significant, proportional to
available cores, or likely before measurements show it. Do not invent benchmark tables, ratios,
timing numbers, or a parallel code block; tell the reader to benchmark the real workload instead.
For "10 million item" examples, still use this same structure: correctness snippet first,
benchmark-only parallel prose second, and no scaling claims without measured results.

Useful review wording for this pattern:

```text
The first fix is to remove the external mutation; let the stream produce the list directly.
For throughput, benchmark the sequential version against a pure side-effect-free parallel stream on
the real workload before relying on parallelStream. `parallelStream()` can be slower for small lists
or mostly-small call paths.
```

Do not include optional parallelism snippets for this pattern unless the user explicitly requests
parallel code. If requested, avoid multiline lambda bodies and prefer method references or
single-line helpers.

Only keep terminal `forEach` when the side effect is the operation's purpose, such as logging or
calling an API, and the side effect is safe for the chosen stream mode.

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

If a `groupingBy` classifier can return null, filter nulls or map them to an explicit non-null key
before collecting. Do not treat possible null classifier keys as acceptable without proof.
If a loop skipped null keys before building a map, filter those null keys before `toMap`; the issue
is the behavior change, not a guaranteed null-key `NullPointerException`.
When a review includes a collector replacement snippet, include the supporting imports for helper
APIs such as `Function.identity()` or `BinaryOperator.minBy(...)`, and avoid tangential import
commentary unless missing imports are part of the stream issue.

For nested data indexes with duplicate-key rules, prefer flattening first and expressing the merge
in the collector:

```java
Map<String, Session> longestSessionByRoom = conferences.stream()
        .flatMap(conference -> conference.sessions().stream())
        .filter(session -> session.room() != null)
        .collect(Collectors.toMap(
                Session::room,
                Function.identity(),
                SessionIndexes::longerSession));
```

Extract the merge helper when tie-breaking takes more than a same-line expression, especially when
encounter order must decide equal values.

```java
private static Session longerSession(Session first, Session second) {
    return first.minutes() >= second.minutes() ? first : second;
}
```

When a task says to use nested records or helper types in the requested file, keep those types in
that file instead of splitting them into separate top-level files.

Java 12+ `teeing` can combine two independent reductions over the same input. Prefer this for a
min/max pair or price range instead of running two separate stream passes:

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
        .<String>mapMulti(TrainingReports::emitDeveloperEmailWithoutTraining)
        .collect(Collectors.toSet());

private static void emitDeveloperEmailWithoutTraining(Employee employee, Consumer<String> emails) {
    if (employee instanceof Developer developer
            && !developer.getSecureCodingTraining().isCompleted()) {
        emails.accept(developer.getEmail());
    }
}
```

For primitive subtype extraction, avoid emitting boxed primitives only to unbox them later:

```java
double totalCircleRadius = shapes.stream()
        .filter(Circle.class::isInstance)
        .map(Circle.class::cast)
        .mapToDouble(Circle::radius)
        .sum();
```

Java 9+ `takeWhile` is a prefix operation:

```java
List<Packet> beforeFirstSpike = packets.stream()
        .takeWhile(packet -> packet.getLoss() <= threshold)
        .collect(Collectors.toList());
```

Parallel streams can help CPU-heavy stateless work, but they remain blocking and use the common
fork-join pool by default. Recommend measuring or benchmarking the stream chain because split/merge
overhead and common-pool contention can outweigh the benefit:

```java
long result = LongStream.rangeClosed(1, 100_000)
        .parallel()
        .map(ParallelStreamDemo::heavyComputation)
        .sum();
```

For Java 24+ projects, use bounded `Gatherers.mapConcurrent` for blocking per-element calls when the
task gives a concurrency limit and the project intentionally uses virtual-thread concurrency. Keep
existing helper methods that encode behavior:

```java
List<Product> favoriteProducts = user.getFavoriteProducts().stream()
        .gather(Gatherers.mapConcurrent(
                100,
                product -> Map.entry(product, isInStock(product))))
        .filter(Map.Entry::getValue)
        .map(Map.Entry::getKey)
        .sorted(Comparator.comparing(Product::getName))
        .toList();
```

`Map.entry` is appropriate in this example because the baseline is Java 24 and neither side of the
entry is null. Do not return `null` from a `mapConcurrent` mapper to mean "skip"; carry the element
with an explicit boolean result, then filter and map afterward. If nulls can reach the carrier or
the baseline is Java 8, use a null-tolerant project type or `AbstractMap.SimpleImmutableEntry`.
When the task provides a production service stub such as `AvailabilityApi.lookup(...)` or
`CalendarService.canSchedule(...)`, call that stub directly. Do not add delegate fields, alternate
overloads, package-private switches, or other test hooks unless the task explicitly asks for them.
Do not replace a bounded `mapConcurrent` stream with `CompletableFuture` fan-out when the task asks
for stream APIs.
