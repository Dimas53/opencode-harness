#!/bin/bash
# tests/behavior/fixtures/session-end-with-failures/setup.sh
# Forces a real FAIL in session-end.sh (Step 3 — memory log, not Step 2 as
# the ticket originally assumed; verified against current code that missing
# PROGRESS.md is only ever a WARN there — see scenario notes) so we can
# check .session-ended is NOT written when the session genuinely has
# unresolved issues (regression check for T0.4).
# Prints ONLY the fixture directory path to stdout; everything else to stderr.
set -euo pipefail

TMP=$(mktemp -d)
git clone --quiet "$(git rev-parse --show-toplevel)" "$TMP" >&2
cd "$TMP"
rm -f "memory/$(date +%Y-%m-%d).md"
echo "<!-- forces session-end.sh Step 3 to see real session changes -->" >> README.md
echo "$TMP"
