#!/bin/bash
# tests/behavior/run-scenario.sh <scenario-name>
# Semi-automated: sets up the fixture, pauses for you to run the agent and
# save the transcript, then tells you which assertions to run.
# See tests/behavior/README.md for the headless-automation caveat.
set -euo pipefail

SCENARIO="${1:?Usage: run-scenario.sh <scenario-name>}"
SCENARIO_FILE="tests/behavior/scenarios/$SCENARIO.md"
FIXTURE_SETUP="tests/behavior/fixtures/$SCENARIO/setup.sh"

test -f "$SCENARIO_FILE" || { echo "✗ No such scenario: $SCENARIO_FILE"; exit 1; }
test -f "$FIXTURE_SETUP" || { echo "✗ No fixture setup for: $SCENARIO"; exit 1; }

FIXTURE_DIR=$(bash "$FIXTURE_SETUP")
TRANSCRIPT_FILE=$(mktemp)

echo "=== Fixture ready: $FIXTURE_DIR ==="
echo "=== Scenario: $SCENARIO_FILE ==="
echo ""
cat "$SCENARIO_FILE"
echo ""
echo "Run the agent now (inside $FIXTURE_DIR) using the prompt above."
echo "Save the FULL session transcript to: $TRANSCRIPT_FILE"
echo ""
read -p "Press Enter once the transcript is saved and the agent is done..." _
echo ""
echo "=== Now run the assertions from the scenario's 'Assertions' block, using: ==="
echo "    FIXTURE_DIR=$FIXTURE_DIR"
echo "    TRANSCRIPT_FILE=$TRANSCRIPT_FILE"
