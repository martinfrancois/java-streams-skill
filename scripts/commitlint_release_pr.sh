#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/commitlint_release_pr.sh <pull-request-title>

Lints the Release Please PR title and commits from origin/main to HEAD.
USAGE
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

pr_title="$1"
commitlint_home="${RUNNER_TEMP:-$(mktemp -d)}/commitlint"
mkdir -p "$commitlint_home"
printf '{"private":true}\n' > "$commitlint_home/package.json"
cp commitlint.config.cjs "$commitlint_home/commitlint.config.cjs"
npm --prefix "$commitlint_home" install --silent --ignore-scripts \
  @commitlint/cli@21.0.2 \
  @commitlint/config-conventional@21.0.2

commitlint_bin="$commitlint_home/node_modules/.bin/commitlint"
commitlint_config="$commitlint_home/commitlint.config.cjs"

printf '%s\n' "$pr_title" | "$commitlint_bin" --config "$commitlint_config"
"$commitlint_bin" --config "$commitlint_config" \
  --from origin/main --to HEAD --verbose
