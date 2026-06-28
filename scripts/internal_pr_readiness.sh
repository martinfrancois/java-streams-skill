#!/usr/bin/env bash
set -euo pipefail
set -o pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/internal_pr_readiness.sh [mode] [pre_submit_gate options...]

Modes:
  --plan     print the staged check plan only (default)
  --targeted run the suggested targeted pre-submit checks
  --full     run targeted checks and required full suites in sequence

This is an internal, non-plugin skill for maintainer workflow:
- it delegates to scripts/pre_submit_gate.sh
- keeps quality-first ordering intact
- avoids accidental broad hosted-ramp starts by default

Examples:
  scripts/internal_pr_readiness.sh --plan
  scripts/internal_pr_readiness.sh --targeted --focus reference:05-...
  scripts/internal_pr_readiness.sh --full
USAGE
}

mode="plan"

case "${1-}" in
  --plan|--targeted|--full)
    mode="$1"
    shift
    ;;
  --help|-h)
    usage
    exit 0
    ;;
  "")
    ;;
  *)
    :
    ;;
esac

case "$mode" in
  plan)
    args=(--plan-only)
    ;;
  targeted)
    args=(--auto-continue --targeted-only)
    ;;
  full)
    args=(--auto-continue --run-broad)
    ;;
esac

exec bash "$(dirname "$0")/pre_submit_gate.sh" "${args[@]}" "$@"
