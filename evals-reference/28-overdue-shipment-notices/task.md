# Implement overdue shipment notices

Create `OverdueShipmentNotices.java`. Assume Java 17.

Implement:

```java
List<ShipmentNotice> overdueNotices(List<Shipment> shipments, Clock clock)
```

Use these records in the same file:

```java
record Shipment(String id, String customerEmail, LocalDate dueDate, Optional<LocalDate> deliveredAt) {}
record ShipmentNotice(String id, String customerEmail, long daysLate, String severity) {}
```

Rules:

- Include only shipments whose `deliveredAt` is empty and whose `dueDate` is before
  `LocalDate.now(clock)`.
- Preserve the encounter order of `shipments`.
- For each overdue shipment, return a notice containing:
  - the shipment id,
  - the customer email,
  - the number of days late,
  - severity `"critical"` when the shipment is at least 14 days late, otherwise `"late"`.
- Do not mutate the input list, add external dependencies, start background work, or introduce new
  public APIs beyond the requested class, method, and records.
