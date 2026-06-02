# Public Metadata And OSS Readiness

## Scope

Use this when editing GitHub metadata, release readiness docs, package metadata, public docs, or repo
topics.

## Rules

- GitHub description should be short, clickable, and user-benefit focused.
- Current preferred shape: "Help AI coding agents use Java Optional well in new code and cleanups,
  without replacing one antipattern with another."
- Use the maximum useful number of relevant discoverability topics when the repo becomes public.
- If asked about topics, report how many GitHub repositories exist for each topic when you can.
- Before calling the repo OSS-ready, check for a license, no private/secret references, a
  user-focused README, contributor docs, passing lint, and benchmark claims that match the current
  evals.
- Tessl packaging currently uses `.tessl-plugin/plugin.json`. Keep docs, scripts, workflows, and
  release config aligned with plugin terminology unless official docs and CLI behavior change.
- This repository currently uses `.tessl-plugin/plugin.json` as the active manifest. Do not add
  `tile.json` unless current Tessl docs and CLI behavior require it.

## References

- [Project Identity](project-identity.md)
- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
