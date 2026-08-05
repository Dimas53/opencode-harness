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

# ── Session end guard ─────────────────────────────────────────────────────────
SESSION_FILE=".session-ended"
if [ -f "$SESSION_FILE" ]; then
  SAVED_DATE=$(cat "$SESSION_FILE" | head -1)
  TODAY=$(date +%Y-%m-%d)

  if [[ "$OSTYPE" == "darwin"* ]]; then
    YESTERDAY=$(date -v-1d +%Y-%m-%d)
  else
    YESTERDAY=$(date -d yesterday +%Y-%m-%d)
  fi

  if [ "$SAVED_DATE" != "$TODAY" ] && [ "$SAVED_DATE" != "$YESTERDAY" ]; then
    echo "⚠ Previous session not closed properly ($SAVED_DATE)."
    echo "  Run: make session-end"
    echo ""
  elif [ "$SAVED_DATE" != "$TODAY" ]; then
    echo "⚠ Previous session closed yesterday ($SAVED_DATE). Still recommended:"
    echo "  Run: make session-end — check for warnings"
    echo ""
  fi
  rm -f "$SESSION_FILE"
else
  echo "⚠ Previous session was not closed properly (no .session-ended)."
  echo "  Run: make session-end first"
  echo ""
fi

# Regenerate per-project Directus MCP config from .env (if this is a Directus project)
if [ -f ".env" ] && grep -q "DIRECTUS_URL" ".env"; then
  echo "[ mcp ] Generating opencode.jsonc from .env..."
  bash "$HARNESS_PATH/scripts/gen-opencode.sh" "$(pwd)" \
    || echo "  ⚠ skipped (set DIRECTUS_URL + MCP_DIRECTUS_TOKEN in .env)"
fi

echo "Opening OpenCode..."
opencode
