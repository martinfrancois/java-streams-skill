# Review primary contact lookup

Assume Java 17.

Create `review.md` with a short code review decision and rationale. Do not modify the Java code.

Before:

```java
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

final class ContactSelector {
    Optional<Contact> primaryVerifiedContact(List<Contact> contacts) {
        return contacts.stream()
                .sorted(Comparator.comparing(Contact::priority))
                .filter(Contact::verified)
                .findFirst();
    }

    record Contact(String email, int priority, boolean verified) {}
}
```

Proposed:

```java
import java.util.List;
import java.util.Optional;

final class ContactSelector {
    Optional<Contact> primaryVerifiedContact(List<Contact> contacts) {
        return contacts.parallelStream()
                .filter(Contact::verified)
                .findAny();
    }

    record Contact(String email, int priority, boolean verified) {}
}
```
