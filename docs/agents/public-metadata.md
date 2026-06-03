# Public Metadata And OSS Readiness

## Scope

Use this when editing GitHub metadata, release readiness docs, package metadata, public docs, or repo
topics.

## Rules

- GitHub description should be short, clickable, and user-benefit focused.
- Current preferred shape: "Help AI coding agents use Java Streams and Collectors well in new code,
  review, and cleanup without replacing one antipattern with another."
- Keep the GitHub repository private until the maintainer explicitly says to make it public.
- Keep `.tessl-plugin/plugin.json` private until the maintainer says to publish publicly.
- Use the maximum useful number of relevant discoverability topics when the repo becomes public.
- Before calling the repo OSS-ready, check for a license, no private/secret references, a
  user-focused README, contributor docs, passing lint, and benchmark claims that match current
  evals.
- Tessl packaging currently uses `.tessl-plugin/plugin.json`. Keep docs, scripts, workflows, and
  release config aligned with plugin terminology unless official docs and CLI behavior change.
- Do not add `tile.json` unless current Tessl docs and CLI behavior require it.

## References

- [Project Identity](project-identity.md)
- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
