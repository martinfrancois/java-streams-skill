#!/usr/bin/env bash
# Sourced by scripts/install_commitlint.sh and scripts/commitlint_release_pr.sh.
# install_commitlint <dir> installs the pinned commitlint packages into <dir>
# with this repository's config and sets COMMITLINT_BIN and COMMITLINT_CONFIG.
# Renovate updates the two pins here; this is the only place they live.

install_commitlint() {
  local commitlint_home="$1"
  mkdir -p "$commitlint_home"
  printf '{"private":true}\n' > "$commitlint_home/package.json"
  cp commitlint.config.cjs "$commitlint_home/commitlint.config.cjs"
  pnpm --dir "$commitlint_home" add --silent --ignore-scripts \
    @commitlint/cli@21.2.4 \
    @commitlint/config-conventional@21.2.4
  COMMITLINT_BIN="$commitlint_home/node_modules/.bin/commitlint"
  COMMITLINT_CONFIG="$commitlint_home/commitlint.config.cjs"
  export COMMITLINT_BIN COMMITLINT_CONFIG
}
