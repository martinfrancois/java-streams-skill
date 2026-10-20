#!/usr/bin/env python3
"""Grade one local_screen.sh run against the scenario's criteria.json.

Writes assessment.json next to solver.json, shaped like one Tessl solution, and
prints the score with every item that lost points. Used by scripts/local_screen.sh;
can be rerun on its own to re-grade a run with another judge model:

    local_screen_judge.py <scenario-dir> <run-dir> [judge-model] [variant-label]

local_screen.sh passes all four; standalone runs default to haiku and "local".

The DeepSeek key named by DEEPSEEK_API_KEY_FILE (default ~/deepseek-api-key) is
replaced with [redacted] in everything sent to the judge.
"""
import json
import os
import subprocess
import sys
from pathlib import Path

scenario_dir = Path(sys.argv[1]).resolve()
run_dir = Path(sys.argv[2]).resolve()
judge_model = sys.argv[3] if len(sys.argv) > 3 else "haiku"
variant = sys.argv[4] if len(sys.argv) > 4 else "local"
criteria = json.loads((scenario_dir / "criteria.json").read_text())
task = (scenario_dir / "task.md").read_text()
solver = json.loads((run_dir / "solver.json").read_text())
work = run_dir / "work"
key_file = Path(os.environ.get("DEEPSEEK_API_KEY_FILE", Path.home() / "deepseek-api-key"))
secret = key_file.read_text().strip() if key_file.is_file() else ""
files = []
for path in sorted(work.rglob("*")):
    if not path.is_file() or path.suffix == ".class" or ".claude" in path.parts:
        continue
    if path.stat().st_size > 60000:
        continue
    text = path.read_text(errors="replace").replace("\x00", "")
    if secret:
        text = text.replace(secret, "[redacted]")
    files.append(f"### {path.relative_to(work)}\n```\n{text}\n```")
artifacts = "\n\n".join(files) or "(no files written)"
final_message = str(solver.get("result", ""))
if secret:
    final_message = final_message.replace(secret, "[redacted]")
checklist = json.dumps(criteria["checklist"], indent=2)
prompt = f"""You are grading an AI coding agent's solution against a weighted checklist.
Score each checklist item from 0 to its max_score. Be strict: award full points only
when the description is clearly met by the artifacts. Partial credit is allowed.

## Task given to the agent
{task}

## Checklist
{checklist}

## Files the agent wrote
{artifacts}

## Agent's final message
{final_message}

Reply with only a JSON array, one object per checklist item in order:
[{{"name": "...", "score": <number>, "max_score": <number>, "reasoning": "<one sentence>"}}]
"""
out = subprocess.run(
    ["claude", "-p", "--model", judge_model, "--output-format", "json", prompt],
    capture_output=True, text=True, cwd=str(run_dir), check=False,
)
if out.returncode != 0:
    sys.exit(f"judge failed: {out.stderr[-500:]}")
text = json.loads(out.stdout)["result"].strip()
if text.startswith("```"):
    text = text.split("\n", 1)[1].rsplit("```", 1)[0]
results = json.loads(text)
assessment = {"variant": variant, "judge": judge_model, "assessmentResults": results}
(run_dir / "assessment.json").write_text(json.dumps(assessment, indent=2) + "\n")
earned = sum(item["score"] for item in results)
maximum = sum(item["max_score"] for item in results)
print(f"{scenario_dir.name} {run_dir.name}: {earned}/{maximum} ({100 * earned / maximum:.0f}%)")
for item in results:
    if item["score"] < item["max_score"]:
        print(f"  lost {item['name']}: {item['score']}/{item['max_score']} {item['reasoning']}")
