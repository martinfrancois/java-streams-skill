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
- If the Tessl package is not published yet, use evergreen wording such as "After the first Tessl
  release" before install commands. Do not add live registry badges or links that currently 404, and
  do not ship README wording that will become false immediately after publication.
- Keep a table of contents after the intro and before `Getting Started`.
- Avoid fixed benchmark claims unless they match the latest hosted eval run.
- When discussing evals, explain that the Java streams skill is broadly about stream and collector
  correctness, maintainability, laziness, ordering, reduction, collection, flattening, and
  concurrency choices.
- Describe the main eval set as evidence-weighted, not `mapConcurrent`-focused: it covers core skill
  capabilities and gives more weight to scenario families where hosted runs show the largest
  with-vs-without improvement.
- When discussing evals, distinguish main eval lift scenarios from reference/regression scenarios,
  and say that broader stream and collector coverage in `evals-reference/` should be reported
  separately from the main score.
- Keep evaluation wording concrete: say what tasks check, what behavior must be preserved, and how
  to read result subsets. Avoid vague benchmark language.
- Use `main score` and `main eval set` consistently in public and maintainer docs.
- Keep public examples compact and domain-neutral: products, orders, items, addresses, packets, and
  messages are fine.
- When comparing bad and good code examples, use clear subheadings and bullet points so each reason
  belongs to the relevant example.
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
