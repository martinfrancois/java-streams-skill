# Implement invoice bounds and temperature windows

Use `$java-streams` to create `InvoiceBoundsAndTemperatures.java`. Assume Java 17.

Implement:

```java
Bounds<Invoice, Invoice> invoiceTotalBounds(List<Invoice> invoices)
List<Reading> readingsBeforeFirstOverheat(List<Reading> readings, double maxSafeTemperature)
List<Reading> readingsAfterInitialSafeRun(List<Reading> readings, double maxSafeTemperature)
```

Rules:

- `invoiceTotalBounds` should return the lowest-total and highest-total invoices. For an empty
  invoice list, both bounds values should be `null`.
- `readingsBeforeFirstOverheat` returns the chronological prefix where
  `temperatureCelsius <= maxSafeTemperature`.
- `readingsAfterInitialSafeRun` skips the initial chronological prefix where
  `temperatureCelsius <= maxSafeTemperature` and returns the rest.

Use nested records:

```java
record Invoice(String id, BigDecimal total) {}
record Reading(long sequence, double temperatureCelsius) {}
record Bounds<L, R>(L low, R high) {}
```
