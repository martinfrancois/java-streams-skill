# Audit Java 8 stream API drift

Use `$java-streams` to run the hard-stop scan workflow over this proposed helper. Create
`review.md`.

Assume Java 8.

In `review.md`, start with the exact skill-provided scan header and hard-stop `rg` scan command,
including the full marker regex and `<touched Java files>` placeholder. Then list each Java-version
drift issue and a Java 8-compatible direction. Also mention whether `activeCount` is acceptable
Java 8 stream code, and be precise about whether plain `count()` is a skill-provided scan hit.

```java
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

final class Java8StreamDrift {
    List<String> aliases(List<Optional<String>> aliases) {
        return aliases.stream()
                .flatMap(Optional::stream)
                .toList();
    }

    Stream<String> nullableName(Customer customer) {
        return Stream.ofNullable(customer.name());
    }

    List<Event> leadingVisible(List<Event> events) {
        return events.stream()
                .takeWhile(Event::visible)
                .collect(Collectors.toList());
    }

    List<Event> afterHiddenPrefix(List<Event> events) {
        return events.stream()
                .dropWhile(Event::visible)
                .collect(Collectors.toList());
    }

    Map<String, List<String>> namesByRegion(List<Customer> customers) {
        return customers.stream()
                .collect(Collectors.groupingBy(
                        Customer::region,
                        Collectors.flatMapping(
                                customer -> customer.aliases().stream(),
                                Collectors.toList())));
    }

    Split splitScores(List<Score> scores) {
        return scores.stream()
                .collect(Collectors.teeing(
                        Collectors.minBy(Score::compareTo),
                        Collectors.maxBy(Score::compareTo),
                        Split::new));
    }

    List<String> activeIds(List<Customer> customers) {
        return customers.stream()
                .filter(Customer::active)
                .mapMulti((customer, out) -> out.accept(customer.id()))
                .collect(Collectors.toList());
    }

    long activeCount(List<Customer> customers) {
        return customers.stream()
                .filter(Customer::active)
                .count();
    }

    static final class Customer {
        private final String id;
        private final String name;
        private final String region;
        private final List<String> aliases;
        private final boolean active;

        Customer(String id, String name, String region, List<String> aliases, boolean active) {
            this.id = id;
            this.name = name;
            this.region = region;
            this.aliases = aliases;
            this.active = active;
        }

        String id() { return id; }
        String name() { return name; }
        String region() { return region; }
        List<String> aliases() { return aliases; }
        boolean active() { return active; }
    }

    static final class Event {
        private final String id;
        private final boolean visible;

        Event(String id, boolean visible) {
            this.id = id;
            this.visible = visible;
        }

        String id() { return id; }
        boolean visible() { return visible; }
    }

    static final class Score implements Comparable<Score> {
        private final int value;

        Score(int value) {
            this.value = value;
        }

        @Override
        public int compareTo(Score other) {
            return Integer.compare(value, other.value);
        }
    }

    static final class Split {
        private final Optional<Score> min;
        private final Optional<Score> max;

        Split(Optional<Score> min, Optional<Score> max) {
            this.min = min;
            this.max = max;
        }

        Optional<Score> min() { return min; }
        Optional<Score> max() { return max; }
    }
}
```
