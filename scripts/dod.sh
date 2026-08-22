#!/bin/bash
# scripts/dod.sh — Definition of Done checks
# Called by: make dod, pre-commit hook
# Returns: 0 if all pass, 1 if any fail
#
# DOD_SKIP=<step-name>[,<step-name>...] — skip specific named steps only.
# Valid names: docs-lag, progress, docs-matrix, tests, self-check
# NEVER skippable: uncommitted (in pre-commit mode), cyrillic, agentignore —
# these guard git integrity and the Safety Check; there is no override for them.
# Usage: DOD_SKIP=docs-matrix git commit -m "..."
# Every skip is printed as a WARNING in the output — it is never silent.
set -euo pipefail

PASS=0
FAIL=0
WARN=0

DOD_SKIP="${DOD_SKIP:-}"
is_skipped() {
  case ",$DOD_SKIP," in
    *",$1,"*) return 0 ;;
    *) return 1 ;;
  esac
}
skip_notice() {
  check_warn "Step '$1' SKIPPED via DOD_SKIP=$DOD_SKIP — this is logged, not silent"
}

check_pass() { echo "✓ $1"; PASS=$((PASS + 1)); }
check_fail() { echo "✗ $1"; FAIL=$((FAIL + 1)); }
check_warn() { echo "⚠ $1"; WARN=$((WARN + 1)); }

# Steps 6/7 below check for a local Makefile/bats and scripts/*.sh — real
# only in the harness repo itself. Client projects never get their own copy
# of these (see init-project.sh/init-adopt.sh), so absence there is the
# expected, correct state, not something to warn about.
IS_HARNESS_REPO=0
[ -f "scripts/init-project.sh" ] && IS_HARNESS_REPO=1

echo "=== DoD Check ==="
echo ""

# ── Step 1: Uncommitted changes ──────────────────────────────────────────────
echo "[ 1/8 ] Uncommitted changes"

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
echo "[ 2/8 ] Cyrillic scan (project files)"

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
    [[ "$file" == scripts/dod.sh ]] && continue
    [[ "$file" == scripts/session-end.sh ]] && continue
    [[ "$file" == tests/dod.bats ]] && continue
    # Same reason as dod.sh itself: this script has to spell out a Cyrillic
    # character class in order to scan for one (T-I13). grep -P, which would
    # let us write \p{Cyrillic} instead, does not exist in BSD grep.
    [[ "$file" == scripts/check-docs-refs.sh ]] && continue
    # Rotated history, not new writing (T-J2). rotate-progress.sh moves old
    # PROGRESS.md sections here verbatim; some pre-date the English-only rule
    # and this scan never saw them, because it only ever looks at changed
    # files and they had not changed in months. Failing the commit that files
    # them away would make rotation impossible in exactly the projects that
    # need it most. PROGRESS.md itself stays scanned — new entries are new
    # writing and the rule applies to them in full.
    [[ "$file" == docs/progress-archive/* ]] && continue

    # Skip binary extensions
    case "$file" in
      *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.woff|*.woff2|*.ttf|*.eot|*.pdf|*.zip|*.tar|*.gz) continue ;;
    esac

    # Check added lines only, exclude the Chat language: label itself.
    #
    # Collected into a variable rather than tested with a trailing `grep -q`.
    # `-q` exits at the first match, the greps upstream of it take SIGPIPE, and
    # `set -o pipefail` (line 12) turns that into status 141 — so the `if` read
    # false and the scan silently reported nothing. It needs a diff large
    # enough for the writer to still be writing when `-q` leaves, which is why
    # it showed up first in CI (GNU grep leaves immediately) and would have hit
    # macOS on any big commit. Found 2026-08-22; reproduced on both platforms.
    #
    # Reading the whole stream costs nothing here and cannot race.
    if [ -f "$file" ]; then
      ADDED=$($DIFF_SRC "$file" 2>/dev/null | grep '^+' | grep -v '^+++' | grep -v 'Chat language:' || true)
      CYR_LINES=$(printf '%s\n' "$ADDED" | grep '[а-яА-ЯёЁ]' || true)
      if [ -n "$CYR_LINES" ]; then
        check_fail "Cyrillic found in $file — use English"
        echo "   Affected lines:"
        printf '%s\n' "$CYR_LINES" | sed 's/^+/    +/'
        CYRILLIC_FAIL=1
      fi
    fi
  done
fi

if [ "$CYRILLIC_FAIL" -eq 0 ]; then
  check_pass "No Cyrillic in changed files"
fi

echo ""

# ── Step 3: Docs lag ─────────────────────────────────────────────────────────
echo "[ 3/8 ] Docs lag check"

if is_skipped "docs-lag"; then
  skip_notice "docs-lag"
else
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  check_warn "Not inside a git repo — skipping docs lag check"
else
  # Both directories are considered, not the first one that happens to exist.
  # This repo renamed docs/ to instructions/ (84641c5), so "docs/ wins if
  # present" was correct only for as long as docs/ stayed absent — the moment
  # T-J2 rotation created docs/progress-archive/, the gate started measuring
  # lag against a directory holding no documentation and reported 235 commits
  # behind. Measuring the freshest commit across both survives the rename in
  # either direction. progress-archive is excluded because it is rotated
  # history: committing it is not a documentation update.
  DOCS_PATHS=()
  [ -d "docs" ] && DOCS_PATHS+=("docs")
  [ -d "instructions" ] && DOCS_PATHS+=("instructions")
  if [ "${#DOCS_PATHS[@]}" -gt 0 ]; then
    DOCS_DIR="${DOCS_PATHS[0]}"
  else
    DOCS_DIR=""
  fi

  # Pre-commit: if this commit stages docs/, it resets the lag once landed.
  # The history check below would still see the OLD lag (HEAD is unchanged
  # until the commit is created), deadlocking the very docs commit that
  # should fix the lag.
  DOCS_STAGED=0
  for d in "${DOCS_PATHS[@]+"${DOCS_PATHS[@]}"}"; do
    git diff --cached --name-only 2>/dev/null \
      | grep -v "^docs/progress-archive/" | grep -q "^$d/" && DOCS_STAGED=1
  done
  if [ -n "$DOCS_DIR" ] && [ "${PRE_COMMIT:-0}" = "1" ] && [ "$DOCS_STAGED" = "1" ]; then
    check_pass "Docs updated in this commit — lag resets after commit"
  elif [ -z "$DOCS_DIR" ]; then
    check_warn "No docs/ or instructions/ directory — skipping"
  else
    # Freshest commit touching ANY documentation directory, minus rotated
    # history — see the DOCS_PATHS comment above.
    DOCS_COMMIT=$(git log --oneline -- "${DOCS_PATHS[@]}" ":(exclude)docs/progress-archive" 2>/dev/null \
      | sed -n '1p' | awk '{print $1}')
    # Current HEAD
    HEAD_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "")

    if [ -z "$DOCS_COMMIT" ]; then
      check_warn "docs/ has never been committed — consider adding initial docs"
    elif [ "$DOCS_COMMIT" = "$HEAD_COMMIT" ]; then
      check_pass "Docs are current (last commit = HEAD)"
    else
      # Count commits since docs were last touched.
      LAG=$(git log --oneline "$DOCS_COMMIT"..HEAD 2>/dev/null | wc -l | tr -d ' ')
      # In pre-commit mode the commit being created is not in HEAD yet, so the
      # same commit is counted as LAG for pre-commit and LAG+1 for the
      # post-commit guard — the gate would pass a commit and the guard would
      # then roll it back, blaming --no-verify (T-I27). One commit must get
      # one verdict: count the commit being created, so the 4th non-docs
      # commit in a row is blocked BEFORE it lands, not rolled back after.
      if [ "${PRE_COMMIT:-0}" = "1" ]; then
        LAG=$((LAG + 1))
      fi
      if [ "$LAG" -gt 3 ]; then
        if [ "${PRE_COMMIT:-0}" = "1" ]; then
          check_fail "Docs would be ${LAG} commits behind HEAD after this commit (last docs commit: $DOCS_COMMIT)"
          echo "   → Stage a change under $DOCS_DIR/ in this commit, or run a documentation session first"
        else
          check_fail "Docs are ${LAG} commits behind HEAD (last docs commit: $DOCS_COMMIT)"
          echo "   → Run a documentation session before closing"
        fi
      else
        check_pass "Docs lag: ${LAG} commit(s) — acceptable"
      fi
    fi
  fi
fi
fi

echo ""

# ── Step 4: PROGRESS.md ──────────────────────────────────────────────────────
echo "[ 4/8 ] PROGRESS.md check"

if is_skipped "progress"; then
  skip_notice "progress"
else
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
fi

echo ""

# ── Step 5: Docs matrix check ────────────────────────────────────────────────
echo "[ 5/8 ] Docs matrix check"

if is_skipped "docs-matrix"; then
  skip_notice "docs-matrix"
else
CODE_DIRS="scripts/ hooks/ tests/ global/ templates/ Makefile"
DOCS_DIRS="docs/ instructions/"
DOCS_FILES="INSTALL.md README.md"

# T-H1 step 1: in the harness repo "code" is the explicit CODE_DIRS list
# above (layout is known and stable). In a client project we cannot know
# the layout, so we invert the test instead: a file counts as
# documentation if it lives in a docs dir, is a top-level .md, or is agent
# bookkeeping — everything else is code. Without this, CODE_DIRS never
# matched anything in a client project (app code lives in app/, server/,
# src/, ...) and this whole step was a permanent no-op there.
is_doc_file() {
  case "$1" in
    docs/*|instructions/*|notes/*|memory/*) return 0 ;;
    *.md) return 0 ;;
    *) return 1 ;;
  esac
}

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
    # Only meaningful when DOCS_CHANGED ends up 0 below — tracked from the
    # unfiltered list since PROGRESS.md itself is stripped out of FILTERED.
    PROGRESS_TOUCHED=0
    echo "$CHANGED" | grep -qx "PROGRESS.md" && PROGRESS_TOUCHED=1

    # Filter out files that ARE documentation (PROGRESS.md, notes/)
    CODE_CHANGED=0
    DOCS_CHANGED=0
    FILTERED=$(echo "$CHANGED" | grep -v "^PROGRESS.md$" | grep -v "^notes/" || true)
    if [ "$IS_HARNESS_REPO" = "1" ]; then
      for d in $CODE_DIRS; do
        if echo "$FILTERED" | grep -q "^$d"; then CODE_CHANGED=1; fi
      done
      for d in $DOCS_DIRS; do
        if echo "$FILTERED" | grep -q "^$d"; then DOCS_CHANGED=1; fi
      done
      for f in $DOCS_FILES; do
        if echo "$FILTERED" | grep -qx "$f"; then DOCS_CHANGED=1; fi
      done
    else
      for f in $FILTERED; do
        if is_doc_file "$f"; then DOCS_CHANGED=1; else CODE_CHANGED=1; fi
      done
    fi
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
      elif [ "$IS_HARNESS_REPO" != "1" ] && [ "$PROGRESS_TOUCHED" = "1" ]; then
        # H-DEC-1 (client profile only): PROGRESS.md is the canonical
        # minimum per the Docs Update Matrix's "anything else" row — warn,
        # don't fail, but still say what a real feature/config change owes.
        check_warn "Code changed, only PROGRESS.md updated — check the Docs Update Matrix (new feature -> docs/architecture/*.md, config change -> docs/deployment.md, etc.)"
        echo "   Changed: $(echo "$CHANGED" | tr '\n' ' ')"
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
fi

echo ""

# ── Step 6: Quick tests ──────────────────────────────────────────────────────
echo "[ 6/8 ] Quick tests"

if is_skipped "tests"; then
  skip_notice "tests"
else
if command -v bats &>/dev/null && [ -f "Makefile" ]; then
  TEST_OUTPUT=$(make test-quick 2>&1) && TEST_OK=1 || TEST_OK=0
  if [ "$TEST_OK" = "1" ]; then
    check_pass "All tests pass"
  else
    check_fail "Tests failed — run 'make test-quick' to see details"
    # Print the failing tests, not the first five lines. bats emits its TAP
    # header and plan first, so `head -5` showed "1..105" and nothing else —
    # a gate that announced a failure and then hid which one. Found when the
    # harness's own CI went red and the log carried no diagnosis (2026-08-22).
    #
    # No `head` and no early-exiting `awk` in these pipelines: either would
    # leave the writer upstream holding a closed pipe, and `pipefail` turns
    # that SIGPIPE into status 141, which aborts this script under `set -e` —
    # the diagnosis added above then killed the gate before steps 7 and 8 and
    # replaced exit 1 with exit 141. Both readers below consume the whole
    # stream and limit what they print instead.
    FAILING=$(printf '%s\n' "$TEST_OUTPUT" | grep -E '^not ok' || true)
    if [ -n "$FAILING" ]; then
      FAIL_TOTAL=$(printf '%s\n' "$FAILING" | wc -l | tr -d ' ')
      printf '%s\n' "$FAILING" | awk 'NR <= 20 { print "    " $0 }'
      [ "$FAIL_TOTAL" -gt 20 ] && echo "    … showing 20 of $FAIL_TOTAL failing tests"
      # Names alone say what broke, not why. bats writes its diagnosis as `#`
      # lines under each failure; print the first one's block so a red run is
      # actionable from the log instead of only reproducible on a machine.
      FIRST_BLOCK=$(printf '%s\n' "$TEST_OUTPUT" | awk '
        /^not ok/ { if (started) finished = 1; else started = 1 }
        started && !finished && n < 30 { print; n++ }')
      if [ -n "$FIRST_BLOCK" ]; then
        echo "    ── first failure in detail ──"
        printf '%s\n' "$FIRST_BLOCK" | sed 's/^/    /'
      fi
    else
      # Not a TAP failure — the runner itself broke. Show the end, where the
      # error is, rather than the beginning, where the banner is.
      printf '%s\n' "$TEST_OUTPUT" | tail -20 | sed 's/^/    /'
    fi
  fi
elif [ "$IS_HARNESS_REPO" = "1" ]; then
  check_warn "bats or Makefile not found — TESTS NOT RUN. Install: brew install bats-core (or see README). Real enforcement happens in CI regardless of local bats."
else
  # Client project: no harness Makefile by design. Do NOT claim success —
  # the project has its own test command (declared in HARNESS.md) and this
  # gate never ran it. Say so. propagation-ok: honest warn, not a stub —
  # auto-running the declared command is a separate, still-open decision
  # (H-DEC-2); this default (no auto-run) doesn't need it.
  if [ -f "HARNESS.md" ] && grep -qi "^\s*-\s*\*\*Tests:\*\*" HARNESS.md; then
    TESTS_LINE=$(grep -i "^\s*-\s*\*\*Tests:\*\*" HARNESS.md | head -1 | sed 's/.*\*\*Tests:\*\*//' | xargs)
    case "$TESTS_LINE" in
      *none*|*None*|*n/a*|*N/A*|*planned*)
        check_warn "Project declares no test suite yet (HARNESS.md: $TESTS_LINE)" ;;
      *)
        check_warn "TESTS NOT RUN by the gate — project test command: $TESTS_LINE — run it before saying done" ;;
    esac
  else
    check_warn "No test command declared — add '- **Tests:** <command>' to HARNESS.md"
  fi
fi
fi

echo ""

# ── Step 7: Self-check ───────────────────────────────────────────────────────
echo "[ 7/8 ] Self-check (verification-before-completion)"
if is_skipped "self-check"; then
  skip_notice "self-check"
else
echo "  → Did you verify each change actually works, not just syntactically?"
echo "  → Run: bash -n on changed scripts"
echo "  → Run: make verify"
if ls scripts/*.sh &>/dev/null 2>&1; then
  bash -n scripts/*.sh 2>&1 && check_pass "Self-check (syntax)" || check_fail "Self-check (syntax) — fix the syntax errors above"
elif [ "$IS_HARNESS_REPO" = "1" ]; then
  check_warn "No scripts/*.sh found — skipping syntax check"
else
  # Client project: no scripts/ dir by design, but that doesn't mean
  # nothing to check — this commit may still touch shell files elsewhere
  # in the project. Syntax-check those instead of claiming a pass for a
  # check that never ran. propagation-ok: real check, not a stub.
  # No `tr ' ' '\n'` here: FILES is already newline-separated (git
  # --name-only), and translating spaces shredded any path containing one —
  # the very case this branch exists to handle (T-I19).
  SH_STAGED=$(echo "${FILES:-}" | grep -E '\.sh$' || true)
  if [ -n "$SH_STAGED" ]; then
    # One file per iteration, quoted: `bash -n $SH_STAGED` word-splits on
    # spaces, and "src/My Component/build.sh" is an ordinary path in a client
    # project — the check would report a missing file instead of a real
    # syntax error (T-I19).
    SH_SYNTAX_OK=1
    while IFS= read -r shf; do
      [ -z "$shf" ] && continue
      bash -n "$shf" 2>&1 || SH_SYNTAX_OK=0
    done <<< "$SH_STAGED"
    # propagation-ok: real check on real files, not a stub pass.
    [ "$SH_SYNTAX_OK" = "1" ] && check_pass "Self-check (syntax on changed shell files)" \
                              || check_fail "Self-check (syntax) — fix the syntax errors above"
  else
    check_warn "Self-check is advisory in this project — verify each change actually works"
  fi
fi
fi

echo ""

# ── Step 8: .agentignore file-level check ───────────────────────────────────
echo "[ 8/8 ] .agentignore file-level check"

AGENTIGNORE_FAIL=0
if [ -f ".agentignore" ] && git rev-parse --is-inside-work-tree &>/dev/null; then
  if [ "${PRE_COMMIT:-0}" = "1" ]; then
    STAGED=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
  else
    STAGED=$(git diff --name-only HEAD~1 2>/dev/null || true)
  fi
  while IFS= read -r pattern; do
    # Skip comments and empty lines
    [[ "$pattern" =~ ^#.*$ || -z "$pattern" ]] && continue
    for f in $STAGED; do
      case "$f" in
        $pattern|$pattern*)
          check_fail ".agentignore: staged file '$f' matches restricted pattern '$pattern'"
          echo "   → This file requires explicit user confirmation before being touched."
          AGENTIGNORE_FAIL=1
          ;;
      esac
    done
  done < ".agentignore"
fi

if [ ! -f ".agentignore" ]; then
  # propagation-ok: honest warn, not a silent pass — the backstop this step
  # provides is inactive, not "nothing to restrict".
  check_warn ".agentignore not present — file-level access backstop is INACTIVE (run update-project to install it)"
elif [ "$AGENTIGNORE_FAIL" -eq 0 ]; then
  check_pass "No staged files match .agentignore restrictions"
fi

echo ""

# ── Upkeep check — is session-end actually being run? ────────────────────────
# Rotation (T-J2) and the memory index (T-J4) are both invoked from
# session-end.sh and from nowhere else. Nothing verified they had ever run,
# so in a project where the user stopped typing `session-end` they simply
# stopped happening — silently, because a mechanism that is never invoked
# reports nothing at all.
#
# Measured 2026-08-21 in a live project: last memory note 2026-08-12, no
# index in MEMORY.md, and PROGRESS.md at 1364 lines — 69% of the session's
# entire starting context. Every piece was built and working; none had run.
#
# Warn, never fail: this is upkeep, and blocking a commit over it would
# punish the wrong moment. Same shape as the .agentignore warning above —
# say what is inactive and name the command that fixes it.
if [ -f "PROGRESS.md" ]; then
  PROGRESS_LINES=$(wc -l < "PROGRESS.md" | tr -d ' ')
  if [ "$PROGRESS_LINES" -gt "${PROGRESS_MAX_LINES:-400}" ]; then
    check_warn "PROGRESS.md is $PROGRESS_LINES lines (threshold ${PROGRESS_MAX_LINES:-400}) — every session reads it in full; run: session-end"
  fi
fi

if [ -d "memory" ] && [ -n "$(ls -A memory 2>/dev/null)" ] && [ -f "MEMORY.md" ]; then
  if ! grep -q "MEMORY-INDEX START" "MEMORY.md" 2>/dev/null; then
    NOTE_COUNT=$(ls -1 memory/*.md 2>/dev/null | wc -l | tr -d ' ')
    check_warn "MEMORY.md has no index — $NOTE_COUNT note(s) in memory/ are unreachable at Session Start; run: session-end"
  fi
fi

echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"

# ── Audit trail (T-F4) — append one line per run, local-only, gitignored.
#    session-end.sh reads today's entries into memory/YYYY-MM-DD.md so
#    there's a record of what DoD actually did this session, not just the
#    commits it let through. MODE distinguishes the automatic pre-commit
#    hook run from a manual `make dod`/direct invocation.
LOG_MODE="manual"
[ "${PRE_COMMIT:-0}" = "1" ] && LOG_MODE="pre-commit"
LOG_RESULT="pass"
[ "$FAIL" -gt 0 ] && LOG_RESULT="fail"
printf '%s|%s|pass=%s|fail=%s|warn=%s|skip=%s|%s\n' \
  "$(date '+%Y-%m-%dT%H:%M:%S')" "$LOG_MODE" "$PASS" "$FAIL" "$WARN" "${DOD_SKIP:-none}" "$LOG_RESULT" \
  >> .dod-run.log 2>/dev/null || true

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