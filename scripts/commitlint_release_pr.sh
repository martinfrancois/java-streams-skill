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
# shellcheck source=scripts/lib/commitlint_install.sh
. "$(dirname "$0")/lib/commitlint_install.sh"
install_commitlint "${RUNNER_TEMP:-$(mktemp -d)}/commitlint"
commitlint_bin="$COMMITLINT_BIN"
commitlint_config="$COMMITLINT_CONFIG"

printf '%s\n' "$pr_title" | "$commitlint_bin" --config "$commitlint_config"
"$commitlint_bin" --config "$commitlint_config" \
  --from origin/main --to HEAD --verbose
