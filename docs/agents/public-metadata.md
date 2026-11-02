# Public Metadata And OSS Readiness

## Scope

Use this when editing GitHub metadata, release readiness docs, package metadata, public docs, repo
topics, or the CodeQL code scanning settings.

## Rules

- GitHub description should be short, clickable, and user-benefit focused.
- Current preferred wording: "Help AI coding agents use Java Streams and Collectors well in new code,
  review, and cleanup without replacing one antipattern with another."
- The GitHub repository is public.
- For OSS-readiness work, `.tessl-plugin/plugin.json` should be public-ready with
  `"private": false`; this does not publish the plugin by itself.
- Do not run a real `tessl plugin publish` until the maintainer explicitly asks for that release
  step.
- Use the maximum useful number of relevant discoverability topics.
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

## CodeQL Code Scanning

- CodeQL runs through GitHub's default setup, which lives in the repository settings, not in a
  workflow file. It scans `actions` and `python` only.
- JavaScript/TypeScript scanning is off. The only JavaScript file is `commitlint.config.cjs`, which
  commitlint loads in the commitlint workflow and the skill never ships. On pull requests CodeQL
  extracts only the changed files, so a pull request that changes YAML files but not that config
  makes the JavaScript job log "Only found JavaScript or TypeScript files that were empty or
  contained syntax errors."
- Check the setting from a clone with
  `gh api repos/{owner}/{repo}/code-scanning/default-setup -q .languages`.
- When a JavaScript or TypeScript file other than CI-only config is added, such as a script or a
  file the skill ships, turn the language on:

  ```bash
  gh api -X PATCH repos/{owner}/{repo}/code-scanning/default-setup \
    -f state=configured -f 'languages[]=actions' -f 'languages[]=javascript-typescript' \
    -f 'languages[]=python'
  ```

## References

- [Project Identity](project-identity.md)
- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
