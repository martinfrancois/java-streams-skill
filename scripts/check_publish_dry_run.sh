#!/usr/bin/env bash
set -euo pipefail

path="${1:-.}"
output_file="$(mktemp)"
trap 'rm -f "$output_file"' EXIT

if ! command -v tessl >/dev/null 2>&1; then
  echo "tessl CLI is required for publish dry-run checks." >&2
  exit 127
fi

echo "Running fast Tessl plugin publish dry-run with --skip-evals."
echo "Scenario integrity is checked separately by scripts/validate_eval_criteria.py."

if tessl plugin publish --dry-run --skip-evals "$path" >"$output_file" 2>&1; then
  cat "$output_file"
  exit 0
else
  status=$?
fi

# Tessl currently reports existing versions with "already exists". If the CLI adds structured
# output for registry conflicts, prefer that over text matching.
if grep -q "already exists" "$output_file"; then
  echo "Current manifest version already exists in the registry; checking next patch version instead."
  tessl plugin publish --dry-run --skip-evals --bump patch "$path"
  echo "Publish dry-run reached the registry; next patch version is available."
  exit 0
fi

cat "$output_file"
exit "$status"
