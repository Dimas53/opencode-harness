#!/bin/bash
# scripts/check-dod-sync.sh
# Verifies global/AGENTS.md ## Definition of Done and
# global/skills/dod/SKILL.md stay in sync with the canonical step list in
# global/rules/dod.yaml (T-F1, implementation-plan-2 Wave F). Kept as a
# thin wrapper around gen-rules.sh --check so existing callers (Makefile
# `check-docs-sync` target, .github/workflows/dod.yml) don't need to
# change. Was a direct cross-file (AGENTS.md vs SKILL.md) comparison
# before T-F1 — that let both files drift together against a step that
# was silently deleted/renamed in both; dod.yaml is now the actual
# canon both are checked against. Run via: make check-docs-sync
set -euo pipefail
exec bash "$(dirname "$0")/gen-rules.sh" --check
