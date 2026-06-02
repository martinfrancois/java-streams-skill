# Keep three-state mode behavior

Assume Java 17.

Use `$java-optionals` to improve this Java code without changing behavior. Create
`GiftWrapConfigurator.java` with the revised class.

```java
import java.io.IOException;
import java.util.Optional;

final class GiftWrapConfigurator {
    GiftWrapIntegration resolve(Options options, Prerequisites prerequisites, Terminal terminal)
            throws IOException {
        if (options.giftWrapMode().isPresent()) {
            boolean enabled = options.giftWrapMode().orElseThrow();
            if (!enabled) {
                terminal.info("Gift wrap skipped");
                return GiftWrapIntegration.DISABLED;
            }
            if (options.nonInteractive() && !prerequisites.giftWrapServiceAvailable()) {
                throw new IllegalStateException("Gift wrap service is required");
            }
            return GiftWrapIntegration.ENABLED;
        }
        if (prerequisites.accountAlreadyConfigured()) {
            return GiftWrapIntegration.ENABLED;
        }
        if (options.nonInteractive()) {
            return GiftWrapIntegration.DISABLED;
        }
        return terminal.confirm("Enable gift wrap? ")
                ? GiftWrapIntegration.ENABLED
                : GiftWrapIntegration.DISABLED;
    }

    interface Options {
        Optional<Boolean> giftWrapMode();
        boolean nonInteractive();
    }

    interface Prerequisites {
        boolean giftWrapServiceAvailable();
        boolean accountAlreadyConfigured();
    }

    interface Terminal {
        void info(String message);
        boolean confirm(String prompt) throws IOException;
    }

    enum GiftWrapIntegration {
        ENABLED,
        DISABLED
    }
}
```

Keep these meanings:

- `Optional.of(false)` skips gift wrap immediately.
- `Optional.of(true)` enables gift wrap and checks non-interactive prerequisites.
- `Optional.empty()` keeps the account-configured, non-interactive, and prompt fallback behavior.
