#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${TESSL_TOKEN:-}" ]]; then
  echo "TESSL_TOKEN is required to publish the Tessl plugin." >&2
  exit 1
fi
