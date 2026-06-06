# README Guidance

## Scope

Use this when editing `README.md`, examples in public docs, install instructions, or benchmark
wording.

## Rules

- Use `Java Streams Skill for AI Agents` as the README title.
- Keep the README user-focused. Put contributor workflow details in `CONTRIBUTING.md` or
  `docs/agents/`.
- The first screen should explain the practical failure mode: agents use streams but choose weak
  stream terminal operations, collectors, ordering, primitive aggregation, null handling, or
  parallelism.
- The README may say agents that support skill auto-selection, such as Codex and Claude Code, can
  select the skill from context.
- Install examples should use `martinfrancois/java-streams`.
- Treat public docs as release-ready even while the GitHub repository is still private. Keep the
  Tessl badge and published-install wording unless the maintainer explicitly asks to hide them.
- Keep a table of contents after the intro and before `Getting Started`.
- Avoid fixed benchmark claims unless they match the latest hosted eval run.
- When discussing evals, distinguish main eval lift scenarios from reference/regression scenarios.
- Keep evaluation wording concrete: say what tasks check, what behavior must be preserved, and how
  to read result subsets. Avoid vague benchmark language.
- Use `main score` and `main eval set` consistently in public and maintainer docs.
- Keep public examples compact and domain-neutral: products, orders, items, addresses, packets, and
  messages are fine.
- When comparing bad and good code examples, use clear subheadings and bullet points so each reason
  belongs to the relevant example.
- README code examples copied from hosted eval outputs or reference runs are evidence examples.
  Do not "fix" or harden those snippets during review cleanup unless the maintainer explicitly asks
  to change the underlying example; update surrounding explanation instead.
- When explaining `Gatherers.mapConcurrent` for remote checks, mention bounded concurrency with
  backpressure: keep limited work in flight and start more as earlier checks finish.
- Keep broad mistake catalogs separate from individual examples so they do not read as part of one
  specific example.
- Avoid `pipeline` for Java stream code; use `stream chain`, `stream operation`, or more specific
  wording. Reserve `pipeline` for CI/release contexts.
- Mention the JFokus reference source only as a public origin link. Use the full name
  `François Martin` in origin wording.
- Do not include private run IDs, local paths, transcripts, tokens, or unpublished workspace data.

## References

- [Project Identity](project-identity.md)
- [Eval Guidance](evals.md)
- [Public Metadata And OSS Readiness](public-metadata.md)
