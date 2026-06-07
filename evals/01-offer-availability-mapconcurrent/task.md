# Implement offer availability filtering

Use `$java-streams` to create `OfferAvailability.java`. Assume Java 24.

Implement:

```java
List<Offer> availableOffers(List<Offer> offers)
```

Rules:

- `AvailabilityApi.lookup(offer.id())` is a blocking remote call.
- During one `availableOffers(offers)` call, run at most 8 in-flight
  `AvailabilityApi.lookup(...)` calls at the same time.
- Return only offers whose availability decision says they can be shown.
- Sort the returned offers by `Offer::rank`, then `Offer::id`.
- Use Java stream APIs for the operation.
- Do not use `parallelStream()` or `.parallel()`.
- Do not fan out unbounded asynchronous work.
- Keep the concurrency limit explicit in code.
- Do not use `null` as a sentinel for unavailable offers.

Use these nested types:

```java
record Offer(String id, int rank) {}
record Availability(boolean show, String region) {}
static final class AvailabilityApi {
    static Availability lookup(String id) {
        throw new UnsupportedOperationException("provided by production");
    }
}
```
