# Tidy the depot service desk

Create `DepotServiceDesk.java` with the revised class. Assume Java 17.

The fleet team's service desk class below works, but a reviewer called its stream code dated.
Modernize it where that makes the code clearer, and keep its behavior.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Logger;

final class DepotServiceDesk {
    private static final Logger LOG = Logger.getLogger(DepotServiceDesk.class.getName());
    private final WorkshopPager pager;

    DepotServiceDesk(WorkshopPager pager) {
        this.pager = pager;
    }

    void pageOverdue(List<ServiceVisit> visits) {
        visits.stream().filter(ServiceVisit::overdue).forEach(pager::page);
    }

    void logDepotLoad(List<ServiceVisit> visits) {
        visits.stream().forEach(visit -> LOG.info(visit.depot() + " -> " + visit.vehicleId()));
    }

    List<String> overdueVehicleIds(List<ServiceVisit> visits) {
        List<String> ids = new ArrayList<>();
        visits.stream().filter(ServiceVisit::overdue).map(ServiceVisit::vehicleId).forEach(ids::add);
        return ids;
    }

    Map<String, Integer> labourMinutesByDepot(List<ServiceVisit> visits) {
        Map<String, Integer> totals = new TreeMap<>();
        visits.stream().forEach(visit -> totals.merge(visit.depot(), visit.labourMinutes(), Integer::sum));
        return totals;
    }

    interface WorkshopPager {
        void page(ServiceVisit visit);
    }

    record ServiceVisit(String vehicleId, String depot, int labourMinutes, boolean overdue) {}
}
```

Rules:

- `pageOverdue` pages every overdue visit, one pager call per visit, in input order, on every call.
- `logDepotLoad` writes one log line per visit, in input order.
- `overdueVehicleIds` returns the vehicle ids of overdue visits in input order. Callers only read
  the returned list.
- `labourMinutesByDepot` returns the summed labour minutes per depot, with depot names in ascending
  order. Callers only read the returned map.
- Keep the constructor, the method signatures, `WorkshopPager`, and `ServiceVisit` as they are.
