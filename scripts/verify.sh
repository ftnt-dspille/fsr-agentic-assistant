#!/usr/bin/env bash
# `make verify` for the monorepo: framework gates, then the connector suite, both on
# the connector's dev env (scripts/dev_env.sh; framework editable from ./framework),
# so the connector is tested against the framework in THIS commit.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_PY="$(bash "$ROOT/connector/scripts/dev_env.sh" python)"
export FSRPB_DEV=1 PYTHONPATH="$ROOT/framework/tooling"
cd "$ROOT/framework"
echo "-> [1/4] ruff (framework)";        RUFF="${RUFF:-$(command -v ruff || echo "uvx ruff@0.15.20")}" bash scripts/ci_suite.sh lint
echo "-> [2/4] fsr_playbooks tests";     "$VENV_PY" -m pytest fsr_playbooks/tests -q -m "not live and not slow" -p no:randomly
echo "-> [3/4] tooling tests (own process)"; "$VENV_PY" -m pytest tooling/tests -q -m "not live and not slow" -p no:randomly
echo "-> [4/4] connector suite";         make --no-print-directory -C "$ROOT/connector" test
echo "verify passed"
