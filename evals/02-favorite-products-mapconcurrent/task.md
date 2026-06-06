# Implement delivery appointment checks

Create `DeliveryAppointments.java`. Assume Java 24.

Implement:

```java
List<Appointment> schedulableAppointments(Planner planner)
```

Rules:

- `planner.appointments()` returns appointments in the planner's proposed order.
- `CalendarService.canSchedule(appointment.token())` is a blocking remote call.
- A planner can contain hundreds of appointments, and checking one appointment at a time is too
  slow in production.
- The concurrency limit is per `schedulableAppointments(planner)` call: during one call, run at
  most 8 in-flight `CalendarService.canSchedule(...)` calls at the same time.
- Return only appointments that can be scheduled.
- Sort the returned appointments by `Appointment::startsAt`, then `Appointment::token`.
- Use Java stream APIs for the operation.

Use these nested types:

```java
record Planner(List<Appointment> appointments) {}
record Appointment(String token, long startsAt) {}
static final class CalendarService {
    static boolean canSchedule(String token) {
        throw new UnsupportedOperationException("provided by production");
    }
}
```
