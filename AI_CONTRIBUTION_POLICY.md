# AI Contribution Policy

AI-assisted contributions are welcome when they're transparent, reviewable, and owned by a human.

## Expectations

- A human contributor is responsible for the design, docs, tests, evals, licensing, and security of
  every submitted change.
- Disclose material AI assistance in the pull request body. Short completion, search, formatting, or
  typo fixes don't need a detailed disclosure.
- Review generated changes before committing them. Don't submit changes you can't explain or
  maintain.
- Run the relevant validation locally and report the commands in the pull request.
- Don't paste Tessl tokens, GitHub tokens, package manager tokens, private repository links, private
  eval artifacts, private registry or workspace links, local host paths, proprietary Java source, or
  unrelated private data into AI tools.
- Don't add generated dependencies, vendored code, or copied snippets unless their license and origin
  are clear and compatible with this repository.
- Keep AI-generated pull requests focused. Separate broad rewrites from behavior, eval, or release
  changes when practical.

## Maintainer Review

Maintainers review AI-assisted changes by the same standard as any other contribution. Disclosure is
not a substitute for tests, evals, documentation, or careful review.
