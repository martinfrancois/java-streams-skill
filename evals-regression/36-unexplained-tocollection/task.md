# Make the claim triage collections readable

Create `ClaimTriage.java` with the revised class. Assume Java 17.

A reviewer on the insurance claims team left this note on `ClaimTriage`: "I can't tell why each of
these methods collects into the collection it does. Was that deliberate or habit? Please make it
obvious to the next person who touches this." Revise the class so that question has an answer in
the code.

```java
import static java.util.stream.Collectors.*;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

final class ClaimTriage {
    record ClaimLine(String claimId, String policyNumber, String adjuster, String region, boolean flagged) {}

    Deque<String> reviewQueue(List<ClaimLine> lines, String escalatedClaimId) {
        Deque<String> queue = lines.stream()
                .filter(ClaimLine::flagged)
                .map(ClaimLine::claimId)
                .collect(toCollection(ArrayDeque::new));
        queue.addLast(escalatedClaimId);
        return queue;
    }

    Set<String> adjustersInvolved(List<ClaimLine> lines) {
        return lines.stream()
                .map(ClaimLine::adjuster)
                .collect(toCollection(HashSet::new));
    }

    Set<String> affectedPolicies(List<ClaimLine> lines) {
        return lines.stream()
                .map(ClaimLine::policyNumber)
                .collect(toCollection(LinkedHashSet::new));
    }

    Set<String> regionsTouched(List<ClaimLine> lines) {
        return lines.stream()
                .map(ClaimLine::region)
                .collect(toCollection(LinkedHashSet::new));
    }
}
```

What you need to know about the callers:

- The adjuster dashboard takes claim ids off the front of `reviewQueue`'s result one at a time, and
  the escalated claim must come out last.
- The letter generator prints `affectedPolicies` in the order the set iterates, and it must list each
  policy once, in the order the policy first appears in `lines`.
- `adjustersInvolved` and `regionsTouched` are only used for membership checks. No caller modifies
  them or depends on their iteration order.
- `ClaimLine` string fields are never null.
- The build's lint rejects the JDK toSet() collector because it leaves the result's mutability
  unstated.
- Keep the method names, parameters, and return types unchanged.
