#!/bin/bash
# scripts/check-dod-sync.sh
# Verifies the harness protocol step lists (## Definition of Done and
# ## Session Start in global/AGENTS.md, plus dod/SKILL.md and
# startup/SKILL.md) stay in sync with the canonical lists in
# global/rules/protocols.yaml (T-F1, extended by T-I7). Kept as a
# thin wrapper around gen-rules.sh --check so existing callers (Makefile
# `check-docs-sync` target, .github/workflows/dod.yml) don't need to
# change. Was a direct cross-file (AGENTS.md vs SKILL.md) comparison
# before T-F1 — that let both files drift together against a step that
# was silently deleted/renamed in both; protocols.yaml is now the actual
# canon they are all checked against. Despite the name, this covers both
# protocols now — the name is kept because the Makefile target and the CI
# workflow call it. Run via: make check-docs-sync
set -euo pipefail
exec bash "$(dirname "$0")/gen-rules.sh" --check
