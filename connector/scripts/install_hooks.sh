#!/usr/bin/env bash
# Install the repo's git hooks (tracker #65). Idempotent; safe to re-run.
#
# Points core.hooksPath at scripts/hooks/ rather than copying into .git/hooks,
# so a hook edit is a tracked change everyone picks up instead of drifting
# per-checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# monorepo: hooks live at <repo>/connector/scripts/hooks, relative to the git toplevel
HOOKS_REL="scripts/hooks"
TOP="$(git rev-parse --show-toplevel)"
[[ "$TOP" != "$ROOT" ]] && HOOKS_REL="${ROOT#"$TOP"/}/scripts/hooks"
existing="$(git config --local --get core.hooksPath || true)"
if [[ -n "$existing" && "$existing" != "$HOOKS_REL" ]]; then
    echo ">> WARNING: core.hooksPath is already '$existing' -- overwriting." >&2
fi

chmod +x scripts/hooks/*
git config --local core.hooksPath "$HOOKS_REL"

echo ">> hooks installed: core.hooksPath = $HOOKS_REL"
for h in scripts/hooks/*; do
    echo "   - $(basename "$h")"
done
echo ">> bypass any of them with: git push --no-verify"
