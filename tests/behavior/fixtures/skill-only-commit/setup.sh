#!/bin/bash
# tests/behavior/fixtures/skill-only-commit/setup.sh
# Reproduces the exact starting state that used to trigger the docs-matrix
# false positive (fixed in T0.3) — a skill-only staged change.
# Prints ONLY the fixture directory path to stdout; everything else to stderr.
set -euo pipefail

TMP=$(mktemp -d)
git clone --quiet "$(git rev-parse --show-toplevel)" "$TMP" >&2
cd "$TMP"
echo "<!-- golden-transcript fixture marker -->" >> global/skills/dod/SKILL.md
git add global/skills/dod/SKILL.md
echo "$TMP"
