#!/usr/bin/env bash
set -euo pipefail

commitlint_home="${RUNNER_TEMP:-$(mktemp -d)}/commitlint"
mkdir -p "$commitlint_home"
printf '{"private":true}\n' > "$commitlint_home/package.json"
cp commitlint.config.cjs "$commitlint_home/commitlint.config.cjs"
npm --prefix "$commitlint_home" install --silent --ignore-scripts \
  @commitlint/cli@21.2.2 \
  @commitlint/config-conventional@21.2.2

{
  echo "COMMITLINT_BIN=$commitlint_home/node_modules/.bin/commitlint"
  echo "COMMITLINT_CONFIG=$commitlint_home/commitlint.config.cjs"
} >> "${GITHUB_ENV:?GITHUB_ENV is required}"
