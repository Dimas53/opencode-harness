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
echo "[ 1/5 ] Docs lag check"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  check_warn "Not inside a git repo — skipping"
else
  # Both directories, not the first that exists — same fix as dod.sh step 3:
  # T-J2 rotation creates docs/progress-archive/, and "docs/ wins if present"
  # then measured lag against a directory with no documentation in it. Rotated
  # history is excluded: filing it away is not a docs update.
  DOCS_PATHS=()
  [ -d "docs" ] && DOCS_PATHS+=("docs")
  [ -d "instructions" ] && DOCS_PATHS+=("instructions")
  if [ "${#DOCS_PATHS[@]}" -gt 0 ]; then
    DOCS_DIR="${DOCS_PATHS[0]}"
  else
    DOCS_DIR=""
  fi

  if [ -z "$DOCS_DIR" ]; then
    check_warn "No docs/ or instructions/ directory — skipping"
  else
    DOCS_COMMIT=$(git log --oneline -1 -- "${DOCS_PATHS[@]}" ":(exclude)docs/progress-archive" 2>/dev/null | awk '{print $1}' || echo "")
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
echo "[ 2/5 ] PROGRESS.md check"

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
echo "[ 3/5 ] Memory log check"

MEMORY_FILE="memory/$TODAY.md"

  SESSION_CHANGES=$(git diff HEAD~1 --name-only 2>/dev/null || true)

  if [ ! -d "memory" ]; then
    if [ -n "$SESSION_CHANGES" ]; then
      check_fail "memory/ not found and session has changes — workarounds may be lost, and there is no ## Retro"
      echo "   → Run: mkdir memory && touch $MEMORY_FILE"
      echo "   → Include a ## Retro section: what went wrong / workaround found /"
      echo "     skill behaved unexpectedly (or 'none' for each)"
      echo "   → A blocked Hard Limit is NOT a workaround. Later sessions read"
      echo "     this file as practice — do not record a way around the gate."
    else
      check_warn "memory/ directory not found"
      echo "   → Run: mkdir memory"
    fi
  elif [ ! -f "$MEMORY_FILE" ]; then
    if [ -n "$SESSION_CHANGES" ]; then
      check_fail "No memory log for today and session has changes — workarounds may be lost, and there is no ## Retro"
      echo "   → Run: touch $MEMORY_FILE && write session notes"
      echo "   → Include a ## Retro section: what went wrong / workaround found /"
      echo "     skill behaved unexpectedly (or 'none' for each)"
      echo "   → A blocked Hard Limit is NOT a workaround. Later sessions read"
      echo "     this file as practice — do not record a way around the gate."
    else
      check_warn "No memory log for today: $MEMORY_FILE — and therefore no ## Retro either"
      echo "   → If you found workarounds or errors this session — write them now"
      echo "   → Then add a ## Retro section: what went wrong / workaround found /"
      echo "     skill behaved unexpectedly (or 'none' for each)"
    fi
else
  LINES=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [ "$LINES" -lt 3 ]; then
    check_warn "$MEMORY_FILE exists but seems empty ($LINES lines)"
    echo "   → Add session notes before closing"
  else
    check_pass "$MEMORY_FILE exists ($LINES lines)"
  fi

  # ── Audit trail (T-F4) — auto-append today's DoD run log. Mechanizes
  #    the format session-end/SKILL.md already documented (T-H5): proof of
  #    what actually ran this session, not just what the diff shows.
  #    Idempotent (skips if already present) so reruns don't duplicate it.
  if [ -f ".dod-run.log" ] && ! grep -q "^## Session audit trail" "$MEMORY_FILE" 2>/dev/null; then
    TODAY_RUNS=$(grep "^$TODAY" ".dod-run.log" 2>/dev/null || true)
    if [ -n "$TODAY_RUNS" ]; then
      {
        echo ""
        echo "## Session audit trail"
        echo ""
        echo "DoD runs today (timestamp|mode|pass|fail|warn|skip|result):"
        echo '```'
        echo "$TODAY_RUNS"
        echo '```'
      } >> "$MEMORY_FILE"
      RUN_COUNT=$(echo "$TODAY_RUNS" | grep -c .)
      echo "  ✓ Audit trail appended to $MEMORY_FILE ($RUN_COUNT DoD run(s) today)"
    fi
  fi

  # ── Retro nudge (T-F4) — DoD step 7 (Skill feedback) generalized to the
  #    whole session, per session-end/SKILL.md. Warn only, never blocks;
  #    content itself needs the agent's own reflection, not something to
  #    auto-generate.
  #
  #    The branches above carry the same reminder, deliberately: this one only
  #    fires when memory/YYYY-MM-DD.md exists, and the session with no memory
  #    file at all is precisely the one where nothing was reflected on. Having
  #    the nudge only here meant it was absent exactly where it was needed
  #    most (T-I20).
  if ! grep -q "^## Retro" "$MEMORY_FILE" 2>/dev/null; then
    check_warn "$MEMORY_FILE has no ## Retro section — add one line each: what went wrong / workaround found / skill behaved unexpectedly (or 'none')"
  fi
fi

echo ""

# ── Step 4: Docs completeness (T-G2) ─────────────────────────────────────────
# Only fires once a project has some history — flagging an empty HARNESS.md
# on session 1 would just be noise (G-DEC-2: warn after ~4 sessions, never
# fail). Session count = dated headings in PROGRESS.md plus the archive.
#
# It used to count `^### YYYY-MM-DD` only — the templates/PROGRESS.md spelling,
# which is the one live projects use least: this repo writes
# `## Session 2026-08-07 (…)` and a client project writes
# `## Current session — … (2026-08-14)`. So the check that fires "after ~4
# sessions" was reading 0 in the very projects it was written for. Rotation
# (T-J2) made it visible by moving the few matching lines into the archive,
# but the miscount predates it. Same detector as rotate-progress.sh: a level-2
# or 3 heading containing an ISO date. The archive is counted too — sessions
# that happened do not stop having happened when they are filed away.
echo "[ 4/5 ] Docs completeness check"

SESSION_COUNT=0
if [ -f "PROGRESS.md" ]; then
  SESSION_COUNT=$(grep -cE "^#{2,3} .*[0-9]{4}-[0-9]{2}-[0-9]{2}" PROGRESS.md 2>/dev/null) || SESSION_COUNT=0
fi
if [ -d "docs/progress-archive" ]; then
  ARCHIVED=$(grep -hcE "^#{2,3} .*[0-9]{4}-[0-9]{2}-[0-9]{2}" docs/progress-archive/*.md 2>/dev/null \
    | awk '{s+=$1} END {print s+0}') || ARCHIVED=0
  SESSION_COUNT=$((SESSION_COUNT + ARCHIVED))
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

  # `{{PLACEHOLDER}}` is excluded on purpose: it is how both AGENTS.md files
  # NAME the convention ("templates use {{PLACEHOLDER}} syntax"), not an
  # unfilled slot. Without this the harness's own AGENTS.md reports itself as
  # unfilled forever, and a warning that is always on is a warning nobody reads.
  if [ -f "AGENTS.md" ] && grep -oE '\{\{[A-Z_]+\}\}' AGENTS.md 2>/dev/null | grep -qv '^{{PLACEHOLDER}}$'; then
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
echo "[ 5/5 ] Uncommitted changes"

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

# ── PROGRESS.md rotation (T-J2) ──────────────────────────────────────────────
# Deliberately AFTER every check above, not before. Step 2 asks whether
# PROGRESS.md was updated today; rotation rewrites the file, so running it
# first would answer that question with its own side effect. (The script also
# restores the original mtime for the same reason — belt and braces, because
# the ordering here is easy to "tidy up" later without noticing why it was
# chosen.)
#
# Rotation is what keeps Session Start affordable: PROGRESS.md is ~70% of the
# cold-start context budget, and it is read in full every session.
echo ""
echo "PROGRESS.md rotation"
ROTATE="$(dirname "$0")/rotate-progress.sh"
if [ -f "$ROTATE" ]; then
  bash "$ROTATE" || check_warn "rotate-progress.sh failed — PROGRESS.md left as is"
else
  check_warn "rotate-progress.sh not found next to session-end.sh — skipping rotation"
fi

echo ""

# ── memory/ index (T-J4) ─────────────────────────────────────────────────────
# Same placement rationale as rotation above: after the checks, so it cannot
# answer them with its own side effect. Regenerating the index here is what
# makes "write a note and forget to index it" impossible — the alternative was
# a rule telling the agent to remember, which is the class of mechanism this
# harness keeps finding broken.
echo "memory/ index"
INDEXER="$(dirname "$0")/index-memory.sh"
if [ -f "$INDEXER" ]; then
  bash "$INDEXER" || check_warn "index-memory.sh failed — MEMORY.md index not updated"
else
  check_warn "index-memory.sh not found next to session-end.sh — skipping memory index"
fi

echo ""

# ── Mark session as closed ────────────────────────────────────────────────────
date +%Y-%m-%d > .session-ended
echo "✓ Session closed: $(cat .session-ended)"