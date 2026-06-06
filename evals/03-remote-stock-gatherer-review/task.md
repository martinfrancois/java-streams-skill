# Review payment screening stream change

Assume Java 24.

Use `$java-streams` to review this proposed change. Create `review.md` with a short review decision
and a safer Java 24 stream shape.

The payment service calls a remote fraud-screening API inside `passesFraudScreen(payment)`.

Before:

```java
import java.util.Comparator;
import java.util.List;

final class PaymentScreening {
    List<Payment> releasablePayments(Batch batch) {
        return batch.payments().stream()
                .filter(this::passesFraudScreen)
                .sorted(Comparator.comparing(Payment::submittedAt))
                .toList();
    }

    boolean passesFraudScreen(Payment payment) {
        return FraudApi.approve(payment.reference());
    }

    record Batch(List<Payment> payments) {}
    record Payment(String reference, long submittedAt) {}
}
```

Proposed:

```java
import java.util.Comparator;
import java.util.List;

final class PaymentScreening {
    List<Payment> releasablePayments(Batch batch) {
        return batch.payments().parallelStream()
                .filter(this::passesFraudScreen)
                .sorted(Comparator.comparing(Payment::submittedAt))
                .toList();
    }

    boolean passesFraudScreen(Payment payment) {
        return FraudApi.approve(payment.reference());
    }

    record Batch(List<Payment> payments) {}
    record Payment(String reference, long submittedAt) {}
}
```
