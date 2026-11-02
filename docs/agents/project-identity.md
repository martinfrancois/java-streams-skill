# Project Identity

## Scope

Use this when naming the repository, skill, package, workspace, or public source links.

## Rules

- Repository name: `java-streams-skill`.
- Skill name: `java-streams`.
- Tessl package name: `martinfrancois/java-streams`.
- Tessl workspace: `martinfrancois`.
- The GitHub repository is public.
- The Tessl plugin is published on the registry as public, from `.tessl-plugin/plugin.json` with
  `"private": false`. Tessl calls making a plugin public irreversible, so keep `"private": false`
  and never set it back to `true`.
- The repository should remain open-source ready: MIT license, security policy, contributor
  docs, public-safe README, public-safe metadata, and no private transcript or secret references.
- If `tessl project repair` cannot relink this checkout and the Tessl project needs to be
  recreated, use the pinned CLI project command:

  ```bash
  tessl project create --workspace martinfrancois java-streams-skill
  ```

  Do this only for project identity recovery. It is not part of normal plugin publishing, release,
  or eval execution.

- Public origin links may point to
  `https://github.com/martinfrancois/jfokus-2026/blob/main/code.md`.

## References

- [Public Metadata And OSS Readiness](public-metadata.md)
- [Workflow](workflow.md)
