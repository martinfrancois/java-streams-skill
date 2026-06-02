# Maintaining Agent Docs

## Scope

Use this when changing `AGENTS.md` or files under `docs/agents/`.

## Progressive Disclosure Contract

- `AGENTS.md` stays minimal and should only contain global essentials and links.
- Topic-specific guidance must live under `docs/agents/` and be linked from `AGENTS.md`.
- When the user asks to add detailed guidance to `AGENTS.md`, put the detail in `docs/agents/` and
  add or update a link instead.
- When the user corrects wording, naming, scope, eval design, public metadata, or project policy,
  make that correction durable in the relevant `docs/agents/` file.

## What May Stay In AGENTS.md

- One-sentence project description.
- One mandatory startup instruction.
- The durable-correction rule.
- Links to `docs/agents/` pages.

## What Must Move Out Of AGENTS.md

- README wording guidance.
- Example and motivation guidance.
- Skill triggering details.
- Eval and benchmark rules.
- Public metadata and release checks.
- Git/Tessl/GitHub workflow details.

## Contradictions

If a requested change conflicts with existing instructions, stop and ask the user which version to
keep. Don't auto-resolve.

## Remove Vague Rules

When editing these docs, delete or rewrite anything redundant, vague, or too obvious to be
actionable.

## Minimal Template For New Pages

```md
# <Title>

## Scope

Describe what this page covers and what it doesn't.

## Rules

- Bullet list of clear, actionable rules.

## References

- Links to related docs/agents pages.
```
