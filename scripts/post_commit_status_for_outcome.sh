#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/post_commit_status_for_outcome.sh <sha> <context> <outcome> <success-description> <failure-description> <target-url>
USAGE
}

if [[ $# -ne 6 ]]; then
  usage >&2
  exit 2
fi

sha="$1"
context="$2"
outcome="$3"
success_description="$4"
failure_description="$5"
target_url="$6"

case "$outcome" in
  success)
    state="success"
    description="$success_description"
    ;;
  failure|cancelled|skipped)
    state="failure"
    description="$failure_description"
    ;;
  *)
    echo "Unsupported GitHub Actions outcome: $outcome" >&2
    exit 2
    ;;
esac

scripts/post_commit_status.sh "$sha" "$context" "$state" "$description" "$target_url"
[[ "$outcome" == "success" ]]
