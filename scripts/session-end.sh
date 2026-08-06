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
echo "[ 1/4 ] Docs lag check"

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
echo "[ 2/4 ] PROGRESS.md check"

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
echo "[ 3/4 ] Memory log check"

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

# ── Step 4: Docs completeness (T-G2) ─────────────────────────────────────────
# Only fires once a project has some history — flagging an empty HARNESS.md
# on session 1 would just be noise (G-DEC-2: warn after ~4 sessions, never
# fail). Session count = number of "### YYYY-MM-DD" entries under PROGRESS.md
# Session Log — the templates/PROGRESS.md convention.
echo "[ 4/4 ] Docs completeness check"

SESSION_COUNT=0
if [ -f "PROGRESS.md" ]; then
  # grep -c prints "0" AND exits 1 on no match — `|| echo 0` would append a
  # second "0" on a new line instead of replacing it. Reset on failure instead.
  SESSION_COUNT=$(grep -cE "^### [0-9]{4}-[0-9]{2}-[0-9]{2}" PROGRESS.md 2>/dev/null) || SESSION_COUNT=0
fi

if [ "$SESSION_COUNT" -lt 4 ]; then
  check_pass "Docs-completeness check skipped — only $SESSION_COUNT session(s) logged (fires at 4+)"
else
  PLACEHOLDERS_FOUND=0

  if [ -f "HARNESS.md" ]; then
    grep -qF -- "- [ ] ..." HARNESS.md 2>/dev/null && {
      check_warn "HARNESS.md Product Contract not filled in ($SESSION_COUNT sessions in)"
      PLACEHOLDERS_FOUND=1
    }
    grep -qxF -- "- ..." HARNESS.md 2>/dev/null && {
      check_warn "HARNESS.md Decisions to Inherit not filled in ($SESSION_COUNT sessions in)"
      PLACEHOLDERS_FOUND=1
    }
  fi

  if [ -f "AGENTS.md" ] && grep -qE '\{\{[A-Z_]+\}\}' AGENTS.md 2>/dev/null; then
    check_warn "AGENTS.md still has unfilled {{...}} placeholders ($SESSION_COUNT sessions in) — agent is missing stack/file-map context"
    PLACEHOLDERS_FOUND=1
  fi

  # design.md only applies to UI projects (same heuristic as T-G3's adopt-time skip).
  if [ -f "package.json" ] || find . -maxdepth 2 -name package.json -not -path '*/node_modules/*' 2>/dev/null | grep -q .; then
    if [ -f "docs/design.md" ] && grep -qF "TBD" docs/design.md 2>/dev/null; then
      check_warn "docs/design.md still has TBD placeholders ($SESSION_COUNT sessions in)"
      PLACEHOLDERS_FOUND=1
    fi
  fi

  if [ -f "docs/CONTEXT.md" ] && grep -qF "[Term]" docs/CONTEXT.md 2>/dev/null; then
    check_warn "docs/CONTEXT.md still has the example placeholder row ($SESSION_COUNT sessions in)"
    PLACEHOLDERS_FOUND=1
  fi

  if [ -f "docs/roadmap.md" ] && grep -qF "[Phase name]" docs/roadmap.md 2>/dev/null; then
    check_warn "docs/roadmap.md still has [Phase name] placeholders ($SESSION_COUNT sessions in)"
    PLACEHOLDERS_FOUND=1
  fi

  [ "$PLACEHOLDERS_FOUND" -eq 0 ] && check_pass "No stale placeholders found in key docs ($SESSION_COUNT sessions in)"
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