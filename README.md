# Java Optional Skill for AI Agents

[![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Fmartinfrancois%2Fjava-optionals)](https://tessl.io/registry/martinfrancois/java-optionals)

AI agents often know enough Java to reach for `Optional`, but not enough to use it well.

They write code that looks modern at first glance, then leaves you with `isPresent()` plus `get()`,
`orElse(null)`, fallback code that runs too early, fake one-item lists, or a clear stream rewritten
as a noisy loop.

This skill gives the agent a small decision guide before it writes or changes Optional code: choose
the Optional shape, run fallback work only when needed, keep real collection streams readable, and
use a plain branch when checked IO makes that clearer.

It also tells the agent to check the project Java version first. The right Optional code for a
Java 8 project may be different from the right code for Java 17 or Java 21.

## Contents

- [Getting Started](#getting-started)
- [Why This Exists](#why-this-exists)
- [What Good Looks Like](#what-good-looks-like)
- [What It Helps With](#what-it-helps-with)
- [Examples](#examples)
- [How It's Evaluated](#how-its-evaluated)
- [Contributing](#contributing)
- [Origin](#origin)
- [License](#license)

## Getting Started

### 1. Install

Install the published Tessl plugin using the option that fits your setup:

| Tool | Command |
| --- | --- |
| npm | `npx tessl i martinfrancois/java-optionals` |
| yarn | `yarn dlx tessl i martinfrancois/java-optionals` |
| pnpm | `pnpx tessl i martinfrancois/java-optionals` |
| bun | `bunx tessl i martinfrancois/java-optionals` |
| Tessl CLI | `tessl i martinfrancois/java-optionals` |

Use one of the package-runner commands if you want to try the skill without installing the Tessl CLI
first.

### 2. Use It

Agents that support skill auto-selection, such as
[Codex](https://developers.openai.com/codex/skills) and
[Claude Code](https://code.claude.com/docs/en/skills), can choose this skill automatically from the
task or code context. The task doesn't need to say `Optional` by name.

It can also trigger when Java code deals with missing values, values that may be `null`,
fallback/default values, `isPresent()`, `orElse(null)`, `optional.stream()`,
`findFirst()` / `findAny()`, or similar code paths for values that may or may not exist.

For important Optional-heavy work, you can still name the skill explicitly:

```text
Use $java-optionals to implement this Java feature with Optional best practices.
```

For cleanup work:

```text
Use $java-optionals to clean up this Java method without changing its outputs or error handling.
```

For reviews:

```text
Use $java-optionals to review this Java Optional code and suggest any cleanups.
```

## Why This Exists

The motivation was real AI-written Java code. The agent already used `Optional`, but didn't follow
best practices.

Sometimes the agent introduced weak Optional code while writing a new feature:

```java
// what an unassisted AI would write in new code
Optional<Coupon> coupon = findCoupon(code);
if (coupon.isPresent()) {
    return applyCoupon(cart, coupon.get());
}
return cart;
```

Other times, when asked to clean up the code and follow Optional best practices, it swapped one bad
pattern for another:

- replacing `isPresent()` / `get()` with `orElse(null)` and local null checks;
- using `isPresent()` or `isEmpty()` and then reading the same value with `get()` or
  `orElseThrow()`;
- running fallback work too early by using `orElse(...)` where `orElseGet(...)` is required;
- turning one optional value into a fake list, then reading the first item;
- replacing a clear collection stream with a long manual loop;
- hiding checked IO or user prompts behind clever helper code;
- changing the meaning of `findFirst()` / `findAny()` by accident.

The examples below are anti-examples. They show Java `Optional` code an AI agent would write,
followed by what it would change that code to when asked to follow Optional best practices without
this skill.

For example, one cleanup would have changed a simple coupon branch into a fake list:

```java
// before the AI cleanup request
if (selectedCoupon.isPresent()) {
    return applyCoupon(cart, selectedCoupon.get());
}
return cart;

// what an unassisted AI would have changed it to
List<Coupon> coupons = selectedCoupon.stream().toList();
if (!coupons.isEmpty()) {
    return applyCoupon(cart, coupons.get(0));
}
return cart;
```

Another would have changed a product discount fallback into local null checks:

```java
// before the AI cleanup request
if (discount.isPresent()) {
    return price.minus(discount.get());
}
return price;

// what an unassisted AI would have changed it to
Money value = discount.orElse(null);
if (value != null) {
    return price.minus(value);
}
return price;
```

And another would have changed a delivery-slot lookup into a harder-to-read loop:

```java
// before the AI cleanup request
for (DeliveryWindow preferredWindow : preferredWindows) {
    Optional<DeliverySlot> match = availableSlots.stream()
            .filter(slot -> slot.fits(preferredWindow))
            .findFirst();
    if (match.isPresent()) {
        return Optional.of(match.orElseThrow());
    }
}
return Optional.empty();

// what an unassisted AI would have changed it to
for (DeliveryWindow preferredWindow : preferredWindows) {
    for (DeliverySlot slot : availableSlots) {
        if (slot.fits(preferredWindow)) {
            return Optional.of(slot);
        }
    }
}
return Optional.empty();
```

The goal isn't to force every branch into a method chain. The goal is simpler: understand what the
`Optional` is doing, keep the important effects in the same places, and choose the clearest code.

## What Good Looks Like

Without this skill, agents may "clean up" Optional code but still leave the same control-flow
problem:

```java
Coupon coupon = cart.coupon().orElse(null);

if (coupon != null) {
    return totalWithCoupon(cart, coupon);
}
return totalWithoutCoupon(cart);
```

With this skill, the agent is pushed toward using the `Optional` for the actual decision:

```java
Money total(Cart cart) {
    return cart.coupon()
            .map(coupon -> totalWithCoupon(cart, coupon))
            .orElseGet(() -> totalWithoutCoupon(cart));
}
```

## What It Helps With

Good fit:

- replacing `isPresent()` or `isEmpty()` followed by `get()` or `orElseThrow()`;
- choosing APIs that fit the project Java baseline instead of assuming the newest JDK;
- avoiding `orElse(null)` followed by local null checks;
- choosing between `orElse(...)` and `orElseGet(...)`;
- using `OptionalInt`, `OptionalLong`, and `OptionalDouble` without boxing or `getAs*()` reopening;
- keeping checked exceptions, user prompts, IO, and side effects in the right place;
- deciding whether `findFirst()` or `findAny()` keeps the same result;
- keeping real collection streams instead of rewriting them as noisy loops;
- avoiding `optional.stream().toList()` loops for a single `Optional`;
- handling old APIs that really use `null` for missing values;
- writing new Optional code directly instead of cleaning up hard-to-read branches later.

Poor fit:

- broad Java style enforcement unrelated to `Optional`;
- large API redesigns, data object changes, or new dependencies without maintainer agreement;
- changing business behavior just to make code look more functional;
- replacing every readable branch with a method chain.

## Examples

Simple fallback:

```java
String customerName(Optional<Customer> customer) {
    return customer.map(Customer::name).orElse("Guest");
}
```

Create only when needed:

```java
Cart cart(String cartId) {
    return carts.find(cartId).orElseGet(() -> createCart(cartId));
}
```

Side-effect branch:

```java
void sendReceipt(Order order, Optional<Email> email) {
    email.ifPresentOrElse(
            address -> sendEmail(address, order),
            () -> printReceipt(order));
}
```

Checked IO case where a plain branch is clearer:

```java
String shippingAddress(Checkout checkout, Console console) throws IOException {
    Optional<String> saved = checkout.savedShippingAddress();
    // Presence read is intentional here because the empty branch performs checked IO.
    if (!saved.isPresent()) {
        return console.readLine("Shipping address: ");
    }
    return saved.get();
}
```

This is a narrow checked-IO boundary exception. Don't copy this shape for ordinary in-memory value
flow; use `map`, `flatMap`, `orElseGet`, or `orElseThrow` when both branches are ordinary Optional
value flow.

Real collection lookup:

```java
Optional<DeliverySlot> deliverySlot(DeliveryWindow preferredWindow) {
    return availableSlots.stream()
            .filter(slot -> slot.fits(preferredWindow))
            .findFirst();
}
```

## How It's Evaluated

The skill is tested on implementation tasks based on real AI-written `Optional` mistakes. The tasks
cover both writing new Optional code and cleaning up existing Optional code. The headline suite uses
a documented mix of natural prompts and explicit `Use $java-optionals` prompts. Each task is run
without the skill and with the skill, then scored mainly on Optional-specific quality, with compile
and behavior checks included as safety checks.

The evals check that agents:

- produce coherent Java for the stated baseline;
- preserve exact outputs, errors, prompts, side effects, ordering, and fallback timing;
- avoid `isPresent()` / `get()` for ordinary value reads;
- don't replace `Optional` with `orElse(null)`;
- run fallback work only when needed;
- keep checked IO and user prompts clear;
- keep real collection streams readable;
- handle primitive Optionals and Optional-producing stream/collector APIs correctly.

Compile and behavior checks make regressions visible in the score, but the headline score is
intentionally weighted toward Optional quality: whether the agent keeps the same behavior while
avoiding Optional antipatterns and readability regressions.

Results should be read by subset:

- natural activation scenarios do not name the skill;
- explicit invocation scenarios directly ask for `$java-optionals`;
- Optional-quality subtotal shows the skill-specific effect;
- the focused headline suite reports the representative mix;
- `evals-reference/` keeps broader regression cases, including scenarios a strong baseline may
  already solve.

Current published scores are shown on the
[Tessl plugin](https://tessl.io/registry/martinfrancois/java-optionals).

## Contributing

Want to improve the skill, evals, or package metadata? See [CONTRIBUTING.md](CONTRIBUTING.md).

## Origin

This skill is based on real-world failures where coding agents wrote weak Java `Optional` code or
changed existing Optional code into different bad shapes while working on production-style tasks. The
motivating discussion is
[`martin-francois/symphony-trello#96`](https://github.com/martin-francois/symphony-trello/issues/96).

The skill is self-contained: using it doesn't require access to that issue, the original repository,
development drafts, or any external article.

## License

MIT. See [LICENSE](LICENSE).
