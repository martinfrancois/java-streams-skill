# Tidy the branch loan summary

Create `BranchLoanSummary.java` with the revised class. Assume Java 17.

The library's lending service builds its nightly branch report from this class. The logic is
correct and has tests, but reviewers keep saying the methods are hard to read in a diff. Change
only how the code is laid out; the logic stays as it is.

```java
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

final class BranchLoanSummary {
    record BookLoan(String isbn, String memberId, String branch, int daysOverdue, long feeCents, boolean returned) {}

    List<String> overdueIsbns(List<BookLoan> loans) {
        return loans.stream().filter(loan -> !loan.returned()).filter(loan -> loan.daysOverdue() > 0).map(BookLoan::isbn).toList();
    }

    long outstandingFeeCents(List<BookLoan> loans, String branch) {
        return loans.stream().filter(loan -> loan.branch().equals(branch)).filter(loan -> !loan.returned()).mapToLong(BookLoan::feeCents).sum();
    }

    Optional<BookLoan> mostOverdue(List<BookLoan> loans) {
        return loans.stream().filter(loan -> !loan.returned()).max(Comparator.comparingInt(BookLoan::daysOverdue));
    }

    boolean hasBorrowed(List<BookLoan> loans, String memberId) {
        return loans.stream().anyMatch(loan -> loan.memberId().equals(memberId));
    }

    Map<String, Object> exportFields(String branch, List<BookLoan> loans) {
        Map<String, Object> fields = new LinkedHashMap<>();
        fields.put("branch", branch);
        fields.put("isbns", loans.stream().map(BookLoan::isbn).toList());
        fields.put("members", loans.stream().map(BookLoan::memberId).sorted().toList());
        return fields;
    }
}
```

Requirements:

- Every method must return the same values as before, in the same order, with the same
  mutability.
- Keep the method names, parameters, return types, and the nested record unchanged.
- Do not add dependencies, build plugins, or new public types.
