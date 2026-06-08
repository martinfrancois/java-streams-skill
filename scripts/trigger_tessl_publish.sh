#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

tag_name="${1:-}"
if [[ -z "$tag_name" ]]; then
  echo "Release Please reported a release but did not output tag_name." >&2
  exit 1
fi

gh workflow run publish-tessl.yml --repo "$GITHUB_REPOSITORY" --ref main -f ref="refs/tags/${tag_name}"
