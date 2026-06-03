# Implement offer availability filtering

Use `$java-streams` to create `OfferAvailability.java`. Assume Java 24.

Implement:

```java
List<Offer> availableOffers(List<Offer> offers)
```

Rules:

- `AvailabilityApi.isAvailable(offer.id())` is a blocking remote call.
- Return only offers that are available.
- Sort the returned offers by `Offer::rank`, then `Offer::id`.
- Use Java stream APIs for the pipeline.
- Do not use `parallelStream()` or `.parallel()`.
- Do not fan out unbounded asynchronous work.
- Keep the concurrency limit explicit in code.

Use these nested types:

```java
record Offer(String id, int rank) {}
static final class AvailabilityApi {
    static boolean isAvailable(String id) {
        throw new UnsupportedOperationException("provided by production");
    }
}
```
