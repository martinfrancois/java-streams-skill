# Write retry backoff code

Create `RetryBackoff.java`. Assume Java 17.

Implement:

```java
Duration backoff(Config config, int attempt, HttpResponse<?> response)
```

Rules:

- If `response` is not null and has a valid `Retry-After` header, return that duration.
- A valid `Retry-After` value is a positive whole number of seconds.
- If the header is missing, blank, zero, negative, or not a number, return the exponential backoff.
- The exponential backoff is `config.baseDelay().multipliedBy(1L << Math.min(attempt - 1, 8))`.
- Include `Optional<Duration> parseRetryAfter(String value)`.
- Include this nested record:

```java
record Config(Duration baseDelay) {}
```
