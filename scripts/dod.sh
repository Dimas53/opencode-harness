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
echo "[ 1/7 ] Uncommitted changes"

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
  elif [ "${PRE_COMMIT:-0}" != "1" ]; then
    check_warn "Uncommitted changes present (expected before a commit):"
    echo "$UNCOMMITTED" | sed 's/^/    /'
  else
    check_fail "Uncommitted changes found:"
    echo "$UNCOMMITTED" | sed 's/^/    /'
    echo "   → Run: git add -p && git commit"
  fi
fi

echo ""

# ── Step 2: Cyrillic scan ────────────────────────────────────────────────────
echo "[ 2/7 ] Cyrillic scan (project files)"

CYRILLIC_FAIL=0
if git rev-parse --is-inside-work-tree &>/dev/null; then
  # Determine files and diff source based on mode
  if [ "${PRE_COMMIT:-0}" = "1" ]; then
    FILES=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
    DIFF_SRC="git diff --cached"
  else
    FILES=$(git diff --name-only HEAD 2>/dev/null || true)
    DIFF_SRC="git diff HEAD --"
  fi

  for file in $FILES; do
    # Skip known exceptions
    [[ "$file" == docs/audits/* ]] && continue
    [[ "$file" == notes/* ]] && continue
    [[ "$file" == global/* ]] && continue
    [[ "$file" == scripts/dod.sh ]] && continue
    [[ "$file" == scripts/session-end.sh ]] && continue

    # Skip binary extensions
    case "$file" in
      *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.woff|*.woff2|*.ttf|*.eot|*.pdf|*.zip|*.tar|*.gz) continue ;;
    esac

    # Check added lines only, exclude the Chat language: label itself
    if [ -f "$file" ] && $DIFF_SRC "$file" 2>/dev/null | grep '^+' | grep -v '^+++' | grep -v 'Chat language:' | grep -q '[а-яА-ЯёЁ]'; then
      check_fail "Cyrillic found in $file — use English"
      echo "   Affected lines:"
      $DIFF_SRC "$file" 2>/dev/null | grep '^+' | grep -v '^+++' | grep -v 'Chat language:' | grep '[а-яА-ЯёЁ]' | sed 's/^+/    +/'
      CYRILLIC_FAIL=1
    fi
  done
fi

if [ "$CYRILLIC_FAIL" -eq 0 ]; then
  check_pass "No Cyrillic in changed files"
fi

echo ""

# ── Step 3: Docs lag ─────────────────────────────────────────────────────────
echo "[ 3/7 ] Docs lag check"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  check_warn "Not inside a git repo — skipping docs lag check"
else
  if [ -d "docs" ]; then
    DOCS_DIR="docs"
  elif [ -d "instructions" ]; then
    DOCS_DIR="instructions"
  else
    DOCS_DIR=""
  fi

  # Pre-commit: if this commit stages docs/, it resets the lag once landed.
  # The history check below would still see the OLD lag (HEAD is unchanged
  # until the commit is created), deadlocking the very docs commit that
  # should fix the lag.
  if [ -n "$DOCS_DIR" ] && [ "${PRE_COMMIT:-0}" = "1" ] && git diff --cached --name-only 2>/dev/null | grep -q "^$DOCS_DIR/"; then
    check_pass "Docs updated in this commit — lag resets after commit"
  elif [ -z "$DOCS_DIR" ]; then
    check_warn "No docs/ or instructions/ directory — skipping"
  else
    # Last commit touching docs/
    DOCS_COMMIT=$(git log --oneline -- "$DOCS_DIR" 2>/dev/null | sed -n '1p' | awk '{print $1}')
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
echo "[ 4/7 ] PROGRESS.md check"

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

# ── Step 5: Docs matrix check ────────────────────────────────────────────────
echo "[ 5/7 ] Docs matrix check"

CODE_DIRS="scripts/ hooks/ tests/ global/ templates/ Makefile"
DOCS_DIRS="docs/ instructions/"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  check_warn "Not inside a git repo — skipping"
else
  if [ "${PRE_COMMIT:-0}" = "1" ]; then
    CHANGED=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
  else
    CHANGED=$(git diff HEAD~1 --name-only --diff-filter=ACMR 2>/dev/null || true)
  fi

  if [ -z "$CHANGED" ]; then
    check_pass "No changed files to check"
  else
    # Filter out files that ARE documentation (PROGRESS.md, notes/)
    CODE_CHANGED=0
    DOCS_CHANGED=0
    FILTERED=$(echo "$CHANGED" | grep -v "^PROGRESS.md$" | grep -v "^notes/" || true)
    for d in $CODE_DIRS; do
      if echo "$FILTERED" | grep -q "^$d"; then CODE_CHANGED=1; fi
    done
    for d in $DOCS_DIRS; do
      if echo "$FILTERED" | grep -q "^$d"; then DOCS_CHANGED=1; fi
    done
    if [ "$CODE_CHANGED" = "1" ] && [ "$DOCS_CHANGED" = "0" ]; then
      # Skill-only fallback: if EVERY non-doc changed file lives under
      # global/skills/, accept a same-day dated section in
      # instructions/CHANGELOG.md as the docs update. This does NOT apply
      # to any other CODE_DIRS path (scripts/, hooks/, tests/, templates/,
      # Makefile) — those still require a real docs/ or instructions/ update.
      SKILL_ONLY=1
      for f in $FILTERED; do
        case "$f" in
          global/skills/*) ;;
          *) SKILL_ONLY=0 ;;
        esac
      done
      TODAY=$(date +%Y-%m-%d)
      if [ "$SKILL_ONLY" = "1" ] && [ -f "instructions/CHANGELOG.md" ] \
         && grep -q "^## $TODAY" instructions/CHANGELOG.md; then
        check_pass "Skill-only change — same-day CHANGELOG.md entry found ($TODAY)"
      else
        check_fail "Code changed but no docs update found"
        echo "   Changed: $(echo "$CHANGED" | tr '\n' ' ')"
        if [ "$SKILL_ONLY" = "1" ]; then
          echo "   → Skill-only change detected. Add a dated section to"
          echo "     instructions/CHANGELOG.md before committing:"
          echo "       ## $TODAY"
          echo "       - what changed in the skill and why"
        else
          echo "   → Update docs/ or instructions/ before committing"
        fi
      fi
    else
      check_pass "Code changes accompanied by docs update (or docs-only change)"
    fi
  fi
fi

echo ""

# ── Step 6: Quick tests ──────────────────────────────────────────────────────
echo "[ 6/7 ] Quick tests"

if command -v bats &>/dev/null && [ -f "Makefile" ]; then
  TEST_OUTPUT=$(make test-quick 2>&1) && TEST_OK=1 || TEST_OK=0
  if [ "$TEST_OK" = "1" ]; then
    check_pass "All tests pass"
  else
    check_fail "Tests failed — run 'make test-quick' to see details"
    echo "   $TEST_OUTPUT" | head -5 | sed 's/^/    /'
  fi
else
  check_warn "bats or Makefile not found — TESTS NOT RUN. Install: brew install bats-core (or see README). Real enforcement happens in CI regardless of local bats."
fi

echo ""

# ── Step 7: Self-check ───────────────────────────────────────────────────────
echo "[ 7/7 ] Self-check (verification-before-completion)"
echo "  → Did you verify each change actually works, not just syntactically?"
echo "  → Run: bash -n on changed scripts"
echo "  → Run: make verify"
if ls scripts/*.sh &>/dev/null 2>&1; then
  bash -n scripts/*.sh 2>&1 && check_pass "Self-check (syntax)" || check_fail "Self-check" "fix syntax errors above"
else
  check_warn "No scripts/*.sh found — skipping syntax check"
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