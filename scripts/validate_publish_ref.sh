#!/usr/bin/env bash
set -euo pipefail

event_name="${EVENT_NAME:-}"
release_tag="${RELEASE_TAG:-}"
manual_ref="${MANUAL_REF:-}"
allow_non_tag_ref="${ALLOW_NON_TAG_REF:-false}"

plugin_version="$(python3 - <<'PY'
import json
print(json.load(open(".tessl-plugin/plugin.json", encoding="utf-8"))["version"])
PY
)"
expected_tag="v${plugin_version}"

echo "plugin_version=${plugin_version}"
echo "expected_tag=${expected_tag}"

if [[ "$event_name" == "release" ]]; then
  if [[ "$release_tag" != "$expected_tag" ]]; then
    echo "Release tag '${release_tag}' must match plugin version tag '${expected_tag}'." >&2
    exit 1
  fi
  exit 0
fi

if [[ -z "$manual_ref" ]]; then
  echo "Manual publish requires an explicit ref input." >&2
  exit 1
fi

git fetch --force --tags origin '+refs/tags/*:refs/tags/*'

if [[ "$manual_ref" == "refs/tags/${expected_tag}" ]]; then
  exit 0
fi

if [[ "$manual_ref" == "$expected_tag" ]]; then
  echo "Manual release publishes must use fully qualified tag ref 'refs/tags/${expected_tag}'." >&2
  exit 1
fi

tag_ref="${manual_ref#refs/tags/}"
if git show-ref --verify --quiet "refs/tags/${tag_ref}"; then
  echo "Manual release tag '${manual_ref}' must match 'refs/tags/${expected_tag}'." >&2
  exit 1
fi

if [[ "$allow_non_tag_ref" != "true" ]]; then
  echo "Manual publish from non-tag ref '${manual_ref}' requires allow_non_tag_ref=true." >&2
  exit 1
fi

echo "Publishing non-tag ref '${manual_ref}' with explicit maintainer override."
