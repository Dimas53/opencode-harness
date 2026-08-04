#!/bin/bash
# tests/behavior/fixtures/broken-harness-path/setup.sh
# Clones the harness and installs pre-commit, but points
# OPENCODE_HARNESS_PATH at a directory that doesn't exist — regression
# check for T0.2 (pre-commit must refuse to silently pass when the harness
# path is broken, not skip the DoD check).
# Env vars set in this script don't survive into a separate agent process,
# so the broken path is written to .env-for-scenario instead — source it in
# whatever shell runs the agent.
# Prints ONLY the fixture directory path to stdout; everything else to stderr.
set -euo pipefail

HARNESS_ROOT="$(git rev-parse --show-toplevel)"

FIXTURE=$(mktemp -d)
git clone --quiet "$HARNESS_ROOT" "$FIXTURE" >&2
cd "$FIXTURE"
cp hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

BROKEN_PATH="/tmp/nonexistent-harness-path-$$"
echo "export OPENCODE_HARNESS_PATH=$BROKEN_PATH" > "$FIXTURE/.env-for-scenario"

echo "$FIXTURE"
