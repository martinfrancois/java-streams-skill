#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"

release_pr="${RELEASE_PR:-}"
if [[ -z "$release_pr" || "$release_pr" == "null" ]]; then
  echo "Release Please did not emit a PR output; checking for an unchanged open release PR."
  release_branch="release-please--branches--main--components--java-streams"
  release_branch_prefix="release-please--branches--main"
  release_pr="$(gh pr list \
    --state open \
    --base main \
    --head "$release_branch" \
    --json title,headRefName \
    --jq 'map({title, headBranchName: .headRefName}) | .[0] // empty')"

  if [[ -z "$release_pr" ]]; then
    release_pr="$(gh pr list \
      --state open \
      --base main \
      --limit 100 \
      --json title,headRefName \
      --jq "map(select(.headRefName | startswith(\"$release_branch_prefix\")) | {title, headBranchName: .headRefName}) | sort_by(.headBranchName) | .[0] // empty")"
  fi

  if [[ -z "$release_pr" ]]; then
    echo "No open release PR to check."
    echo "found=false" >> "$GITHUB_OUTPUT"
    exit 0
  fi
fi

title="$(printf '%s\n' "$release_pr" | jq -r '.title')"
branch="$(printf '%s\n' "$release_pr" | jq -r '.headBranchName')"

if [[ -z "$title" || "$title" == "null" || -z "$branch" || "$branch" == "null" ]]; then
  echo "Release Please returned a release PR without title or headBranchName." >&2
  printf '%s\n' "$release_pr" >&2
  exit 1
fi

{
  echo "found=true"
  echo "title<<EOF"
  printf '%s\n' "$title"
  echo "EOF"
  echo "branch<<EOF"
  printf '%s\n' "$branch"
  echo "EOF"
} >> "$GITHUB_OUTPUT"
