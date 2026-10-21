#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/commitlint_install.sh
. "$(dirname "$0")/lib/commitlint_install.sh"
install_commitlint "${RUNNER_TEMP:-$(mktemp -d)}/commitlint"

{
  echo "COMMITLINT_BIN=$COMMITLINT_BIN"
  echo "COMMITLINT_CONFIG=$COMMITLINT_CONFIG"
} >> "${GITHUB_ENV:?GITHUB_ENV is required}"
