# Review primary address lookup

Assume Java 17.

Create `review.md` with a short review decision. Do not modify the Java code.

```java
import java.util.List;

final class AddressLookup {
    Address primaryAddress(CustomerAccount account) {
        List<Address> primaryAddresses = account.addresses().stream()
                .filter(Address::primary)
                .toList();
        return primaryAddresses.isEmpty() ? null : primaryAddresses.get(0);
    }

    record CustomerAccount(List<Address> addresses) {}
    record Address(String line1, boolean primary) {}
}
```

Should this lookup keep collecting a list, use `findFirst`, or use `findAny`?
