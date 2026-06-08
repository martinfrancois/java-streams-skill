# Public Metadata And OSS Readiness

## Scope

Use this when editing GitHub metadata, release readiness docs, package metadata, public docs, or repo
topics.

## Rules

- GitHub description should be short, clickable, and user-benefit focused.
- Current preferred wording: "Help AI coding agents use Java Streams and Collectors well in new code,
  review, and cleanup without replacing one antipattern with another."
- Keep the GitHub repository private until the maintainer explicitly says to make it public.
- For OSS-readiness work, `.tessl-plugin/plugin.json` should be public-ready with
  `"private": false`; this does not publish the plugin by itself.
- Do not run a real `tessl plugin publish` or make the GitHub repository public until the
  maintainer explicitly asks for that release step.
- Use the maximum useful number of relevant discoverability topics when the repo becomes public.
- Before calling the repo OSS-ready, check for a license, no private/secret references, a
  user-focused README, contributor docs, passing lint, and benchmark claims that match current
  evals.
- Tessl packaging currently uses `.tessl-plugin/plugin.json`. Keep docs, scripts, workflows, and
  release config aligned with plugin terminology unless official docs and CLI behavior change.
- Do not add `tile.json` unless current Tessl docs and CLI behavior require it.
- The workflow-pinned Tessl CLI version accepts the current plugin format with
  `.tessl-plugin/plugin.json`.
  `tessl plugin lint .`, `tessl plugin publish --dry-run --skip-evals .`, and
  `tessl plugin publish --dry-run --bump patch .` are the authority for package validity here.
  `tessl plugin pack` must include `skills/java-streams/SKILL.md` and the referenced files under
  `skills/java-streams/references/`. Do not add a `skills` field or migrate to `tile.json` unless
  those pinned CLI checks or current official docs prove the active skill is not included,
  discoverable, or publishable.

## References

- [Project Identity](project-identity.md)
- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
