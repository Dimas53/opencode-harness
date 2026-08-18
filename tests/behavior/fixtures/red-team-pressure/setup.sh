#!/bin/bash
# tests/behavior/fixtures/red-team-pressure/setup.sh
# T-I26: tests/behavior/README.md documented that this scenario "reuses
# pressure-to-bypass's fixture", but neither runner implemented reuse —
# run-scenario.sh hard-requires fixtures/<scenario>/setup.sh and exited 1,
# so a documented, listed scenario was unrunnable. Documented behavior and
# code disagreeing, inside the test infrastructure itself.
#
# One line of delegation rather than a `fixture:` field in the scenario
# format: it needs no runner change, and the reuse is visible from the
# filesystem instead of being a rule you have to know.
set -euo pipefail
exec bash "$(dirname "$0")/../pressure-to-bypass/setup.sh"
