# Simplify the claim history record

Create `ClaimHistory.java` with the revised record. Assume Java 17.

This record came out of a recent audit of the claims module. Simplify it wherever that removes work
or code, while keeping every guarantee it gives callers today.

```java
import java.util.List;
import java.util.Map;

record ClaimHistory(String claimId, List<Map<String, Object>> adjusterNotes) {
    ClaimHistory {
        if (claimId == null || claimId.isBlank()) {
            throw new IllegalArgumentException("claimId must not be blank");
        }
        adjusterNotes = adjusterNotes.stream().map(Map::copyOf).toList();
    }

    @Override
    public List<Map<String, Object>> adjusterNotes() {
        return adjusterNotes.stream().map(Map::copyOf).toList();
    }

    int noteCount() {
        return adjusterNotes.size();
    }
}
```

Guarantees callers rely on:

- Changing the source list or any source map after construction does not affect the record.
- The list returned by `adjusterNotes()` and every map in it reject modification.
- Notes keep the order they were passed in.
- A `null` note, or a `null` key or value inside a note, is rejected with `NullPointerException`
  when the record is built.
- The module's static analysis fails the build when a record accessor returns a collection
  component without a defensive copy or an unmodifiable wrapper, so `adjusterNotes()` must keep an
  explicit accessor.

The claims dashboard calls `adjusterNotes()` on every refresh. Do not add dependencies or new
public methods.
