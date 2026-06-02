# README Guidance

## Scope

Use this when editing `README.md`, examples, motivation wording, or user-facing docs.

## Reader Rules

- Write for users first. Tessl is the install path, not the main story.
- Use `Java Optional Skill for AI Agents` as the README title. Keep package and repo names unchanged.
- The README should quickly make a Java developer think: "This solves a real problem I have."
- Keep the README flow natural from top to bottom. People may read it in order, so avoid sections
  that feel like disconnected notes.
- Put Getting Started before the motivation section.
- Keep a table of contents.
- Keep contributor-only details in `CONTRIBUTING.md`, not in the README.
- Keep eval-development details in `CONTRIBUTING.md`. The README should explain how the skill is
  evaluated and link to the Tessl plugin for current scores instead of duplicating fixed benchmark
  numbers that can go stale.
- Preserve maintainer-approved package-runner install examples such as `npx`, `yarn dlx`, `pnpx`,
  and `bunx` when they remain valid. Tessl's deprecated global npm install is a separate issue.
- Mention Java baseline detection as a user benefit, but keep deep compatibility tables in runtime
  references or contributor docs.
- Use contractions in docs, including `README.md`, unless a contraction would make a technical
  statement less clear.
- Don't add random package-name blocks such as `martinfrancois/java-optionals` unless they're part
  of a real install command or are otherwise useful to the reader.
- Keep Getting Started simple. Don't add overly specific prompt examples that restate individual
  antipatterns; one implementation prompt, one cleanup prompt, and one review prompt is enough.
- Prompt examples should match how users naturally ask. For reviews, assume the user wants the agent
  to find possible Optional cleanups, not review a cleanup proposal they already wrote.
- Structure Getting Started so readers can skim it: install first, then how automatic use works,
  then optional explicit prompts.
- Once the Tessl plugin is published, make the package install command the primary install path.
- Write the README as if the GitHub repository is public, even before it's actually public. Don't mention
  that the repo is private or add private-repo source install instructions.
- Use simple words that non-native Java developers can understand.
- Avoid avoidable words such as "idiomatic", "rationale", "provenance", "fluent", "semantics",
  "nullable", "present/absent", "first-pass", and "DTO" in user-facing README text.
  Prefer "standard", "reason", "origin", "method chain", "business behavior", "values that may be
  null", "values that may or may not exist", "new code", and "data object".

## Motivation Rules

- Keep the opening hook concrete. Mention the real bad shapes early, such as `isPresent()` plus
  `get()`, `orElse(null)`, fallback work that runs too early, fake one-item lists, and clear streams
  rewritten as noisy loops.
- The core motivation is: AI agents already wrote Java `Optional` code, but often used bad patterns.
  When asked to clean it up, they sometimes replaced one bad pattern with another.
- Prefer direct wording such as "didn't follow best practices" over vague phrases such as "not in a
  clear or standard way".
- Mention that the skill is based on real AI-written failures, not a made-up style preference.
- If changing the motivation, re-check the original issue body and all comments, plus the local
  source notes. The comments contained useful details that were easy to miss.
- Don't lose the issue-only cases that were added after the first audit: diagnostics selector
  Optionals and optional output side-effect handling.
- Don't imply the skill is only for refactoring. It helps agents write new Optional code well and
  clean up existing Optional code.
- Avoid vague phrases like "keep the same behavior" unless you name what must stay the same, such as
  outputs, errors, prompts, side effects, or when fallback work runs.
- Avoid phrases that make the examples sound like recommended transformations. They're bad outputs
  the skill is meant to prevent.
- When introducing the anti-examples, be accurate that both parts are bad: first, code an AI agent
  would write, then what it would change that code to when asked to follow Optional best practices
  without this skill.

## Example Rules

- Use small, easy examples. Prefer an online-store domain when possible because most readers can
  understand it quickly.
- Keep the store examples intuitive: coupons, discounts, shipping codes, totals, customers, carts,
  and receipts are good. Avoid examples whose business story distracts from the Optional problem.
- Keep code samples as short as possible while still showing the failure.
- The README examples aren't exact copies from the original issue. Phrase them accurately with
  "would have changed" or equivalent wording.
- In anti-examples, avoid generic `from` / `to` labels because they can imply the second half is the
  desired change.
- Prefer comments like:

  ```java
  // before the AI cleanup request
  // what an unassisted AI would have changed it to
  ```

- If mentioning a failure like "turning one Optional into a fake list", include a tiny code example
  so readers understand why it's bad.

## References

- [Skill Behavior](skill-behavior.md)
- [Public Metadata And OSS Readiness](public-metadata.md)
- [Maintaining Agent Docs](maintaining-agent-docs.md)
- Runtime reference: `skills/java-optionals/references/hard-stops.md` lists replacement
  antipatterns and the final scan agents should run before finishing Optional cleanup.
