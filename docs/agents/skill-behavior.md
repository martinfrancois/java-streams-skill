# Skill Behavior

## Scope

Use this when editing `skills/java-optionals/SKILL.md`, skill metadata, install guidance, or
auto-selection wording.

## Rules

- The skill shouldn't require users to explicitly type `$java-optionals` every time.
- Metadata should let agents auto-select it for Java tasks involving `Optional`, `isPresent()`,
  `orElse(null)`, `optional.stream()`, `findFirst()` / `findAny()`, missing values, values that may
  be `null`, fallback/default values, and code where a value may or may not exist.
- Skill guidance must start by detecting the project Java baseline before selecting Optional,
  primitive Optional, stream, collector, record, or collection APIs.
- Keep the highest-risk replay failures near the top of `SKILL.md`, before the normal workflow.
  Agents have read the skill and still repeated fake one-Optional collection loops when that rule
  appeared only as one item in a longer list.
- Cover the full Optional family: `Optional<T>`, `OptionalInt`, `OptionalLong`, `OptionalDouble`,
  Optional-producing stream terminals, primitive stream terminals, and Optional-producing
  collectors.
- Keep `findAny()` guidance defensive. It is only right when all matches are equivalent and no
  ordering or priority contract depends on the first match.
- Boundary exceptions should stay narrow: checked IO, prompts, legacy null APIs, external APIs,
  genuine absence-as-error, and predicate-only presence checks.
- Checked IO and prompt boundaries must not be hidden behind generic Optional helpers such as
  `OptionalSupport`, `OptionalIo`, `CheckedOptionals`, throwing suppliers, or supplier `.get()`
  tricks. Prefer a narrow plain branch at the actual boundary.
- The skill must make the `optional.stream().toList()` rule operational. Agents should scan touched
  code before finalizing and rewrite any fake one-Optional collection or `for` loop over
  `optional.stream().toList()`.
- The same ban applies to disguised variants such as `optional.stream()::iterator`,
  `optionalValues(Optional<T>)`, `presentValues(Optional<T>)`, or any helper that turns one Optional
  into an `Iterable` just so a loop can read zero or one value.
- Historical replay showed an agent may replace a presence-read smell with a fake one-Optional
  loop even after reading the rule. Keep exact examples for checked prompt/parser boundaries where a
  narrow explicit branch is better than `for (value : optional.stream().toList())`.
- When saying a "small helper" is acceptable, distinguish domain helpers from generic Optional
  unwrapping helpers. Helpers like `validateRequestedPort(...)` are fine; helpers accepting
  `Optional<T>` only to unwrap, iterate, or tunnel checked exceptions are not.
- If a user prompt demands removal of presence-read code at a checked-IO or prompt boundary, the
  skill should still prefer a narrow direct branch over a generic checked-Optional helper, fake
  iterable, or `orElse(null)` workaround. Document the checked-boundary exception instead of
  swapping one antipattern for another.
- The skill must require its own hard-stop scan. Historical prompts may ask for narrower scans that
  only find `isPresent()` / `get()` / `orElseThrow()`; agents then miss newly introduced fake
  Optional stream/list replacements.
- `skills/java-optionals/references/hard-stops.md` is the runtime reference for replacement
  antipatterns and the final hard-stop scan. Keep it linked from `SKILL.md` when moving detailed
  hard-stop guidance out of the main skill file.
- The README may say: "agents that support skill auto-selection, such as Codex and Claude Code".
- Before naming platforms that support auto-selection, verify against official docs and link those
  docs when possible.
- Don't over-explain install-path differences in the Getting Started flow.

## References

- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
