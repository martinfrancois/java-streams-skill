#!/usr/bin/env bash
set -euo pipefail

: "${COMMITLINT_BIN:?COMMITLINT_BIN is required}"
: "${COMMITLINT_CONFIG:?COMMITLINT_CONFIG is required}"
: "${EVENT_NAME:?EVENT_NAME is required}"

if [[ "$EVENT_NAME" == "pull_request" ]]; then
  : "${PR_BASE_SHA:?PR_BASE_SHA is required for pull_request events}"
  : "${PR_HEAD_SHA:?PR_HEAD_SHA is required for pull_request events}"
  "$COMMITLINT_BIN" --config "$COMMITLINT_CONFIG" \
    --from "$PR_BASE_SHA" --to "$PR_HEAD_SHA" --verbose
else
  base_ref="${BASE_REF:-main}"
  git fetch origin "$base_ref"
  "$COMMITLINT_BIN" --config "$COMMITLINT_CONFIG" \
    --from "origin/$base_ref" --to HEAD --verbose
fi
