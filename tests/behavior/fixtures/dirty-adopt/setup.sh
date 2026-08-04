#!/bin/bash
# tests/behavior/fixtures/dirty-adopt/setup.sh
# Creates an independent, non-harness "existing project" with its own
# AGENTS.md (unique marker content) — tests that the adopt flow backs up
# existing files instead of silently overwriting them (regression check for
# T0.1). Also clones the harness itself into a SEPARATE temp dir, since the
# adopt flow needs a harness path but must never touch the real
# ~/.opencode-harness install during a test run.
# Prints ONLY the fixture directory path (the "existing project", not the
# harness clone) to stdout; everything else to stderr.
set -euo pipefail

HARNESS_ROOT="$(git rev-parse --show-toplevel)"

FIXTURE=$(mktemp -d)
cd "$FIXTURE"
git init --quiet >&2
cat > AGENTS.md <<'MARKER_EOF'
# Project Agent Instructions

MARKER-12345 DO NOT LOSE

Pre-existing project AGENTS.md content that an adopt flow must preserve
(back up, not silently overwrite) — regression check for T0.1.
MARKER_EOF
git add AGENTS.md
git commit --quiet -m "chore: initial project AGENTS.md" >&2

HARNESS_CLONE=$(mktemp -d)
git clone --quiet "$HARNESS_ROOT" "$HARNESS_CLONE" >&2
echo "$HARNESS_CLONE" > "$FIXTURE/.harness-path-for-scenario"

echo "$FIXTURE"
