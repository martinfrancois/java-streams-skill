#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

write_gh_stub() {
  local exact_output="$1"
  local fallback_output="${2:-}"
  mkdir -p "$tmp_dir/bin"
  cat > "$tmp_dir/bin/gh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$*" != pr\ list* ]]; then
  echo "unexpected gh invocation: $*" >&2
  exit 1
fi

if [[ "$*" == *"--head release-please--branches--main--components--java-streams"* ]]; then
  printf '%s\n' "${GH_STUB_EXACT_OUTPUT:-}"
else
  printf '%s\n' "${GH_STUB_FALLBACK_OUTPUT:-}"
fi
STUB
  chmod +x "$tmp_dir/bin/gh"
  GH_STUB_EXACT_OUTPUT="$exact_output"
  GH_STUB_FALLBACK_OUTPUT="$fallback_output"
}

run_case() {
  local name="$1"
  local release_pr="$2"
  local gh_exact_output="$3"
  local gh_fallback_output="$4"
  local expected_found="$5"
  local expected_branch="${6:-}"

  local output_file="$tmp_dir/$name.out"
  : > "$output_file"
  write_gh_stub "$gh_exact_output" "$gh_fallback_output"

  (
    export PATH="$tmp_dir/bin:$PATH"
    export GITHUB_OUTPUT="$output_file"
    export RELEASE_PR="$release_pr"
    export GH_STUB_EXACT_OUTPUT
    export GH_STUB_FALLBACK_OUTPUT
    "$repo_root/scripts/read_release_pr_output.sh"
  )

  if ! grep -qx "found=$expected_found" "$output_file"; then
    echo "case '$name' expected found=$expected_found" >&2
    cat "$output_file" >&2
    exit 1
  fi

  if [[ -n "$expected_branch" ]] && ! grep -qx "$expected_branch" "$output_file"; then
    echo "case '$name' expected branch output '$expected_branch'" >&2
    cat "$output_file" >&2
    exit 1
  fi
}

run_case \
  "release-pr-json" \
  '{"title":"chore: release 1.2.3","headBranchName":"release-please--branches--main--components--java-streams"}' \
  "" \
  "" \
  "true" \
  "release-please--branches--main--components--java-streams"

run_case \
  "fallback-exact-branch-without-labels" \
  "" \
  '{"title":"chore: release 1.2.3","headBranchName":"release-please--branches--main--components--java-streams"}' \
  "" \
  "true" \
  "release-please--branches--main--components--java-streams"

run_case \
  "fallback-prefix-without-labels" \
  "" \
  "" \
  '{"title":"chore: release 1.2.3","headBranchName":"release-please--branches--main--components--java-streams"}' \
  "true" \
  "release-please--branches--main--components--java-streams"

run_case \
  "fallback-empty" \
  "" \
  "" \
  "" \
  "false"

echo "read_release_pr_output smoke tests passed"
