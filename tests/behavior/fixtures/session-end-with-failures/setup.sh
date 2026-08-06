#!/bin/bash
# tests/behavior/fixtures/session-end-with-failures/setup.sh
# T-H5: rewritten to use a client project (make-client-project.sh) instead
# of cloning the harness itself — session-end.sh's logic is not gated by
# IS_HARNESS_REPO at all, so a client project reproduces the exact same
# real FAIL condition while testing the environment the agent actually
# works in.
# Forces a real FAIL in session-end.sh (Step 3 — memory log, not Step 2 as
# the ticket originally assumed; verified against current code that missing
# PROGRESS.md is only ever a WARN there — see scenario notes): the adopted
# files are committed as a second commit (so `git diff HEAD~1` sees real
# session changes) and no memory/YYYY-MM-DD.md exists for today.
# Prints ONLY the fixture directory path to stdout; everything else to stderr.
set -euo pipefail

HARNESS_ROOT="$(git rev-parse --show-toplevel)"
TMP=$(bash "$HARNESS_ROOT/tests/behavior/fixtures/_lib/make-client-project.sh")
cd "$TMP"
git add -A >&2
git commit --quiet -m "chore: adopt harness" >&2
echo "$TMP"
