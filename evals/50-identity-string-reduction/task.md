# Clean up the bank statement export

Create `StatementExport.java` with the revised class. Assume Java 17.

A bank's statement export renders ledger entries as fixed-width text lines. Zero-amount entries
are validated but print nothing. The code below is correct, and the team wants the rendering in
`render` expressed more directly as part of a cleanup pass. Keep the output identical.

```java
import java.math.BigDecimal;
import java.util.List;

final class StatementExport {
    String render(List<LedgerEntry> entries) {
        return entries.stream()
                .map(StatementExport::renderLine)
                .reduce("", String::concat);
    }

    private static String renderLine(LedgerEntry entry) {
        if (entry.amount().scale() > 2) {
            throw new IllegalArgumentException("More than two decimals in " + entry.reference());
        }
        if (entry.amount().signum() == 0) {
            return "";
        }
        return String.format("%-12s%14s%n", entry.reference(), entry.amount().toPlainString());
    }

    record LedgerEntry(String reference, BigDecimal amount) {}
}
```

Behavior to keep:

- An empty entry list renders as `""`.
- Lines appear in the order of `entries`, with no separator added between them.
- A zero-amount entry contributes nothing to the output but is still checked for scale.
- An amount with more than two decimals still throws `IllegalArgumentException` from `render`.
- A `null` entry in the list still throws `NullPointerException`.

After the code, state in a few sentences why the revised `render` returns the same string or
throws the same exception as the original for every input, including what would happen if
`renderLine` could ever return `null`.
