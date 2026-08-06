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

if [ "$FAIL" = "1" ]; then
  echo "" >&2
  echo "Phantom skill reference(s) found above. Either the skill folder is" >&2
  echo "missing (add it or fix the name), or it's a legitimate external" >&2
  echo "skill that needs adding to EXTERNAL_ALLOWLIST in this script." >&2
  exit 1
fi

echo "✓ check-docs-refs: no phantom skill references found"
