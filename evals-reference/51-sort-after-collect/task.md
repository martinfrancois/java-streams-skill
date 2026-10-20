# Refactor the depot maintenance planner

Use `$java-streams` to refactor the loops in `DepotMaintenancePlanner` and reduce the duplication
between its two methods. Create `DepotMaintenancePlanner.java` with the revised class. Assume Java 17.

A fleet operator's planner lists open service tasks per depot and overdue tasks across the fleet.

```java
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

final class DepotMaintenancePlanner {
    private static final Comparator<ServiceTask> BY_SERVICE_DATE_THEN_VEHICLE =
            Comparator.comparing(ServiceTask::serviceDue).thenComparing(ServiceTask::vehicleId);

    List<ServiceTask> openTasksForDepot(List<ServiceTask> tasks, Depot depot) {
        List<ServiceTask> planned = new ArrayList<>();
        for (ServiceTask task : tasks) {
            if (!task.completed() && task.depot() == depot) {
                planned.add(task);
            }
        }
        planned.sort(BY_SERVICE_DATE_THEN_VEHICLE);
        return planned;
    }

    List<ServiceTask> overdueTasks(List<ServiceTask> tasks, LocalDate asOf) {
        List<ServiceTask> planned = new ArrayList<>();
        for (ServiceTask task : tasks) {
            if (!task.completed() && asOf.isAfter(task.serviceDue())) {
                planned.add(task);
            }
        }
        planned.sort(BY_SERVICE_DATE_THEN_VEHICLE);
        return planned;
    }

    enum Depot { NORTH_YARD, HARBOR, AIRPORT }

    record ServiceTask(String vehicleId, Depot depot, LocalDate serviceDue, boolean completed) {}
}
```

Behavior to keep:

- Completed tasks never appear in either result.
- Both results are ordered by service due date, then vehicle id. Tasks that compare equal keep their
  relative order from `tasks`.
- The dispatcher appends ad-hoc tasks to the returned lists, so both must stay mutable.
- The input list must not be modified.
- A null task or a task with a null service due date must still fail with a
  NullPointerException.

After the code, summarize in a few sentences what you changed and why the results are the same.
