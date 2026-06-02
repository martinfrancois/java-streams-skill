# Review proposed order regression

Assume Java 17.

Use `$java-optionals` to review this proposed change. Create `review.md` with a short review
decision and rationale.

Before:

```java
import java.util.List;
import java.util.Optional;

final class ContactSelector {
    Optional<Contact> primaryContact(List<Contact> contacts) {
        return contacts.stream()
                .filter(Contact::verified)
                .findFirst();
    }

    record Contact(String email, boolean verified) {}
}
```

Proposed:

```java
import java.util.List;
import java.util.Optional;

final class ContactSelector {
    Optional<Contact> primaryContact(List<Contact> contacts) {
        return contacts.stream()
                .filter(Contact::verified)
                .findAny();
    }

    record Contact(String email, boolean verified) {}
}
```
