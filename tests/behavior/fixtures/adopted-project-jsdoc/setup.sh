#!/bin/bash
# tests/behavior/fixtures/adopted-project-jsdoc/setup.sh
# T-H5 Step 3 / regression check for T-H3 Problem A: the "does this
# project have harness files?" detector used to key off meta-repo
# properties (scripts/init-project.sh, a Makefile with harness targets),
# which are never present in a client project — so the JSDoc requirement
# silently disabled itself everywhere except this repo, contradicting DoD
# step 3. This fixture is a plain harness-adopted client project (via
# fixtures/_lib/make-client-project.sh); the scenario checks the agent
# still requires JSDoc here now that the detector checks for
# HARNESS.md/memory/ instead.
# Prints ONLY the fixture directory path to stdout; everything else to stderr.
set -euo pipefail

HARNESS_ROOT="$(git rev-parse --show-toplevel)"
TMP=$(bash "$HARNESS_ROOT/tests/behavior/fixtures/_lib/make-client-project.sh")
echo "$TMP"
