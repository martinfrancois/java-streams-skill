# Audit collector and ordering scan hits

Use `$java-streams` to run the hard-stop scan workflow over this class. Create `review.md`.

Assume Java 21.

In `review.md`, start with the exact scan header and hard-stop `rg` scan command from the skill
bundle, including the full marker regex and `<touched Java files>` placeholder. Then classify all
hard-stop marker hits. Some markers are legitimate because of the domain notes; include those
justifications instead of deleting them from the audit.

```java
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

final class CollectorOrderScan {
    Map<String, Employee> byId(List<Employee> employees) {
        return employees.stream()
                .collect(Collectors.toMap(Employee::id, Function.identity()));
    }

    Map<String, Employee> byDesk(List<Employee> employees) {
        return employees.stream()
                .filter(employee -> employee.desk() != null)
                .collect(Collectors.toMap(Employee::desk, Function.identity()));
    }

    Map<String, List<Employee>> byDepartment(List<Employee> employees) {
        return employees.stream()
                .collect(Collectors.groupingBy(Employee::department));
    }

    Map<String, Long> byStatus(List<Employee> employees) {
        return employees.stream()
                .collect(Collectors.groupingBy(Employee::status, Collectors.counting()));
    }

    Employee cheapestDesk(List<Employee> employees) {
        return employees.stream()
                .filter(employee -> employee.desk() != null)
                .sorted(Comparator.comparing(Employee::deskCost))
                .findFirst()
                .orElse(null);
    }

    List<Employee> topFiveByScore(List<Employee> employees) {
        return employees.stream()
                .limit(5)
                .sorted(Comparator.comparing(Employee::score).reversed())
                .toList();
    }

    List<String> sortedNicknames(List<Employee> employees) {
        return employees.stream()
                .map(Employee::nickname)
                .sorted(Comparator.naturalOrder())
                .toList();
    }

    List<String> stableDepartments(List<Employee> employees) {
        return employees.stream()
                .map(Employee::department)
                .filter(Objects::nonNull)
                .sorted()
                .distinct()
                .toList();
    }

    long cpuScore(List<Employee> employees) {
        return employees.parallelStream()
                .mapToLong(Employee::expensiveCpuScore)
                .sum();
    }

    record Employee(
            String id,
            String desk,
            String department,
            String status,
            String nickname,
            int deskCost,
            int score) {
        long expensiveCpuScore() {
            long out = 0;
            for (int i = 0; i < 50_000; i++) {
                out += (long) score * i;
            }
            return out;
        }
    }
}
```

Domain notes:

- `id` is globally unique.
- `desk` is optional and two active employees can temporarily share a desk during a move.
- `department` and `nickname` can be null.
- `status` is non-null.
- `cpuScore` is an offline batch calculation over large lists.
