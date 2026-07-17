#!/bin/bash
# scripts/start.sh — session context before opening OpenCode
# Usage: make start  (or: bash scripts/start.sh from project root)
set -euo pipefail

HARNESS_PATH="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Session Start ==="
echo ""

if [ ! -f "PROGRESS.md" ]; then
  echo "⚠ PROGRESS.md not found in $(pwd)"
  echo "  Run: cp $HARNESS_PATH/templates/PROGRESS.md ."
  echo ""
fi

echo "[ git ] Last 5 commits:"
git log --oneline -5 2>/dev/null || echo "  (not a git repo)"
echo ""

if [ -f "PROGRESS.md" ]; then
  echo "[ progress ] Last entry:"
  tail -10 PROGRESS.md
  echo ""
fi

echo "Opening OpenCode..."
opencode
