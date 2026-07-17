#!/bin/bash
# scripts/dod.sh — Definition of Done checks
# Called by: make dod, pre-commit hook
# Returns: 0 if all pass, 1 if any fail
set -euo pipefail

PASS=0
FAIL=0
WARN=0

check_pass() { echo "✓ $1"; PASS=$((PASS + 1)); }
check_fail() { echo "✗ $1"; FAIL=$((FAIL + 1)); }
check_warn() { echo "⚠ $1"; WARN=$((WARN + 1)); }

echo "=== DoD Check ==="
echo ""

# ── Step 1: Uncommitted changes ──────────────────────────────────────────────
echo "[ 1/5 ] Uncommitted changes"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  check_warn "Not inside a git repo — skipping git checks"
else
  if [ "${PRE_COMMIT:-0}" = "1" ]; then
    # In pre-commit hook: staged changes are the commit itself — only check unstaged
    UNCOMMITTED=$(git diff --stat 2>/dev/null || true)
  else
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | grep -v "^??" || true)
  fi
  if [ -z "$UNCOMMITTED" ]; then
    check_pass "No uncommitted changes"
  else
    check_fail "Uncommitted changes found:"
    echo "$UNCOMMITTED" | sed 's/^/    /'
    echo "   → Run: git add -p && git commit"
  fi
fi

echo ""

# ── Step 2: Cyrillic scan ────────────────────────────────────────────────────
echo "[ 2/5 ] Cyrillic scan (project files)"

# What to scan: tracked files only, excluding notes/ and binary files
CYRILLIC_HITS=""

if git rev-parse --is-inside-work-tree &>/dev/null; then
  # Scan staged files if called from pre-commit, all tracked files otherwise
  if [ "${PRE_COMMIT:-0}" = "1" ]; then
    FILES=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
  else
    FILES=$(git ls-files 2>/dev/null || true)
  fi

  if [ -n "$FILES" ]; then
    # Exclude notes/ (Russian allowed), global/ (harness templates), this script itself, binary extensions
    SCAN_FILES=$(echo "$FILES" | grep -v "^notes/" | grep -v "^global/" | grep -v "^scripts/dod.sh" | grep -v "^scripts/session-end.sh" | grep -vE "\.(png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot|pdf|zip|tar|gz)$" || true)

    if [ -n "$SCAN_FILES" ]; then
      CYRILLIC_HITS=$(echo "$SCAN_FILES" | xargs grep -rl '[А-Яа-яЁё]' 2>/dev/null || true)
    fi
  fi
fi

if [ -z "$CYRILLIC_HITS" ]; then
  check_pass "No Cyrillic in project files"
else
  check_fail "Cyrillic found in:"
  echo "$CYRILLIC_HITS" | sed 's/^/    /'
  echo "   → Replace Russian text with English before committing"
fi

echo ""

# ── Step 3: Docs lag ─────────────────────────────────────────────────────────
echo "[ 3/5 ] Docs lag check"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  check_warn "Not inside a git repo — skipping docs lag check"
else
  DOCS_DIR="docs"
  if [ ! -d "$DOCS_DIR" ]; then
    check_warn "No docs/ directory — skipping"
  else
    # Last commit touching docs/
    DOCS_COMMIT=$(git log --oneline -- "$DOCS_DIR" 2>/dev/null | head -1 | awk '{print $1}')
    # Current HEAD
    HEAD_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "")

    if [ -z "$DOCS_COMMIT" ]; then
      check_warn "docs/ has never been committed — consider adding initial docs"
    elif [ "$DOCS_COMMIT" = "$HEAD_COMMIT" ]; then
      check_pass "Docs are current (last commit = HEAD)"
    else
      # Count commits since docs were last touched
      LAG=$(git log --oneline "$DOCS_COMMIT"..HEAD 2>/dev/null | wc -l | tr -d ' ')
      if [ "$LAG" -gt 3 ]; then
        check_fail "Docs are ${LAG} commits behind HEAD (last docs commit: $DOCS_COMMIT)"
        echo "   → Run a documentation session before closing"
      else
        check_pass "Docs lag: ${LAG} commit(s) — acceptable"
      fi
    fi
  fi
fi

echo ""

# ── Step 4: PROGRESS.md ──────────────────────────────────────────────────────
echo "[ 4/5 ] PROGRESS.md check"

TODAY=$(date +%Y-%m-%d)

if [ ! -f "PROGRESS.md" ]; then
  check_fail "PROGRESS.md not found"
  echo "   → Create it first: cp templates/PROGRESS.md PROGRESS.md"
else
  if [[ "$OSTYPE" == "darwin"* ]]; then
    MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d" PROGRESS.md 2>/dev/null || echo "unknown")
  else
    MODIFIED=$(stat -c "%y" PROGRESS.md 2>/dev/null | cut -d' ' -f1 || echo "unknown")
  fi

  if [ "$MODIFIED" = "$TODAY" ]; then
    check_pass "PROGRESS.md updated today"
  elif [ "$MODIFIED" = "unknown" ]; then
    check_warn "PROGRESS.md — could not determine modification date"
  else
    check_warn "PROGRESS.md last updated: $MODIFIED (not today)"
    echo "   → Add today's work before committing"
  fi
fi

echo ""

# ── Step 5: Quick tests ──────────────────────────────────────────────────────
echo "[ 5/5 ] Quick tests"

if command -v bats &>/dev/null && [ -f "Makefile" ]; then
  TEST_OUTPUT=$(make test-quick 2>&1) && TEST_OK=1 || TEST_OK=0
  if [ "$TEST_OK" = "1" ]; then
    check_pass "All tests pass"
  else
    check_fail "Tests failed — run 'make test-quick' to see details"
    echo "   $TEST_OUTPUT" | head -5 | sed 's/^/    /'
  fi
else
  check_warn "bats or Makefile not found — skipping tests"
fi

echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"

if [ $FAIL -gt 0 ]; then
  echo ""
  echo "✗ DoD failed — fix the issues above before committing."
  exit 1
else
  echo ""
  if [ $WARN -gt 0 ]; then
    echo "✓ DoD passed (with $WARN warning(s))."
  else
    echo "✓ DoD passed."
  fi
  exit 0
fi