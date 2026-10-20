# Tidy up the policy code validator

Create `PolicyCodeValidator.java` with the revised class. Assume Java 17.

An insurance intake service flags policies whose policy code is not purely numeric. The helper
`isNumeric` is also called directly from other validators. The code below is correct, but the
helper reads like older Java. Make it more concise and idiomatic for Java 17.

```java
import java.util.List;

final class PolicyCodeValidator {
    List<InsurancePolicy> invalidPolicies(List<InsurancePolicy> policies) {
        return policies.stream()
                .filter(policy -> !isNumeric(policy.policyCode()))
                .toList();
    }

    static boolean isNumeric(String value) {
        if (value.isEmpty()) {
            return false;
        }
        for (int i = 0; i < value.length(); i++) {
            if (!Character.isDigit(value.charAt(i))) {
                return false;
            }
        }
        return true;
    }

    record InsurancePolicy(String holderName, String policyCode) {}
}
```

Behavior to keep:

- `isNumeric` must return the same result as today for every `String`, including the empty
  string, signs, whitespace, non-ASCII digits, and characters outside the Basic Multilingual Plane.
- It must stop at the first character that is not a digit.
- A `null` argument must still throw `NullPointerException`.
- `invalidPolicies` keeps its current results and order.

After the code, state in a few sentences why the revised `isNumeric` returns the same result as
the original for an empty string and for a string containing a character outside the Basic
Multilingual Plane.
