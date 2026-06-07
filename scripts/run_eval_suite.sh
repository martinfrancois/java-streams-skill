#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/run_eval_suite.sh <main|reference|regression> [scenario ...] [-- tessl eval run args...]

Runs hosted Tessl evals with the repository's variant policy:
  main       -> without-context and with-context
  reference  -> without-context and with-context
  regression -> with-context only

Examples:
  scripts/run_eval_suite.sh main -- --label "main check"
  scripts/run_eval_suite.sh reference 05-parallel-cpu-review -- --label "targeted reference"
  scripts/run_eval_suite.sh regression -- --label "regression safety"

Do not pass --variant. This script chooses variants from the suite purpose.
USAGE
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

suite="$1"
shift

case "$suite" in
  main)
    source_dir="evals"
    variants=(--variant without-context --variant with-context)
    ;;
  reference)
    source_dir="evals-reference"
    variants=(--variant without-context --variant with-context)
    ;;
  regression)
    source_dir="evals-regression"
    variants=(--variant with-context)
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown suite: $suite" >&2
    usage >&2
    exit 2
    ;;
esac

scenarios=()
extra_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --)
      shift
      extra_args=("$@")
      break
      ;;
    --variant|--variant=*)
      echo "Do not pass --variant; scripts/run_eval_suite.sh chooses variants by suite." >&2
      exit 2
      ;;
    *)
      scenarios+=("$1")
      shift
      ;;
  esac
done

for arg in "${extra_args[@]}"; do
  case "$arg" in
    --variant|--variant=*)
      echo "Do not pass --variant; scripts/run_eval_suite.sh chooses variants by suite." >&2
      exit 2
      ;;
  esac
done

if ! command -v tessl >/dev/null 2>&1; then
  echo "tessl CLI is required to run hosted evals." >&2
  exit 127
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source_path="$repo_root/$source_dir"
if [[ ! -d "$source_path" ]]; then
  echo "Missing suite directory: $source_path" >&2
  exit 1
fi

has_agent=false
for arg in "${extra_args[@]}"; do
  case "$arg" in
    --agent|--agent=*)
      has_agent=true
      ;;
  esac
done

agent_args=()
if [[ "$has_agent" == false ]]; then
  agent_args=(--agent claude:claude-sonnet-4-6)
fi

tmp_dir="$(mktemp -d)"
backup_evals="$tmp_dir/evals-original"
staged_evals="$repo_root/evals"
if [[ "$suite" == "main" ]]; then
  source_path="$backup_evals"
fi

restore() {
  set +e
  if [[ -d "$backup_evals" ]]; then
    rm -rf "$staged_evals"
    mv "$backup_evals" "$staged_evals"
  fi
  rm -rf "$tmp_dir"
}
trap restore EXIT

mv "$staged_evals" "$backup_evals"
mkdir -p "$staged_evals"

copy_scenario() {
  local requested="$1"
  local candidate

  if [[ -d "$source_path/$requested" ]]; then
    candidate="$source_path/$requested"
  elif [[ -d "$requested" ]]; then
    candidate="$(cd "$requested" && pwd)"
  else
    local base
    base="$(basename "$requested")"
    if [[ -d "$source_path/$base" ]]; then
      candidate="$source_path/$base"
    else
      echo "Unknown $suite scenario: $requested" >&2
      exit 1
    fi
  fi

  cp -a "$candidate" "$staged_evals/"
}

if [[ "${#scenarios[@]}" -eq 0 ]]; then
  found=false
  for scenario in "$source_path"/*; do
    if [[ -d "$scenario" ]]; then
      found=true
      cp -a "$scenario" "$staged_evals/"
    fi
  done
  if [[ "$found" == false ]]; then
    echo "No scenarios found in $source_path" >&2
    exit 1
  fi
else
  for scenario in "${scenarios[@]}"; do
    copy_scenario "$scenario"
  done
fi

echo "Running $suite eval suite from the linked plugin path with a temporary evals/ staging area."
echo "Scenarios:"
find "$staged_evals" -mindepth 1 -maxdepth 1 -type d -printf '  %f\n' | sort
echo "Variants: ${variants[*]}"

(
  cd "$repo_root"
  tessl eval run "${agent_args[@]}" "${variants[@]}" "${extra_args[@]}" .
)
