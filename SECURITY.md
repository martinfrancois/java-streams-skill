# Security Policy

If you believe you've found a security issue in Java Optional Skill for AI Agents, report it
privately first.

This policy gives reporters a clear path and explains what maintainers treat as a security issue.
This project is a Tessl skill, eval suite, and release pipeline. It's not a runtime application or a
shared service.

## Supported Versions

Only the most recent published release is supported with security updates unless a maintainer
announces a different support window in the release notes.

| Version | Supported |
| ------- | --------- |
| Most recent published release | Yes |
| Any older release | No |

## Reporting a Vulnerability

Don't open a public issue for a suspected vulnerability.

Use GitHub private vulnerability reporting through
[Report a Vulnerability](https://github.com/martinfrancois/java-optionals-skill/security/advisories/new).
If GitHub private vulnerability reporting isn't working for you, contact the maintainers privately
through GitHub and share only the minimum information needed to start triage.

Don't open a public issue or pull request that discloses an unpatched vulnerability, exploit path,
secret, or security-sensitive proof of concept. Maintainers may hide, delete, or close public reports
that disclose sensitive details and will redirect them to the private reporting path.

Make the report easy to reproduce and easy to route. Include:

- the affected commit, release, or Tessl plugin version;
- a short description of the impact;
- reproduction steps or a proof of concept using a minimal Java example, sanitized eval fixture, or
  isolated test repository/workspace;
- if the report affects a released plugin, evidence from the published plugin version;
- any focused fix or mitigation idea you can share;
- relevant logs with secrets removed.

Don't include Tessl tokens, GitHub tokens, package manager tokens, private repository links, private
eval artifacts, private registry/workspace links, local host paths, or unrelated system details.

You can expect an initial maintainer response within 7 days. If the report is accepted, maintainers
will coordinate the fix privately, publish a security advisory when appropriate, and credit reporters
who want public credit. If the report is declined, maintainers will explain why it isn't considered a
project security issue or why it belongs in a normal public issue instead.

## Project Boundary

Security reports should show impact caused by this repository, the published Tessl plugin, or this
repository's CI and release setup.

This includes this repository's GitHub Actions workflows, repository settings, branch rules, token
permissions, secrets, dependency update rules, release automation, and Tessl publish setup.

If the same issue would affect any Tessl plugin, any GitHub Actions repository, any package-manager
install command, any Java project, or any coding agent in the same way, report it to the upstream
project instead. Send it here only when this repository's configuration, published content, evals, or
release process adds a project-specific security impact.

## What Counts as a Security Issue

These reports should usually be handled privately:

- exposed project-owned credentials, such as `TESSL_TOKEN`, GitHub tokens, package manager tokens,
  release credentials, or maintainer-only registry credentials;
- GitHub Actions, release, Renovate, or Tessl publish behavior that lets untrusted code run with
  secrets or publish the plugin without the expected checks;
- repository-specific supply-chain paths where a malicious dependency update, action update,
  workflow change, or generated pull request could run with this repository's secrets, write access,
  or publish permissions;
- repository settings or rules that let someone bypass protected `main` changes, required checks, or
  release approval in a way they shouldn't be able to;
- published skill instructions or package files that were changed to make agents expose secrets, run
  unrelated unsafe commands, publish private data, or weaken user security;
- eval fixtures or criteria that can be used through CI, Tessl runs, or published artifacts to expose
  secrets, run unintended commands, or change release behavior;
- dependency or toolchain vulnerabilities with a working reproduction that shows impact through this
  repository, its CI, its release process, or the published Tessl plugin;
- an upstream Tessl, GitHub, package-manager, Java, or coding-agent issue that becomes exploitable
  here because of this repository's configuration or published plugin content.

## What Usually Isn't a Security Issue

These reports usually belong in a normal public issue or pull request:

- disagreement with Java `Optional` style guidance, wording, examples, or eval scoring;
- an AI agent producing bad Java code when there's no secret exposure, unsafe instruction
  compromise, CI/release bypass, or other security impact;
- prompt injection against a downstream agent by itself, unless it also shows a secret leak, tool
  boundary bypass, compromised published skill content, or release/publish impact;
- CI failures, flaky evals, stale documentation, or broken install commands without sensitive data
  exposure or unauthorized release impact;
- Tessl CLI, Tessl registry, or Tessl account issues that affect all plugins in the same way and don't
  depend on this plugin's content, metadata, CI, or release setup;
- GitHub platform, GitHub Actions, CodeQL, or private vulnerability reporting behavior that isn't
  caused by this repository's workflow files, permissions, secrets, rules, or settings;
- `npm`, `yarn`, `pnpm`, `bun`, Java, JDK, or build-tool behavior that isn't specific to this
  repository or published plugin;
- coding-agent, model, IDE, or editor vulnerabilities that aren't caused by this skill's published
  instructions or package files;
- vulnerabilities in a user's own Java application or repository after using this skill, unless the
  published skill content caused the unsafe behavior;
- scanner-only or dependency-only reports without a working reproduction and project-specific
  impact;
- reports that require a maintainer to already have a compromised machine, install a malicious local
  tool, or change trusted local files by hand;
- public information such as package names, repository names, issue links, or normal GitHub metadata.

If you're unsure, report privately. It's better to route a careful report than to publish sensitive
details by mistake.

## Credential Handling

Java Optional Skill for AI Agents is a Tessl skill and eval suite, not a runtime application.
Security reports are most likely to involve credential exposure, unsafe skill instructions, eval
fixtures or criteria, GitHub Actions logs, release/publish automation, repository settings, or the
published Tessl plugin.

Treat reports involving these files or systems as sensitive even when the visible symptom looks like
a normal documentation, CI, or publishing failure:

- `.github/workflows/` and repository settings;
- `.tessl-plugin/`, `skills/`, `evals/`, and `evals-reference/`;
- Tessl registry publishing and `TESSL_TOKEN`;
- GitHub Actions logs, release automation, and dependency update automation.

## Learning More About Security

For general software security background, review the
[OWASP Top Ten](https://owasp.org/www-project-top-ten/) and other resources from the
[Open Worldwide Application Security Project](https://owasp.org/).
