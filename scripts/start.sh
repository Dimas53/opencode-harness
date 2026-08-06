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
    echo "ℹ Previous session ($SAVED_DATE) wasn't closed with 'make session-end'."
    echo "  This is informational only — startup is not blocked. If you want a"
    echo "  full session-end summary for that session, run: make session-end"
    echo ""
  elif [ "$SAVED_DATE" != "$TODAY" ]; then
    echo "ℹ Previous session closed yesterday ($SAVED_DATE). Nothing required —"
    echo "  run 'make session-end' if you still want to review its warnings."
    echo ""
  fi
  rm -f "$SESSION_FILE"
else
  echo "ℹ No '.session-ended' marker found — the previous session may not have"
  echo "  run 'make session-end'. This is informational only, startup continues."
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
