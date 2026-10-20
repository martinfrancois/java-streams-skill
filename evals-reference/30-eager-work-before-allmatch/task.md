# Tighten manuscript license resolution

Create `ManuscriptLicenseResolver.java` with the revised class. Assume Java 17.

A manuscript can carry license tags in its front matter, back matter, and editor notes. The
publishing team recently changed `resolve` from "the first tag wins" to "all tags must agree", and
the new version below passes its tests. Clean up `resolve` for readability and efficiency while
keeping its rules.

Each `verify` call is a round trip to the remote license registry and is by far the most expensive
step in this method.

```java
import java.util.ArrayList;
import java.util.List;

final class ManuscriptLicenseResolver {
    private final LicenseRegistry registry;
    ManuscriptLicenseResolver(LicenseRegistry registry) {
        this.registry = registry;
    }

    LicenseVerdict resolve(List<LicenseTag> tags) {
        if (tags.isEmpty()) {
            return LicenseVerdict.none();
        }
        if (tags.size() == 1) {
            return registry.verify(tags.get(0).rawValue());
        }
        List<LicenseVerdict> verdicts = new ArrayList<>(tags.size());
        for (LicenseTag tag : tags) {
            verdicts.add(registry.verify(tag.rawValue()));
        }
        LicenseVerdict leading = verdicts.get(0);
        if (leading.status() == Status.VERIFIED
                && verdicts.stream().allMatch(verdict -> sameLicense(leading, verdict))) {
            return leading;
        }
        return LicenseVerdict.invalid("Conflicting license tags. Keep one tag or make all tags identical.");
    }

    private static boolean sameLicense(LicenseVerdict expected, LicenseVerdict actual) {
        return actual.status() == Status.VERIFIED && expected.spdxId().equalsIgnoreCase(actual.spdxId());
    }

    interface LicenseRegistry { LicenseVerdict verify(String rawValue); }
    enum Status { NONE, VERIFIED, INVALID }
    record LicenseTag(String section, String rawValue) {}
    record LicenseVerdict(Status status, String spdxId, String problem) {
        static LicenseVerdict none() { return new LicenseVerdict(Status.NONE, null, null); }
        static LicenseVerdict invalid(String problem) { return new LicenseVerdict(Status.INVALID, null, problem); }
    }
}
```

Rules:

- No tags: return `LicenseVerdict.none()` without calling the registry.
- One tag: return the registry's verdict for that tag unchanged, whatever its status.
- Several tags: return the first tag's verdict only when it is `VERIFIED` and every other tag
  verifies to the same SPDX id, compared case-insensitively. Otherwise return the conflict verdict
  with the same message. Several tags that all fail verification are a conflict, not a success.
- Verify each tag at most once per `resolve` call.
- Keep the nested types and their signatures unchanged.
