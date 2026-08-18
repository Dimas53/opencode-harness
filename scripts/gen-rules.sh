#!/bin/bash
# scripts/gen-rules.sh
# T-F1 (implementation-plan-2 Wave F, F-DEC-1 = markdown-only), extended by
# T-I7: checks the harness protocol step lists in markdown against the
# canonical list in global/rules/protocols.yaml — single source of truth for
# step COUNT, ORDER, and IDENTITY (title first word).
#
#   dod           -> global/AGENTS.md "## Definition of Done"
#                    global/skills/dod/SKILL.md      ("### STEP n — Title")
#   session-start -> global/AGENTS.md "## Session Start"
#                    global/skills/startup/SKILL.md  ("### Step n — Title")
#
# This supersedes scripts/check-dod-sync.sh's original cross-file comparison:
# that only checked two markdown files against EACH OTHER, so both could drift
# together (silently renumbered, or a step deleted from both) without failing.
#
# Why Session Start joined: it had a canon in AGENTS.md and no checker, and
# drifted exactly the way DoD had — startup/SKILL.md announced a "Full 12-Step
# Ritual" describing a different protocol, not a longer version of the same
# one. The class was known and closed for DoD; the fix was never generalized
# (T-I7).
#
# Does NOT generate file content — the terse operational list in AGENTS.md and
# the rationale in each SKILL.md are different content by design, not a
# duplicate to regenerate. Does NOT touch dod.sh (bash-from-yaml is
# higher-risk, explicitly deferred — F-DEC-1 in
# notes/Harness/implementation-plan-2/06-open-decisions.md).
#
# Usage: bash scripts/gen-rules.sh --check   (only supported mode so far)
set -euo pipefail

MODE="${1:---check}"
if [ "$MODE" != "--check" ]; then
  echo "✗ Only --check is implemented (no dod.sh/prose generation — see header)" >&2
  exit 1
fi

RULES_FILE="global/rules/protocols.yaml"
AGENTS_FILE="global/AGENTS.md"
DOD_SKILL="global/skills/dod/SKILL.md"
STARTUP_SKILL="global/skills/startup/SKILL.md"

for f in "$RULES_FILE" "$AGENTS_FILE" "$DOD_SKILL" "$STARTUP_SKILL"; do
  [ -f "$f" ] || { echo "✗ $f not found"; exit 1; }
done

fail=0

# ── Canonical list for one protocol: "order|first_word" per line ───────────
# Parses the fixed 5-line-per-step shape (no real YAML lib available here).
canonical_for() {
  awk -v want="$1" '
    /^  - id:/           { proto=""; order=""; word="" }
    /^    protocol:/     { proto=$2 }
    /^    order:/        { order=$2 }
    /^    first_word:/   {
      word=$0
      sub(/^    first_word: "/, "", word)
      sub(/".*$/, "", word)
      if (proto == want) print order "|" word
    }
  ' "$RULES_FILE" | sort -n -t'|' -k1,1
}

# ── Steps as written in an AGENTS.md section: "5. **Commit Gate:** ..." ────
agents_section_pairs() {
  awk -v section="$1" '
    $0 == section { flag=1; next }
    /^## / { flag=0 }
    flag
  ' "$AGENTS_FILE" \
    | grep -oE '^[0-9]+\. \*\*[^*]+\*\*' \
    | sed -E 's/^([0-9]+)\. \*\*([^*]+)\*\*/\1|\2/' \
    | awk -F'|' '{split($2,w," "); word=w[1]; sub(/:$/,"",word); print $1"|"word}'
}

# ── Steps as written in a SKILL.md: "### STEP 5 — Commit Gate" ─────────────
# Case-insensitive on the STEP/Step keyword: the two skills capitalize it
# differently, and that is cosmetic, not a protocol difference.
skill_pairs() {
  local file="$1" stop_at="$2"
  awk -v stop="$stop_at" '
    stop != "" && $0 ~ stop { exit }
    { print }
  ' "$file" \
    | grep -oiE '^### STEP [0-9]+ — .+$' \
    | sed -E 's/^### [Ss][Tt][Ee][Pp] ([0-9]+) — (.+)$/\1|\2/' \
    | awk -F'|' '{split($2,w," "); word=w[1]; sub(/:$/,"",word); print $1"|"word}'
}

count_lines() { echo "$1" | grep -c . || true; }

# ── Compare one protocol across canon + two markdown files ────────────────
check_protocol() {
  local proto="$1" label="$2" canonical="$3" a_pairs="$4" s_pairs="$5" s_file="$6"
  local c_count a_count s_count
  c_count=$(count_lines "$canonical")
  a_count=$(count_lines "$a_pairs")
  s_count=$(count_lines "$s_pairs")

  if [ "$c_count" = "0" ]; then
    echo "✗ protocols.yaml declares no steps for protocol '$proto'"
    fail=1
    return
  fi

  local local_fail=0
  if [ "$a_count" != "$c_count" ]; then
    echo "✗ $AGENTS_FILE has $a_count $label steps, protocols.yaml declares $c_count"
    fail=1; local_fail=1
  fi
  if [ "$s_count" != "$c_count" ]; then
    echo "✗ $s_file has $s_count $label steps, protocols.yaml declares $c_count"
    fail=1; local_fail=1
  fi
  [ "$local_fail" = "1" ] && return

  local i=1 c_word a_word s_word
  while [ "$i" -le "$c_count" ]; do
    c_word=$(echo "$canonical" | sed -n "${i}p" | cut -d'|' -f2)
    a_word=$(echo "$a_pairs"   | sed -n "${i}p" | cut -d'|' -f2)
    s_word=$(echo "$s_pairs"   | sed -n "${i}p" | cut -d'|' -f2)
    if [ "$a_word" != "$c_word" ]; then
      echo "✗ $AGENTS_FILE $label step $i first word \"$a_word\" != protocols.yaml \"$c_word\""
      fail=1
    fi
    if [ "$s_word" != "$c_word" ]; then
      echo "✗ $s_file $label step $i first word \"$s_word\" != protocols.yaml \"$c_word\""
      fail=1
    fi
    i=$((i + 1))
  done
}

# DoD: dod/SKILL.md's "## Checklist format" section reuses "### STEP 1" as a
# formatting EXAMPLE, not a real step — truncate there (same exclusion T1.3
# made).
check_protocol "dod" "DoD" \
  "$(canonical_for dod)" \
  "$(agents_section_pairs '## Definition of Done')" \
  "$(skill_pairs "$DOD_SKILL" '^## Checklist format')" \
  "$DOD_SKILL"

check_protocol "session-start" "Session Start" \
  "$(canonical_for session-start)" \
  "$(agents_section_pairs '## Session Start')" \
  "$(skill_pairs "$STARTUP_SKILL" '')" \
  "$STARTUP_SKILL"

[ "$fail" = "1" ] && exit 1

echo "✓ DoD sync OK — $(count_lines "$(canonical_for dod)") steps match protocols.yaml, AGENTS.md, and dod/SKILL.md"
echo "✓ Session Start sync OK — $(count_lines "$(canonical_for session-start)") steps match protocols.yaml, AGENTS.md, and startup/SKILL.md"
exit 0
