# Audit customer stream helpers

Use `$java-streams` to audit this Java stream-heavy class with the hard-stop scan workflow. Create
`review.md`.

Assume Java 17.

In `review.md`, start with the exact scan header and hard-stop `rg` scan command from the skill
bundle, including the full marker regex and `<touched Java files>` placeholder. Then list every
hard-stop marker hit that should be changed, plus any marker hit that is acceptable and why. Keep
the review concise, but do not skip scan hits.

```java
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

final class CustomerStreams {
    boolean hasActive(List<Customer> customers) {
        return customers.stream()
                .filter(Customer::active)
                .count() > 0;
    }

    boolean missingPrimary(List<Customer> customers) {
        return customers.stream()
                .filter(Customer::primary)
                .collect(Collectors.toList())
                .isEmpty();
    }

    Optional<Customer> newest(List<Customer> customers) {
        return customers.stream()
                .sorted(Comparator.comparing(Customer::createdAt).reversed())
                .findFirst();
    }

    String displayNames(List<Customer> customers) {
        List<String> names = customers.stream()
                .map(Customer::displayName)
                .collect(Collectors.toList());
        return String.join(", ", names);
    }

    List<String> activeIds(List<Customer> customers, boolean addSummary) {
        List<String> ids = customers.stream()
                .filter(Customer::active)
                .map(Customer::id)
                .toList();
        if (addSummary) {
            ids.add("summary");
        }
        return ids;
    }

    Optional<Customer> configuredPrimary(List<Customer> customers) {
        return customers.parallelStream()
                .filter(Customer::primary)
                .findAny();
    }

    Map<String, Customer> byEmail(List<Customer> customers) {
        return customers.stream()
                .collect(Collectors.toMap(Customer::email, Function.identity()));
    }

    Map<String, List<Customer>> byRegion(List<Customer> customers) {
        return customers.stream()
                .collect(Collectors.groupingBy(Customer::region));
    }

    List<String> sortedDiscountCodes(List<Customer> customers) {
        return customers.stream()
                .map(Customer::discountCode)
                .sorted(Comparator.naturalOrder())
                .toList();
    }

    List<Customer> topThreeBySpend(List<Customer> customers) {
        return customers.stream()
                .limit(3)
                .sorted(Comparator.comparing(Customer::lifetimeSpend).reversed())
                .toList();
    }

    List<String> presentAliases(List<Optional<String>> aliases) {
        return aliases.stream()
                .filter(Optional::isPresent)
                .map(Optional::get)
                .toList();
    }

    BigDecimal totalSpend(List<Customer> customers) {
        return customers.stream()
                .map(Customer::lifetimeSpend)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    record Customer(
            String id,
            String email,
            String displayName,
            String region,
            String discountCode,
            boolean active,
            boolean primary,
            long createdAt,
            BigDecimal lifetimeSpend) {}
}
```

Domain notes:

- The `customers` list is in configured priority order.
- Duplicate emails can occur during account migration.
- `region` and `discountCode` can be null.
- `totalSpend` intentionally uses `BigDecimal`.
