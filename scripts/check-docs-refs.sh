#!/bin/bash
# scripts/check-docs-refs.sh
# Mechanical backstop for T-A5 (implementation-plan-2 Wave A): checks that
# instructions/reference/03-skills-cheatsheet.md and
# templates/docs/skills-cheatsheet.md don't advertise a harness skill that
# doesn't exist in global/skills/. A1-A4 fixed the drift by hand; this stops
# it from silently recurring (check-dod-sync.sh only guards the AGENTS.md /
# dod/SKILL.md pair, not these reference docs).
#
# Deliberately conservative: it is a checker, not a generator, and it would
# rather skip an ambiguous line than false-fail on legitimate content (e.g.
# skill names appearing in prose, or an explicitly external/find-skills
# entry). It only flags names presented in a "here's a vendored harness
# skill" table row.
set -euo pipefail

cd "$(dirname "$0")/.."

FAIL=0

# Skills that are legitimately NOT in global/skills/ — installed on demand
# via the find-skills ecosystem, and already labeled as such wherever they
# appear. Keep in sync with instructions/reference/05-skills-inventory.md
# section 1.
EXTERNAL_ALLOWLIST="find-skills prototype setup-matt-pocock-skills teach triage write-a-skill"

is_external() {
  local name="$1"
  for ext in $EXTERNAL_ALLOWLIST; do
    [ "$name" = "$ext" ] && return 0
  done
  return 1
}

check_cheatsheet() {
  local file="$1"
  [ -f "$file" ] || return 0

  # Match table rows of the form: | `skill-name` | ...
  # (the only backtick-quoted-first-column format both cheatsheet files use
  # for skill names).
  local lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    local name
    name=$(echo "$line" | grep -oE '^\| `[a-zA-Z0-9._-]+`' | sed -E 's/^\| `//; s/`$//') || true
    [ -z "$name" ] && continue

    is_external "$name" && continue

    if [ ! -d "global/skills/$name" ]; then
      echo "✗ $file:$lineno — references skill '$name', not found in global/skills/" >&2
      FAIL=1
    fi
  done < "$file"
}

check_cheatsheet "instructions/reference/03-skills-cheatsheet.md"
check_cheatsheet "templates/docs/skills-cheatsheet.md"

# The inventory is checked section by section, not whole-file: section 4 is a
# table of MCP servers (`context7`, `fetch`, `sequential-thinking`) in the
# same backtick-first-column format, and reading those as missing skills is
# the false positive that made the ticket's own hand-run `comm` report ten
# phantoms where there was one.
check_inventory_section_1a() {
  local file="$1"
  [ -f "$file" ] || return 0
  local section
  section=$(sed -n '/^### 1a\./,/^### 1b\./p' "$file")
  [ -n "$section" ] || {
    echo "✗ $file — section '### 1a.' not found; the completeness check cannot run." >&2
    FAIL=1
    return 0
  }
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    is_external "$name" && continue
    [ -d "global/skills/$name" ] || {
      echo "✗ $file — section 1a lists skill '$name', not found in global/skills/" >&2
      FAIL=1
    }
  done < <(echo "$section" | grep -oE '^\| `[a-zA-Z0-9._-]+`' | sed -E 's/^\| `//; s/`$//')
}

check_inventory_section_1a "instructions/reference/05-skills-inventory.md"

# ── Rule 2: the inventory must be COMPLETE, not just free of phantoms ───────
# Cheatsheets are selective by design — the inventory is not, and that is the
# whole point of it. T-A3 fixed this file by hand in Wave A; by the next audit
# it was missing 15 of the skills on disk and still advertised one that had
# been deleted. A checker that only looks for phantoms cannot catch that, so
# this one walks the other direction too (T-I6).
INVENTORY="instructions/reference/05-skills-inventory.md"

if [ -f "$INVENTORY" ]; then
  INV_1A=$(sed -n '/^### 1a\./,/^### 1b\./p' "$INVENTORY")
  while IFS= read -r dir; do
    name=$(basename "$dir")
    echo "$INV_1A" | grep -qE "^\| \`$name\`" || {
      echo "✗ $INVENTORY — global/skills/$name/ exists but is not listed. The inventory must list every skill on disk." >&2
      FAIL=1
    }
  done < <(find global/skills -mindepth 1 -maxdepth 1 -type d)
fi

# ── Rule 3: no client literals in reference docs or delivered templates ────
# T-B5 de-identified global/skills/security/, but nothing stopped the same
# names from reappearing elsewhere — and the inventory still carried
# "custom (ItoCook)" long after. A specific client's name in a doc shipped to
# every other project is a leak of one engagement into another (T-I6).
CLIENT_LITERALS="itocook|itouser|duckdns"

while IFS= read -r hit; do
  echo "✗ $hit" >&2
  echo "  ^ client-specific literal in a doc delivered to every project — use a neutral placeholder." >&2
  FAIL=1
done < <(grep -rniE "$CLIENT_LITERALS" instructions/reference/ templates/ 2>/dev/null || true)

# ── Rule 4: no Cyrillic or client literals anywhere under global/skills/ ───
# The mirror copies the working tree, not git — so a git-ignored subdirectory
# of a vendored skill reaches ~/.config/opencode/skills/ and is read by the
# model, while every past scan (which walked *.md only) stayed blind to it.
# That is how 46 lines of Russian text in an HTML file sat inside the live
# config unnoticed (T-I13). All extensions, not just markdown.
#
# grep -E with a Cyrillic class, never grep -P: BSD grep on macOS has no -P
# and exits with a usage error, which reads as "no matches" — a check that
# silently passes is worse than no check.
SKILL_TEXT_EXCLUDE='session-end|harness-init|/notes/'

while IFS= read -r f; do
  echo "✗ $f — Cyrillic text inside global/skills/ (mirrored into the live config and read by the model)." >&2
  FAIL=1
done < <(grep -rlE '[а-яА-ЯёЁ]' global/skills/ 2>/dev/null | grep -vE "$SKILL_TEXT_EXCLUDE" || true)

while IFS= read -r hit; do
  case "$hit" in
    *harness-init/SKILL.md*) continue ;;  # the rule that says "don't copy client terms"
  esac
  echo "✗ $hit" >&2
  echo "  ^ client-specific literal inside global/skills/ — it ships to every project." >&2
  FAIL=1
done < <(grep -rniE "$CLIENT_LITERALS" global/skills/ 2>/dev/null || true)

if [ "$FAIL" = "1" ]; then
  echo "" >&2
  echo "Phantom skill reference(s) found above. Either the skill folder is" >&2
  echo "missing (add it or fix the name), or it's a legitimate external" >&2
  echo "skill that needs adding to EXTERNAL_ALLOWLIST in this script." >&2
  exit 1
fi

echo "✓ check-docs-refs: no phantom skill references found"
