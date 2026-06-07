# Review priority lookup refactor

Use `$java-streams` to review this proposed change. Create `review.md` with a short decision and a
safer stream chain if the change should not be accepted.

Assume Java 17.

Before:

```java
import java.util.List;
import java.util.Optional;

final class PrimaryContact {
    Optional<Contact> choose(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (contact.enabled() && contact.verified()) {
                return Optional.of(contact);
            }
        }
        return Optional.empty();
    }

    record Contact(String id, int priority, boolean enabled, boolean verified) {}
}
```

Proposed:

```java
import java.util.List;
import java.util.Optional;

final class PrimaryContact {
    Optional<Contact> choose(List<Contact> contacts) {
        return contacts.parallelStream()
                .filter(contact -> contact.enabled() && contact.verified())
                .findAny();
    }

    record Contact(String id, int priority, boolean enabled, boolean verified) {}
}
```

The list is already in configured priority order before this method is called.
