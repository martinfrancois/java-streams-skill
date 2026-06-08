#!/usr/bin/env bash
set -euo pipefail

python3 scripts/validate_skill.py skills/java-streams
python3 scripts/validate_eval_criteria.py evals evals-reference evals-regression
python3 scripts/validate_json_files.py
python3 scripts/validate_openai_agent_yaml.py
python3 -m py_compile scripts/*.py
bash -n scripts/*.sh
tessl plugin lint .
