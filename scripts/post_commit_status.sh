#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/post_commit_status.sh <sha> <context> <state> <description> <target-url>

Posts a GitHub commit status for the current repository. Requires GH_TOKEN and GITHUB_REPOSITORY.
USAGE
}

if [[ $# -ne 5 ]]; then
  usage >&2
  exit 2
fi

sha="$1"
context="$2"
state="$3"
description="$4"
target_url="$5"

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

case "$state" in
  pending|success|failure|error)
    ;;
  *)
    echo "Unsupported commit status state: $state" >&2
    exit 2
    ;;
esac

gh api "repos/${GITHUB_REPOSITORY}/statuses/${sha}" \
  -f state="$state" \
  -f context="$context" \
  -f description="$description" \
  -f target_url="$target_url" >/dev/null
