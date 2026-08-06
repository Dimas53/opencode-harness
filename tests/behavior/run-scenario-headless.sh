#!/bin/bash
# tests/behavior/run-scenario-headless.sh <scenario-name>
# Fully automated variant of run-scenario.sh — runs the agent headlessly
# instead of pausing for a human to drive it interactively.
#
# T-F3/A2 (implementation-plan-2 Wave F, 2026-08-06): confirmed
# `opencode run --auto --format json "<prompt>"` genuinely executes
# multi-step tasks (file writes, shell commands) and returns a
# structured JSON event stream, not just an `echo ok` smoke test — the
# limitation documented in README.md's "Current limitation" section
# (and in run-scenario.sh's header) no longer applies. This script is
# the first consumer; run-scenario.sh's human-pause path is left as-is
# for scenarios nobody has ported yet, and as a fallback for tasks where
# --auto's permission auto-approval is undesirable.
#
# --auto auto-approves permissions not explicitly denied — same caution
# as everywhere else in this repo that mentions it: fine for a disposable
# scratch fixture, never point this at a real project.
set -euo pipefail

SCENARIO="${1:?Usage: run-scenario-headless.sh <scenario-name>}"
SCENARIO_FILE="tests/behavior/scenarios/$SCENARIO.md"
FIXTURE_SETUP="tests/behavior/fixtures/$SCENARIO/setup.sh"

test -f "$SCENARIO_FILE" || { echo "✗ No such scenario: $SCENARIO_FILE"; exit 1; }
test -f "$FIXTURE_SETUP" || { echo "✗ No fixture setup for: $SCENARIO"; exit 1; }

# Extract the blockquoted prompt (lines starting with "> ") between
# "**Prompt to send the agent**" and the next "**" heading.
PROMPT=$(awk '
  /^\*\*Prompt to send the agent\*\*/ { grab=1; next }
  grab && /^\*\*/ { exit }
  grab && /^> / { sub(/^> /, ""); print }
' "$SCENARIO_FILE")

[ -n "$PROMPT" ] || { echo "✗ Could not extract a prompt from $SCENARIO_FILE"; exit 1; }

FIXTURE_DIR=$(bash "$FIXTURE_SETUP")
TRANSCRIPT_FILE=$(mktemp)

echo "=== Fixture ready: $FIXTURE_DIR ==="
echo "=== Scenario: $SCENARIO_FILE ==="
echo "=== Prompt: $PROMPT ==="
echo ""
echo "Running headlessly (opencode run --auto --format json)..."

STATUS=0
( cd "$FIXTURE_DIR" && opencode run --auto --format json "$PROMPT" ) > "$TRANSCRIPT_FILE" 2>&1 || STATUS=$?

echo ""
echo "=== Agent run exit code: $STATUS ==="
echo "=== Now run the assertions from the scenario's 'Assertions' block, using: ==="
echo "    FIXTURE_DIR=$FIXTURE_DIR"
echo "    TRANSCRIPT_FILE=$TRANSCRIPT_FILE"
