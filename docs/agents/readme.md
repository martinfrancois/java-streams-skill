# README Guidance

## Scope

Use this when editing `README.md`, examples in public docs, install instructions, or benchmark
wording.

## Rules

- Use `Java Streams Skill for AI Agents` as the README title.
- Keep the README user-focused. Put contributor workflow details in `CONTRIBUTING.md` or
  `docs/agents/`.
- The first screen should explain the practical failure mode: agents use streams but choose weak
  terminals, collectors, ordering, primitive aggregation, null handling, or parallelism.
- The README may say agents that support skill auto-selection, such as Codex and Claude Code, can
  select the skill from context.
- Install examples should use `martinfrancois/java-streams`.
- Avoid fixed benchmark claims unless they match the latest hosted eval run.
- When discussing evals, distinguish headline lift scenarios from reference/regression scenarios.
- Keep public examples compact and domain-neutral: products, orders, items, addresses, packets, and
  messages are fine.
- Mention the JFokus reference source only as a public origin link.
- Do not include private run IDs, local paths, transcripts, tokens, or unpublished workspace data.

## References

- [Project Identity](project-identity.md)
- [Eval Guidance](evals.md)
- [Public Metadata And OSS Readiness](public-metadata.md)
