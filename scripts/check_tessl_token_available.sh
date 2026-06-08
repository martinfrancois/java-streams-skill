#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"

if [[ -n "${TESSL_TOKEN:-}" ]]; then
  echo "available=true" >> "$GITHUB_OUTPUT"
else
  echo "available=false" >> "$GITHUB_OUTPUT"
  echo "TESSL_TOKEN isn't configured; skipping Tessl publish dry-runs."
fi
