#!/bin/bash
# scripts/session-end.sh — Session End checks
# Called by: make session-end, or agent on "done / end / konets / poka"
# Returns: 0 always (warnings only, does not block)
set -euo pipefail

PASS=0
FAIL=0
WARN=0

check_pass() { echo "✓ $1"; PASS=$((PASS + 1)); }
check_fail() { echo "✗ $1"; FAIL=$((FAIL + 1)); }
check_warn() { echo "⚠ $1"; WARN=$((WARN + 1)); }

TODAY=$(date +%Y-%m-%d)

echo "=== Session End ==="
echo ""

# ── Step 1: Docs lag ─────────────────────────────────────────────────────────
echo "[ 1/3 ] Docs lag check"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  check_warn "Not inside a git repo — skipping"
else
  # Support both docs/ and instructions/ (harness uses instructions/)
  if [ -d "docs" ]; then
    DOCS_DIR="docs"
  elif [ -d "instructions" ]; then
    DOCS_DIR="instructions"
  else
    DOCS_DIR=""
  fi

  if [ -z "$DOCS_DIR" ]; then
    check_warn "No docs/ or instructions/ directory — skipping"
  else
    DOCS_COMMIT=$(git log --oneline -1 -- "$DOCS_DIR" 2>/dev/null | awk '{print $1}' || echo "")
    HEAD_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "")

    if [ -z "$DOCS_COMMIT" ]; then
      check_warn "$DOCS_DIR/ has never been committed"
    else
      LAG=$(git log --oneline "$DOCS_COMMIT"..HEAD 2>/dev/null | wc -l | tr -d ' ')
      if [ "$LAG" -gt 3 ]; then
        check_warn "$DOCS_DIR/ is ${LAG} commits behind HEAD — consider a docs update"
        echo "   Last docs commit: $DOCS_COMMIT"
      else
        check_pass "$DOCS_DIR/ lag: ${LAG} commit(s) — OK"
      fi
    fi
  fi
fi

echo ""

# ── Step 2: PROGRESS.md ──────────────────────────────────────────────────────
echo "[ 2/3 ] PROGRESS.md check"

if [ ! -f "PROGRESS.md" ]; then
  check_warn "PROGRESS.md not found — create it to track session continuity"
  echo "   → Run: cp ~/.opencode-harness/templates/PROGRESS.md ."
else
  # Check if updated today (modification date)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d" PROGRESS.md 2>/dev/null || echo "unknown")
  else
    MODIFIED=$(stat -c "%y" PROGRESS.md 2>/dev/null | cut -d' ' -f1 || echo "unknown")
  fi

  if [ "$MODIFIED" = "$TODAY" ]; then
    check_pass "PROGRESS.md updated today"
  else
    check_warn "PROGRESS.md last updated: $MODIFIED (not today)"
    echo "   → Append what was done this session before closing"
  fi
fi

echo ""

# ── Step 3: Memory log ───────────────────────────────────────────────────────
echo "[ 3/3 ] Memory log check"

MEMORY_FILE="memory/$TODAY.md"

  SESSION_CHANGES=$(git diff HEAD~1 --name-only 2>/dev/null || true)

  if [ ! -d "memory" ]; then
    if [ -n "$SESSION_CHANGES" ]; then
      check_fail "memory/ not found and session has changes — workarounds may be lost"
      echo "   → Run: mkdir memory && touch $MEMORY_FILE"
    else
      check_warn "memory/ directory not found"
      echo "   → Run: mkdir memory"
    fi
  elif [ ! -f "$MEMORY_FILE" ]; then
    if [ -n "$SESSION_CHANGES" ]; then
      check_fail "No memory log for today and session has changes — workarounds may be lost"
      echo "   → Run: touch $MEMORY_FILE && write session notes"
    else
      check_warn "No memory log for today: $MEMORY_FILE"
      echo "   → If you found workarounds or errors this session — write them now"
    fi
else
  LINES=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [ "$LINES" -lt 3 ]; then
    check_warn "$MEMORY_FILE exists but seems empty ($LINES lines)"
    echo "   → Add session notes before closing"
  else
    check_pass "$MEMORY_FILE exists ($LINES lines)"
  fi
fi

echo ""

# ── Uncommitted check ────────────────────────────────────────────────────────
echo "[ + ] Uncommitted changes"

if git rev-parse --is-inside-work-tree &>/dev/null; then
  UNCOMMITTED=$(git status --porcelain 2>/dev/null | grep -v "^??" || true)
  if [ -z "$UNCOMMITTED" ]; then
    check_pass "Nothing uncommitted"
  else
    check_warn "Uncommitted changes — commit before closing:"
    echo "$UNCOMMITTED" | sed 's/^/    /'
    echo "   → Run: git add -p && git commit"
  fi
fi

echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"
echo ""

if [ $FAIL -gt 0 ]; then
  echo "✗ Session has issues — fix fails before closing."
  exit 1
elif [ $WARN -gt 0 ]; then
  echo "Address warnings above, then push when ready."
  echo "Push to remote? Run: git push"
else
  echo "Session clean. Push to remote? Run: git push"
fi

# ── Mark session as closed ────────────────────────────────────────────────────
date +%Y-%m-%d > .session-ended
echo "✓ Session closed: $(cat .session-ended)"