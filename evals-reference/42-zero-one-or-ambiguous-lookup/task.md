# Look up a coverage rider by code

Create `RiderLookup.java`. Assume Java 17.

Quoting needs to find the rider a broker selected on an insurance policy. Implement:

```java
Optional<CoverageRider> riderByCode(InsurancePolicy policy, String riderCode)
```

Put these types in the same file:

```java
record CoverageRider(String riderCode, String title, BigDecimal monthlyPremium) {}

record InsurancePolicy(String policyNumber, List<CoverageRider> riders) {}

final class AmbiguousRiderException extends RuntimeException {
    AmbiguousRiderException(String policyNumber, String riderCode) {
        super("Policy " + policyNumber + " has more than one rider with code " + riderCode);
    }
}
```

Rules:

- A rider matches when its `riderCode` equals the requested `riderCode`. Either side can be `null`,
  and a `null` request matches riders whose code is `null`. Matching must not throw on `null`.
- Return an empty `Optional` when no rider matches.
- Return the matching rider when exactly one matches.
- Throw `new AmbiguousRiderException(policy.policyNumber(), riderCode)` when two or more riders
  match. A duplicate must never be quoted silently.
- Fleet policies carry several thousand riders, and quoting calls this method for every line on a
  quote.
- Do not mutate the policy or its rider list, and do not add dependencies, caches, or public types
  beyond the ones listed here.
