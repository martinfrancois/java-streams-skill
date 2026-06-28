#!/usr/bin/env bash
set -euo pipefail
set -o pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/pre_submit_gate.sh [options]

Run the pre-submit hosted-eval gate used for final skill/runtime changes.

Behavior:
- Always runs quality review first (or exits early if it is below threshold).
- Computes changed files against BASE_REF and builds targeted eval commands for changed
  eval scenario directories.
- Uses lightweight impact analysis for runtime-only changes to choose early targeted probes.
- Runs targeted evals first.
- Records scenario-level passing evidence for the current skill bundle fingerprint and skips
  already-proven scenarios when broadening.
- For runtime/reference changes, continues to full suite checks after targeted evals pass unless
  explicitly constrained to targeted-only mode.

Options:
  --base-ref <ref>      Git ref to diff against for changed files (default:
                        origin/main)
  --skill-dir <path>    Skill directory for quality review
                        (default: skills/java-streams)
  --plan-only           Print the staged plan and do not run hosted eval commands.
  --run-broad           After targeted evals clean, run main then reference then
                        regression.
  --targeted-only       Skip full-suite expansion; run only explicitly targeted scope.
  --impact-limit <n>    Maximum impact-analysis scenarios to add for runtime
                        changes (default: 4).
  --no-impact-analysis  Disable runtime-change impact-analysis focus suggestions.
  --risk-limit <n>      Maximum historical risk probes to add for runtime
                        changes (default: 6).
  --risk-probe-file <path>
                        Historical risk probe list (default:
                        docs/agents/eval-risk-probes.txt).
  --no-risk-probes      Disable historical risk probes.
  --target-batch-size <n>
                        Maximum same-suite targeted scenarios per hosted run
                        (default: 1). Smaller batches discover failures with
                        fewer wasted eval-solutions.
  --broad-batch-mode <mode>
                        Broad-stage batching: balanced, progressive, or suite
                        (default: balanced).
  --broad-order <order> Comma-separated broad-stage order, or auto
                        (default: auto). Example: regression,main,reference.
  --evidence-file <path>
                        Scenario evidence cache (default:
                        .tessl/eval-evidence/java-streams-pre-submit.json)
  --reset-evidence      Clear the evidence cache before planning.
  --ignore-evidence     Do not skip scenarios already recorded as passing.
  --focus <scope:scenario>
                        Add a manual focus scenario, e.g. main:02-delivery...
                        Useful when runtime text changed without scenario-scoped
                        eval edits.
  --auto-continue       Skip confirm prompts between hosted stages.
  -h, --help            Show this help.

Examples:
  scripts/pre_submit_gate.sh --base-ref origin/main --plan-only
  scripts/pre_submit_gate.sh --run-broad
  scripts/pre_submit_gate.sh --focus main:02-delivery-appointments-mapconcurrent
USAGE
}

need_confirmation=true
run_broad=false
targeted_only=false
plan_only=false
base_ref="origin/main"
skill_dir="skills/java-streams"
evidence_file=".tessl/eval-evidence/java-streams-pre-submit.json"
use_evidence=true
reset_evidence=false
runtime_fingerprint=""
broad_order_arg="auto"
impact_limit=4
use_impact_analysis=true
risk_limit=6
risk_probe_file="docs/agents/eval-risk-probes.txt"
use_risk_probes=true
target_batch_size=1
broad_batch_mode="balanced"
review_workspace="${TESSL_REVIEW_WORKSPACE:-}"
focus_entries=()
impact_focus_main=()
impact_focus_reference=()
impact_focus_regression=()
risk_focus_main=()
risk_focus_reference=()
risk_focus_regression=()
explicit_focus_ordered=()
impact_focus_ordered=()
risk_focus_ordered=()
target_queue_suites=()
target_queue_scenarios=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-ref)
      if [[ $# -lt 2 ]]; then
        echo "--base-ref requires an argument" >&2
        exit 2
      fi
      base_ref="$2"
      shift 2
      ;;
    --skill-dir)
      if [[ $# -lt 2 ]]; then
        echo "--skill-dir requires an argument" >&2
        exit 2
      fi
      skill_dir="$2"
      shift 2
      ;;
    --plan-only)
      plan_only=true
      shift
      ;;
    --run-broad)
      run_broad=true
      shift
      ;;
    --targeted-only)
      targeted_only=true
      shift
      ;;
    --impact-limit)
      if [[ $# -lt 2 ]]; then
        echo "--impact-limit requires an argument" >&2
        exit 2
      fi
      if [[ ! "$2" =~ ^[0-9]+$ ]]; then
        echo "--impact-limit must be a non-negative integer" >&2
        exit 2
      fi
      impact_limit="$2"
      shift 2
      ;;
    --no-impact-analysis)
      use_impact_analysis=false
      shift
      ;;
    --risk-limit)
      if [[ $# -lt 2 ]]; then
        echo "--risk-limit requires an argument" >&2
        exit 2
      fi
      if [[ ! "$2" =~ ^[0-9]+$ ]]; then
        echo "--risk-limit must be a non-negative integer" >&2
        exit 2
      fi
      risk_limit="$2"
      shift 2
      ;;
    --risk-probe-file)
      if [[ $# -lt 2 ]]; then
        echo "--risk-probe-file requires an argument" >&2
        exit 2
      fi
      risk_probe_file="$2"
      shift 2
      ;;
    --no-risk-probes)
      use_risk_probes=false
      shift
      ;;
    --target-batch-size)
      if [[ $# -lt 2 ]]; then
        echo "--target-batch-size requires an argument" >&2
        exit 2
      fi
      if [[ ! "$2" =~ ^[1-9][0-9]*$ ]]; then
        echo "--target-batch-size must be a positive integer" >&2
        exit 2
      fi
      target_batch_size="$2"
      shift 2
      ;;
    --broad-batch-mode)
      if [[ $# -lt 2 ]]; then
        echo "--broad-batch-mode requires an argument" >&2
        exit 2
      fi
      case "$2" in
        balanced|progressive|suite)
          broad_batch_mode="$2"
          ;;
        *)
          echo "--broad-batch-mode must be balanced, progressive, or suite" >&2
          exit 2
          ;;
      esac
      shift 2
      ;;
    --broad-order)
      if [[ $# -lt 2 ]]; then
        echo "--broad-order requires an argument" >&2
        exit 2
      fi
      broad_order_arg="$2"
      shift 2
      ;;
    --evidence-file)
      if [[ $# -lt 2 ]]; then
        echo "--evidence-file requires an argument" >&2
        exit 2
      fi
      evidence_file="$2"
      shift 2
      ;;
    --reset-evidence)
      reset_evidence=true
      shift
      ;;
    --ignore-evidence)
      use_evidence=false
      shift
      ;;
    --focus)
      if [[ $# -lt 2 ]]; then
        echo "--focus requires a <scope:scenario> argument" >&2
        exit 2
      fi
      focus_entries+=("$2")
      shift 2
      ;;
    --auto-continue)
      need_confirmation=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v tessl >/dev/null 2>&1; then
  echo "tessl CLI is required for pre-submit checks." >&2
  exit 127
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ ! -d "$skill_dir" ]]; then
  echo "Missing skill directory: $skill_dir" >&2
  exit 1
fi

detect_local_eval_runners() {
  local proc pid cmd proc_cwd found=false

  for proc in /proc/[0-9]*; do
    pid="${proc##*/}"
    [[ "$pid" == "$$" || "$pid" == "$PPID" ]] && continue

    [[ -r "$proc/cmdline" ]] || continue
    cmd="$( (tr '\0' ' ' < "$proc/cmdline") 2>/dev/null || true)"
    [[ -z "$cmd" ]] && continue
    case "$cmd" in
      "tessl eval run"*|*"/tessl eval run"*|*"scripts/run_eval_suite.sh"*|*"scripts/pre_submit_gate.sh"*)
        proc_cwd="$(readlink "$proc/cwd" 2>/dev/null || true)"
        if [[ "$proc_cwd" == "$repo_root" || "$proc_cwd" == "$repo_root"/* ]]; then
          if [[ "$found" == false ]]; then
            echo "Another local eval runner is already active for this repo:" >&2
            found=true
          fi
          echo "  pid=$pid cwd=$proc_cwd cmd=$cmd" >&2
        fi
        ;;
    esac
  done

  if [[ "$found" == true ]]; then
    echo "Stop the existing runner before starting a new pre-submit gate." >&2
    return 1
  fi
}

detect_local_eval_runners

if [[ -z "$review_workspace" && -f tessl.json ]]; then
  review_workspace="$(
    python3 - <<'PY'
import json
from pathlib import Path

try:
    name = json.loads(Path("tessl.json").read_text()).get("name", "")
except Exception:
    name = ""
print(name.split("/", 1)[0] if "/" in name else "")
PY
  )"
fi

changed_main=()
changed_reference=()
changed_regression=()
explicit_focus_main=()
explicit_focus_reference=()
explicit_focus_regression=()
planned_passed_main=()
planned_passed_reference=()
planned_passed_regression=()

collect_changed() {
  local file scope scenario
  local changed_list

  changed_list="$(mktemp)"
  git diff --name-only "$base_ref"...HEAD -- > "$changed_list" || true
  git diff --name-only -- >> "$changed_list" || true
  git diff --cached --name-only -- >> "$changed_list" || true
  git ls-files -o --exclude-standard >> "$changed_list" || true

  while IFS= read -r file; do
    [[ -z "$file" ]] && continue

    case "$file" in
      evals/*/*)
        scope="${file%%/*}"
        scenario="$(echo "$file" | awk -F/ '{print $2}')"
        if [[ "$scope" == "evals" ]]; then
          changed_main+=("$scenario")
        fi
        ;;
      evals-reference/*/*)
        scope="${file%%/*}"
        scenario="$(echo "$file" | awk -F/ '{print $2}')"
        if [[ "$scope" == "evals-reference" ]]; then
          changed_reference+=("$scenario")
        fi
        ;;
      evals-regression/*/*)
        scope="${file%%/*}"
        scenario="$(echo "$file" | awk -F/ '{print $2}')"
        if [[ "$scope" == "evals-regression" ]]; then
          changed_regression+=("$scenario")
        fi
        ;;
    esac
  done < "$changed_list"

  rm -f "$changed_list"
}

normalize_targets() {
  local src=("$@")
  local uniq
  local -A seen

  uniq=()
  for item in "${src[@]}"; do
    [[ -z "$item" ]] && continue
    if [[ -n "${seen[$item]:-}" ]]; then
      continue
    fi
    seen["$item"]=1
    uniq+=("$item")
  done
  printf '%s\n' "${uniq[@]}"
}

suite_scenarios() {
  local suite="$1"
  python3 scripts/eval_evidence.py list --repo-root "$repo_root" --suite "$suite"
}

remaining_scenarios() {
  local suite="$1"
  shift
  local candidates=()
  local planned=()
  local scenario
  local -A planned_seen=()

  if [[ "$use_evidence" != true ]]; then
    if [[ $# -gt 0 ]]; then
      candidates=("$@")
    else
      mapfile -t candidates < <(suite_scenarios "$suite")
    fi
  else
    mapfile -t candidates < <(python3 scripts/eval_evidence.py remaining \
      --file "$evidence_file" \
      --fingerprint "$runtime_fingerprint" \
      --repo-root "$repo_root" \
      --suite "$suite" \
      "$@")
  fi

  if [[ "$plan_only" == true && "$use_evidence" == true ]]; then
    case "$suite" in
      main) planned=("${planned_passed_main[@]}") ;;
      reference) planned=("${planned_passed_reference[@]}") ;;
      regression) planned=("${planned_passed_regression[@]}") ;;
    esac

    for scenario in "${planned[@]}"; do
      planned_seen["$scenario"]=1
    done
  fi

  for scenario in "${candidates[@]}"; do
    if [[ -n "${planned_seen[$scenario]:-}" ]]; then
      continue
    fi
    printf '%s\n' "$scenario"
  done
}

remaining_targeted_scenarios() {
  local suite="$1"
  shift

  if [[ $# -eq 0 ]]; then
    return 0
  fi
  remaining_scenarios "$suite" "$@"
}

mark_scenarios_passed() {
  local suite="$1"
  shift

  if [[ "$plan_only" == true || "$use_evidence" != true || $# -eq 0 ]]; then
    return
  fi

  python3 scripts/eval_evidence.py mark \
    --file "$evidence_file" \
    --fingerprint "$runtime_fingerprint" \
    --repo-root "$repo_root" \
    --suite "$suite" \
    "$@"
}

mark_run_passing_scenarios() {
  local suite="$1"
  local run_log="$2"
  local passed=()

  if [[ "$plan_only" == true || "$use_evidence" != true ]]; then
    return
  fi

  mapfile -t passed < <(python3 scripts/eval_evidence.py passing \
    --run-json "$run_log" \
    --repo-root "$repo_root" \
    --suite "$suite")

  if [[ "${#passed[@]}" -eq 0 ]]; then
    return
  fi

  echo "Recording passing scenario evidence for $suite: ${passed[*]}"
  mark_scenarios_passed "$suite" "${passed[@]}"
}

mark_scenarios_planned() {
  local suite="$1"
  shift

  if [[ "$plan_only" != true || $# -eq 0 ]]; then
    return
  fi

  case "$suite" in
    main)
      planned_passed_main+=("$@")
      mapfile -t planned_passed_main < <(normalize_targets "${planned_passed_main[@]}")
      ;;
    reference)
      planned_passed_reference+=("$@")
      mapfile -t planned_passed_reference < <(normalize_targets "${planned_passed_reference[@]}")
      ;;
    regression)
      planned_passed_regression+=("$@")
      mapfile -t planned_passed_regression < <(normalize_targets "${planned_passed_regression[@]}")
      ;;
  esac
}

run_quality_review() {
  local skill_path="$1"
  local threshold="${2:-100}"
  local args=()
  local output
  local status

  if [[ -n "$review_workspace" ]]; then
    args+=(--workspace "$review_workspace")
  fi

  set +e
  output="$(tessl review run "${args[@]}" --threshold "$threshold" "$skill_path" 2>&1)"
  status=$?
  set -e

  if [[ $status -eq 0 ]]; then
    echo "$output"
    return 0
  fi

  if echo "$output" | grep -qiE "unknown command|unknown flag|No help topic"; then
    echo "Top-level tessl review command is unavailable. Falling back to legacy tessl skill review."
    set +e
    output="$(tessl skill review --threshold "$threshold" "$skill_path" 2>&1)"
    status=$?
    set -e
  fi

  echo "$output"
  return "$status"
}

collect_focus() {
  local entry scope scenario

  for entry in "${focus_entries[@]}"; do
    scope="${entry%%:*}"
    scenario="${entry#*:}"
    [[ -z "$scope" || -z "$scenario" || "$scope" == "$entry" ]] && {
      echo "Invalid --focus value '$entry' (expected <scope>:<scenario>)" >&2
      exit 2
    }

    case "$scope" in
      main)
        explicit_focus_main+=("$scenario")
        explicit_focus_ordered+=("$scope:$scenario")
        ;;
      reference)
        explicit_focus_reference+=("$scenario")
        explicit_focus_ordered+=("$scope:$scenario")
        ;;
      regression)
        explicit_focus_regression+=("$scenario")
        explicit_focus_ordered+=("$scope:$scenario")
        ;;
      *)
        echo "Unknown focus scope '$scope' in '$entry'." >&2
        exit 2
        ;;
    esac
  done
}

collect_impact_focus() {
  local entry scope scenario

  if [[ "$changed_runtime" != true || "$use_impact_analysis" != true || "$impact_limit" -le 0 ]]; then
    return
  fi

  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    scope="${entry%%:*}"
    scenario="${entry#*:}"
    case "$scope" in
      main)
        impact_focus_main+=("$scenario")
        impact_focus_ordered+=("$scope:$scenario")
        ;;
      reference)
        impact_focus_reference+=("$scenario")
        impact_focus_ordered+=("$scope:$scenario")
        ;;
      regression)
        impact_focus_regression+=("$scenario")
        impact_focus_ordered+=("$scope:$scenario")
        ;;
    esac
  done < <(python3 scripts/eval_impact.py \
    --repo-root "$repo_root" \
    --base-ref "$base_ref" \
    --skill-dir "$skill_dir" \
    --limit "$impact_limit")
}

collect_risk_probes() {
  local entry scope scenario
  local count=0

  if [[ "$changed_runtime" != true || "$use_risk_probes" != true || "$risk_limit" -le 0 ]]; then
    return
  fi
  if [[ ! -f "$risk_probe_file" ]]; then
    return
  fi

  while IFS= read -r entry; do
    entry="${entry%%#*}"
    entry="$(echo "$entry" | xargs)"
    [[ -z "$entry" ]] && continue

    scope="${entry%%:*}"
    scenario="${entry#*:}"
    [[ -z "$scope" || -z "$scenario" || "$scope" == "$entry" ]] && continue

    case "$scope" in
      main)
        risk_focus_main+=("$scenario")
        risk_focus_ordered+=("$scope:$scenario")
        ;;
      reference)
        risk_focus_reference+=("$scenario")
        risk_focus_ordered+=("$scope:$scenario")
        ;;
      regression)
        risk_focus_regression+=("$scenario")
        risk_focus_ordered+=("$scope:$scenario")
        ;;
      *)
        continue
        ;;
    esac

    count=$((count + 1))
    if [[ "$count" -ge "$risk_limit" ]]; then
      break
    fi
  done < "$risk_probe_file"
}

run_command() {
  local label="$1"
  shift
  echo
  echo ">>> $label"
  if [[ "$plan_only" == true ]]; then
    echo "PLAN ONLY: $*"
    return 0
  fi
  "$@"
}

extract_eval_run_id() {
  local run_log="$1"

  python3 - "$run_log" <<'PY'
import json
import sys

raw = open(sys.argv[1], encoding="utf-8").read()
decoder = json.JSONDecoder()
payload = None
for index, char in enumerate(raw):
    if char not in "[{":
        continue
    try:
        payload, _ = decoder.raw_decode(raw[index:])
    except json.JSONDecodeError:
        continue
    break

if isinstance(payload, list):
    for item in payload:
        if isinstance(item, dict) and item.get("evalRunId"):
            print(item["evalRunId"])
            raise SystemExit(0)
elif isinstance(payload, dict):
    data = payload.get("data")
    if isinstance(data, dict) and data.get("id"):
        print(data["id"])
        raise SystemExit(0)
PY
}

eval_view_state() {
  local view_log="$1"

  python3 - "$view_log" <<'PY'
import json
import sys

raw = open(sys.argv[1], encoding="utf-8").read()
decoder = json.JSONDecoder()
payload = None
for index, char in enumerate(raw):
    if char != "{":
        continue
    try:
        payload, _ = decoder.raw_decode(raw[index:])
    except json.JSONDecodeError:
        continue
    break

if not isinstance(payload, dict):
    print("pending")
    raise SystemExit(0)

attrs = payload.get("data", {}).get("attributes", {})
status = attrs.get("status")
progress = attrs.get("progress", {})
summary = progress.get("summary", {}) if isinstance(progress, dict) else {}
if status in {"failed", "error", "cancelled", "canceled"} or int(summary.get("failed") or 0) > 0:
    print("failed")
    raise SystemExit(0)
if status != "completed":
    print("pending")
    raise SystemExit(0)

scenarios = attrs.get("scenarios")
if not isinstance(scenarios, list) or not scenarios:
    print("pending")
    raise SystemExit(0)

def scored(solution: dict) -> bool:
    if any(key in solution for key in ("score", "max_score", "maxScore")):
        return True
    return isinstance(solution.get("assessmentResults"), list)

for scenario in scenarios:
    if not isinstance(scenario, dict):
        print("pending")
        raise SystemExit(0)
    solutions = scenario.get("solutions")
    if not isinstance(solutions, list):
        print("pending")
        raise SystemExit(0)
    by_variant = {solution.get("variant"): solution for solution in solutions if isinstance(solution, dict)}
    solution = by_variant.get("usage-spec") or by_variant.get("with-context")
    if not solution or not scored(solution):
        print("pending")
        raise SystemExit(0)

print("ready")
PY
}

wait_for_eval_view() {
  local eval_run_id="$1"
  local view_log="$2"
  local attempt
  local state

  for attempt in $(seq 1 180); do
    if ! tessl eval view "$eval_run_id" --json > "$view_log"; then
      return 1
    fi

    state="$(eval_view_state "$view_log")"
    case "$state" in
      ready)
        return 0
        ;;
      failed)
        cat "$view_log"
        return 1
        ;;
    esac

    echo "Waiting for eval run $eval_run_id to finish scoring (attempt $attempt/180)..."
    sleep 20
  done

  echo "Timed out waiting for eval run $eval_run_id to finish scoring." >&2
  return 1
}

run_suite_checked() {
  local suite="$1"
  shift
  local scenarios=("$@")
  local -a run_cmd
  local eval_run_id
  local run_log
  local scored_log
  local label
  local scenario
  local validated_scenarios=()

  if [[ "${#scenarios[@]}" -eq 0 ]]; then
    label="scripts/run_eval_suite.sh $suite"
    run_cmd=(scripts/run_eval_suite.sh "$suite" -- --json)
    mapfile -t validated_scenarios < <(suite_scenarios "$suite")
  else
    label="scripts/run_eval_suite.sh $suite ${scenarios[*]}"
    run_cmd=(scripts/run_eval_suite.sh "$suite")
    for scenario in "${scenarios[@]}"; do
      run_cmd+=("$scenario")
      validated_scenarios+=("$scenario")
    done
    run_cmd+=(-- --json)
  fi

  if [[ "$plan_only" == true ]]; then
    echo
    echo ">>> $label"
    echo "PLAN ONLY: ${run_cmd[*]}"
    mark_scenarios_planned "$suite" "${validated_scenarios[@]}"
    return 0
  fi

  echo
  echo ">>> $label"
  run_log="$(mktemp)"
  if ! ("${run_cmd[@]}" > "$run_log"); then
    rm -f "$run_log"
    return 1
  fi

  cat "$run_log"
  scored_log="$run_log"
  eval_run_id="$(extract_eval_run_id "$run_log" || true)"
  if [[ -n "$eval_run_id" ]]; then
    scored_log="$(mktemp)"
    if ! wait_for_eval_view "$eval_run_id" "$scored_log"; then
      rm -f "$run_log" "$scored_log"
      return 1
    fi
    cat "$scored_log"
  fi

  if python3 scripts/assert_eval_with_context.py "$scored_log" --suite "$suite"; then
    mark_run_passing_scenarios "$suite" "$scored_log"
    rm -f "$run_log"
    if [[ "$scored_log" != "$run_log" ]]; then
      rm -f "$scored_log"
    fi
    return 0
  else
    local status=$?
    mark_run_passing_scenarios "$suite" "$scored_log"
    rm -f "$run_log"
    if [[ "$scored_log" != "$run_log" ]]; then
      rm -f "$scored_log"
    fi
    return $status
  fi
}

confirm_checkpoint() {
  local stage="$1"
  if [[ "$need_confirmation" == false || "$plan_only" == true ]]; then
    return
  fi
  echo
  read -r -p "Confirm ${stage} with-context is 100% before continuing [y/N]: " ok
  if [[ "$ok" != "y" && "$ok" != "Y" && "$ok" != "yes" && "$ok" != "YES" ]]; then
    echo "Stopping. Document blocked run and rerun this stage before broadening."
    exit 0
  fi
}

run_suite() {
  local suite="$1"
  shift
  local scenarios=("$@")

  run_suite_checked "$suite" "${scenarios[@]}"
  if [[ "${#scenarios[@]}" -eq 0 ]]; then
    confirm_checkpoint "$suite broad run"
  else
    confirm_checkpoint "$suite targeted run (${#scenarios[@]} scenario(s))"
  fi
}

run_if_nonempty() {
  local suite="$1"
  shift
  local scenarios=("$@")

  if [[ "${#scenarios[@]}" -eq 0 ]]; then
    return 0
  fi

  run_suite "$suite" "${scenarios[@]}"
}

array_contains() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

is_missing_target() {
  local suite="$1"
  local scenario="$2"

  case "$suite" in
    main)
      array_contains "$scenario" "${combined_main[@]}"
      ;;
    reference)
      array_contains "$scenario" "${combined_reference[@]}"
      ;;
    regression)
      array_contains "$scenario" "${combined_regression[@]}"
      ;;
    *)
      return 1
      ;;
  esac
}

append_target_queue() {
  local suite="$1"
  local scenario="$2"
  local key="$suite:$scenario"

  [[ -z "$suite" || -z "$scenario" ]] && return
  if [[ -n "${target_queue_seen[$key]:-}" ]]; then
    return
  fi
  if ! is_missing_target "$suite" "$scenario"; then
    return
  fi

  target_queue_seen["$key"]=1
  target_queue_suites+=("$suite")
  target_queue_scenarios+=("$scenario")
}

append_target_entry() {
  local entry="$1"
  local suite scenario

  suite="${entry%%:*}"
  scenario="${entry#*:}"
  [[ -z "$suite" || -z "$scenario" || "$suite" == "$entry" ]] && return
  append_target_queue "$suite" "$scenario"
}

build_target_queue() {
  local scenario entry
  declare -gA target_queue_seen=()
  target_queue_suites=()
  target_queue_scenarios=()

  for entry in "${explicit_focus_ordered[@]}"; do
    append_target_entry "$entry"
  done
  for entry in "${risk_focus_ordered[@]}"; do
    append_target_entry "$entry"
  done
  for entry in "${impact_focus_ordered[@]}"; do
    append_target_entry "$entry"
  done

  for scenario in "${changed_main[@]}"; do
    append_target_queue main "$scenario"
  done
  for scenario in "${changed_reference[@]}"; do
    append_target_queue reference "$scenario"
  done
  for scenario in "${changed_regression[@]}"; do
    append_target_queue regression "$scenario"
  done

  # Safety net for any targets not represented in the ordered source lists.
  for scenario in "${combined_main[@]}"; do
    append_target_queue main "$scenario"
  done
  for scenario in "${combined_reference[@]}"; do
    append_target_queue reference "$scenario"
  done
  for scenario in "${combined_regression[@]}"; do
    append_target_queue regression "$scenario"
  done
}

run_targeted_suites() {
  local index=0
  local count="${#target_queue_suites[@]}"
  local suite scenario
  local batch=()

  if [[ "$count" -eq 0 ]]; then
    return 0
  fi

  echo
  echo "Targeted probe order:"
  while [[ "$index" -lt "$count" ]]; do
    echo "  ${target_queue_suites[$index]}:${target_queue_scenarios[$index]}"
    index=$((index + 1))
  done

  index=0
  while [[ "$index" -lt "$count" ]]; do
    suite="${target_queue_suites[$index]}"
    batch=()

    while [[ "$index" -lt "$count" && "${target_queue_suites[$index]}" == "$suite" && "${#batch[@]}" -lt "$target_batch_size" ]]; do
      scenario="${target_queue_scenarios[$index]}"
      batch+=("$scenario")
      index=$((index + 1))
    done

    run_if_nonempty "$suite" "${batch[@]}"
  done
}

run_remaining_suite() {
  local suite="$1"
  local scenarios=()
  local index=0
  local count
  local batch_size=1
  local take remaining
  local batch=()
  local balanced_batch_size=6

  mapfile -t scenarios < <(remaining_scenarios "$suite")
  count="${#scenarios[@]}"
  if [[ "$count" -eq 0 ]]; then
    echo
    echo "Skipping $suite broad stage: all scenarios already have 100% with-context evidence for this skill fingerprint."
    return 0
  fi

  if [[ "$broad_batch_mode" == "suite" || "$count" -eq 1 ]]; then
    run_suite "$suite" "${scenarios[@]}"
    return
  fi

  if [[ "$broad_batch_mode" == "balanced" ]]; then
    while [[ "$index" -lt "$count" ]]; do
      remaining=$((count - index))
      take="$remaining"
      if [[ "$take" -gt "$balanced_batch_size" ]]; then
        take="$balanced_batch_size"
      fi

      batch=("${scenarios[@]:index:take}")
      run_suite "$suite" "${batch[@]}"
      index=$((index + take))
    done
    return
  fi

  while [[ "$index" -lt "$count" ]]; do
    remaining=$((count - index))
    take="$batch_size"
    if [[ "$remaining" -le $((batch_size * 2)) ]]; then
      take="$remaining"
    elif [[ "$take" -gt "$remaining" ]]; then
      take="$remaining"
    fi

    batch=("${scenarios[@]:index:take}")
    run_suite "$suite" "${batch[@]}"
    index=$((index + take))
    batch_size=$((batch_size * 2))
  done
}

append_unique_suite() {
  local suite="$1"
  local existing

  for existing in "${broad_order[@]}"; do
    if [[ "$existing" == "$suite" ]]; then
      return
    fi
  done
  broad_order+=("$suite")
}

resolve_broad_order() {
  local -n out="$1"
  local raw suite
  local normalized=()
  out=()

  if [[ "$broad_order_arg" != "auto" ]]; then
    IFS=',' read -r -a out <<< "$broad_order_arg"
    if [[ "${#out[@]}" -ne 3 ]]; then
      echo "--broad-order must contain main,reference,regression exactly once." >&2
      exit 2
    fi
  else
    broad_order=()
    # The observed history for this skill is dominated by main/reference misses. Keep the broad
    # order aligned with the history-derived expected-cost sweep unless explicitly overridden.
    append_unique_suite main
    append_unique_suite reference
    append_unique_suite regression
    out=("${broad_order[@]}")
  fi

  local -A seen=()
  for raw in "${out[@]}"; do
    suite="$(echo "$raw" | xargs)"
    case "$suite" in
      main|reference|regression)
        if [[ -n "${seen[$suite]:-}" ]]; then
          echo "--broad-order contains duplicate suite '$suite'." >&2
          exit 2
        fi
        seen["$suite"]=1
        normalized+=("$suite")
        ;;
      *)
        echo "--broad-order contains unknown suite '$suite'." >&2
        exit 2
        ;;
    esac
  done
  for suite in main reference regression; do
    if [[ -z "${seen[$suite]:-}" ]]; then
      echo "--broad-order must include $suite." >&2
      exit 2
    fi
  done
  out=("${normalized[@]}")
}

changed_runtime=false
changed_runtime_paths="$(
  git diff --name-only "$base_ref"...HEAD -- "$skill_dir" 2>/dev/null || true
  git diff --name-only -- "$skill_dir" 2>/dev/null || true
  git diff --cached --name-only -- "$skill_dir" 2>/dev/null || true
  git ls-files -o --exclude-standard -- "$skill_dir" 2>/dev/null || true
)"
if [[ -n "$changed_runtime_paths" ]]; then
  changed_runtime=true
fi

collect_changed
collect_focus
collect_impact_focus
collect_risk_probes

mapfile -t changed_main < <(normalize_targets "${changed_main[@]}")
mapfile -t changed_reference < <(normalize_targets "${changed_reference[@]}")
mapfile -t changed_regression < <(normalize_targets "${changed_regression[@]}")
mapfile -t explicit_focus_main < <(normalize_targets "${explicit_focus_main[@]}")
mapfile -t explicit_focus_reference < <(normalize_targets "${explicit_focus_reference[@]}")
mapfile -t explicit_focus_regression < <(normalize_targets "${explicit_focus_regression[@]}")
mapfile -t impact_focus_main < <(normalize_targets "${impact_focus_main[@]}")
mapfile -t impact_focus_reference < <(normalize_targets "${impact_focus_reference[@]}")
mapfile -t impact_focus_regression < <(normalize_targets "${impact_focus_regression[@]}")
mapfile -t risk_focus_main < <(normalize_targets "${risk_focus_main[@]}")
mapfile -t risk_focus_reference < <(normalize_targets "${risk_focus_reference[@]}")
mapfile -t risk_focus_regression < <(normalize_targets "${risk_focus_regression[@]}")

if [[ "$changed_runtime" == false && "${#changed_main[@]}" -eq 0 && "${#changed_reference[@]}" -eq 0 && "${#changed_regression[@]}" -eq 0 && "${#explicit_focus_main[@]}" -eq 0 && "${#explicit_focus_reference[@]}" -eq 0 && "${#explicit_focus_regression[@]}" -eq 0 && "$run_broad" == false ]]; then
  echo
  echo "No changed files detected in skill/eval scope."
  echo "No targeted eval scope detected for the current diff."
  if [[ "$changed_runtime" == true ]]; then
    echo "If this was a runtime change, run a scoped smoke first, then rerun this command:"
    echo "  scripts/pre_submit_gate.sh --focus <scope>:<scenario>"
  else
    echo "Use --focus <scope>:<scenario> or --run-broad if this change still requires hosted validation."
  fi
  echo
  echo "If this is ready for a final hosted sweep, add --run-broad."
  exit 0
fi

if [[ "$changed_runtime" == true && "$targeted_only" == false ]]; then
  run_broad=true
fi

runtime_fingerprint="$(python3 scripts/eval_evidence.py fingerprint --skill-dir "$skill_dir")"
if [[ "$reset_evidence" == true ]]; then
  rm -f "$evidence_file"
fi

echo "Running quality gate first (required by process)."
quality_display="tessl review run"
if [[ -n "$review_workspace" ]]; then
  quality_display+=" --workspace $review_workspace"
fi
quality_display+=" --threshold 100 $skill_dir/SKILL.md"
run_command "$quality_display" \
  run_quality_review "$skill_dir/SKILL.md" 100

combined_main=("${changed_main[@]}" "${explicit_focus_main[@]}" "${impact_focus_main[@]}" "${risk_focus_main[@]}")
combined_reference=("${changed_reference[@]}" "${explicit_focus_reference[@]}" "${impact_focus_reference[@]}" "${risk_focus_reference[@]}")
combined_regression=("${changed_regression[@]}" "${explicit_focus_regression[@]}" "${impact_focus_regression[@]}" "${risk_focus_regression[@]}")
mapfile -t combined_main < <(normalize_targets "${combined_main[@]}")
mapfile -t combined_reference < <(normalize_targets "${combined_reference[@]}")
mapfile -t combined_regression < <(normalize_targets "${combined_regression[@]}")

echo
echo "Detected targeted eval scope:"
echo "  main: ${combined_main[*]:-<none>}"
echo "  reference: ${combined_reference[*]:-<none>}"
echo "  regression: ${combined_regression[*]:-<none>}"
echo "  impact: main=${impact_focus_main[*]:-<none>} reference=${impact_focus_reference[*]:-<none>} regression=${impact_focus_regression[*]:-<none>}"
echo "  risk: main=${risk_focus_main[*]:-<none>} reference=${risk_focus_reference[*]:-<none>} regression=${risk_focus_regression[*]:-<none>}"

if [[ "$use_evidence" == true ]]; then
  echo
  echo "Using scenario evidence cache: $evidence_file"
  echo "Skill bundle fingerprint: $runtime_fingerprint"
fi

_cleaned=()
for item in "${combined_main[@]}"; do
  [[ -n "$item" ]] && _cleaned+=("$item")
done
combined_main=("${_cleaned[@]}")

_cleaned=()
for item in "${combined_reference[@]}"; do
  [[ -n "$item" ]] && _cleaned+=("$item")
done
combined_reference=("${_cleaned[@]}")

_cleaned=()
for item in "${combined_regression[@]}"; do
  [[ -n "$item" ]] && _cleaned+=("$item")
done
combined_regression=("${_cleaned[@]}")
unset _cleaned

missing_main=()
missing_reference=()
missing_regression=()
mapfile -t missing_main < <(remaining_targeted_scenarios main "${combined_main[@]}")
mapfile -t missing_reference < <(remaining_targeted_scenarios reference "${combined_reference[@]}")
mapfile -t missing_regression < <(remaining_targeted_scenarios regression "${combined_regression[@]}")

# Scenario evidence includes both the skill bundle fingerprint and the scenario file fingerprint.
# Changed eval definitions are rerun only when they lack current scenario-fingerprint evidence.
combined_main=("${missing_main[@]}")
combined_reference=("${missing_reference[@]}")
combined_regression=("${missing_regression[@]}")
mapfile -t combined_main < <(normalize_targets "${combined_main[@]}")
mapfile -t combined_reference < <(normalize_targets "${combined_reference[@]}")
mapfile -t combined_regression < <(normalize_targets "${combined_regression[@]}")

echo
echo "Targeted eval scope still missing evidence:"
echo "  main: ${combined_main[*]:-<none>}"
echo "  reference: ${combined_reference[*]:-<none>}"
echo "  regression: ${combined_regression[*]:-<none>}"

build_target_queue

if [[ "${#combined_main[@]}" -eq 0 && "${#combined_reference[@]}" -eq 0 && "${#combined_regression[@]}" -eq 0 && "$run_broad" == false ]]; then
  echo
  echo "No targeted eval scope detected for the current diff."
  if [[ "$changed_runtime" == true ]]; then
    echo "This is a runtime/reference change and therefore requires full suite evidence before final PR"
    echo "submission. Add --auto-continue for automated progression."
  else
    echo "If this was a runtime change, run a scoped smoke first, then rerun this command:"
    echo "  scripts/pre_submit_gate.sh --focus <scope>:<scenario>"
    echo
    echo "If this is ready for a final hosted sweep, add --run-broad."
  fi
  exit 0
fi

run_targeted_suites

if [[ "$run_broad" == false ]]; then
  echo
  echo "Plan complete for targeted-only mode. Add --run-broad for final full-suite readiness."
  exit 0
fi

broad_order=()
resolve_broad_order broad_order

echo
echo "Broad stage order: ${broad_order[*]}"

for suite in "${broad_order[@]}"; do
  run_remaining_suite "$suite"
done

echo
echo "All planned hosted checks completed."
