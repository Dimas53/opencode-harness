#!/bin/bash
# scripts/gen-rules.sh
# T-F1 (implementation-plan-2 Wave F, F-DEC-1 = markdown-only): checks
# global/AGENTS.md ## Definition of Done and global/skills/dod/SKILL.md
# against the canonical step list in global/rules/dod.yaml — single
# source of truth for step COUNT, ORDER, and IDENTITY (title first word).
#
# This supersedes scripts/check-dod-sync.sh's cross-file comparison: that
# script only checked the two markdown files against EACH OTHER, so both
# could drift together (e.g. both silently renumbered, or a step deleted
# from both) without ever failing. This checks both against dod.yaml,
# which encodes what the 9 steps actually are.
#
# Does NOT generate file content — AGENTS.md's terse list and SKILL.md's
# elaborated checklists are genuinely different content by design, not a
# duplicate to regenerate. Does NOT touch dod.sh (bash-from-yaml is
# higher-risk, explicitly deferred — see F-DEC-1 in
# notes/Harness/implementation-plan-2/06-open-decisions.md).
#
# Usage: bash scripts/gen-rules.sh --check   (only supported mode so far)
set -euo pipefail

MODE="${1:---check}"
if [ "$MODE" != "--check" ]; then
  echo "✗ Only --check is implemented (no dod.sh/prose generation — see header)" >&2
  exit 1
fi

RULES_FILE="global/rules/dod.yaml"
AGENTS_FILE="global/AGENTS.md"
SKILL_FILE="global/skills/dod/SKILL.md"

for f in "$RULES_FILE" "$AGENTS_FILE" "$SKILL_FILE"; do
  [ -f "$f" ] || { echo "✗ $f not found"; exit 1; }
done

# ── Parse dod.yaml's fixed 4-line-per-step shape (no real YAML lib —
#    pyyaml isn't installed in this environment). One "order|first_word"
#    pair per line, sorted by order (grep -A/-B on a strict per-step block).
canonical=$(awk '
  /^  - id:/ { order=""; word="" }
  /^    order:/ { order=$2 }
  /^    first_word:/ {
    word=$0
    sub(/^    first_word: "/, "", word)
    sub(/".*$/, "", word)
    print order "|" word
  }
' "$RULES_FILE" | sort -n -t'|' -k1,1)

canonical_count=$(echo "$canonical" | grep -c . || true)

# ── Extract (order|first_word) from AGENTS.md: "5. **Commit Gate:** ..."
#    inside the ## Definition of Done section only.
agents_pairs=$(awk '/^## Definition of Done/{flag=1; next} /^## /{flag=0} flag' "$AGENTS_FILE" \
  | grep -oE '^[0-9]+\. \*\*[^*]+\*\*' \
  | sed -E 's/^([0-9]+)\. \*\*([^*]+)\*\*/\1|\2/' \
  | awk -F'|' '{split($2,w," "); word=w[1]; sub(/:$/,"",word); print $1"|"word}')

# ── Extract (order|first_word) from dod/SKILL.md: "### STEP 5 — Commit Gate".
#    Truncate at "## Checklist format" — that section reuses "### STEP 1"
#    as a formatting EXAMPLE, not a real step (same exclusion as T1.3).
skill_pairs=$(awk '/^## Checklist format/{exit} {print}' "$SKILL_FILE" \
  | grep -oE '^### STEP [0-9]+ — .+$' \
  | sed -E 's/^### STEP ([0-9]+) — (.+)$/\1|\2/' \
  | awk -F'|' '{split($2,w," "); word=w[1]; sub(/:$/,"",word); print $1"|"word}')

agents_count=$(echo "$agents_pairs" | grep -c . || true)
skill_count=$(echo "$skill_pairs" | grep -c . || true)

fail=0

if [ "$agents_count" != "$canonical_count" ]; then
  echo "✗ AGENTS.md has $agents_count DoD steps, dod.yaml declares $canonical_count"
  fail=1
fi
if [ "$skill_count" != "$canonical_count" ]; then
  echo "✗ dod/SKILL.md has $skill_count DoD steps, dod.yaml declares $canonical_count"
  fail=1
fi

if [ "$fail" = "0" ]; then
  i=1
  while [ "$i" -le "$canonical_count" ]; do
    c_word=$(echo "$canonical" | sed -n "${i}p" | cut -d'|' -f2)
    a_word=$(echo "$agents_pairs" | sed -n "${i}p" | cut -d'|' -f2)
    s_word=$(echo "$skill_pairs" | sed -n "${i}p" | cut -d'|' -f2)
    if [ "$a_word" != "$c_word" ]; then
      echo "✗ AGENTS.md step $i first word \"$a_word\" != dod.yaml \"$c_word\""
      fail=1
    fi
    if [ "$s_word" != "$c_word" ]; then
      echo "✗ dod/SKILL.md step $i first word \"$s_word\" != dod.yaml \"$c_word\""
      fail=1
    fi
    i=$((i + 1))
  done
fi

if [ "$fail" = "1" ]; then
  exit 1
fi

echo "✓ DoD sync OK — $canonical_count steps match dod.yaml, AGENTS.md, and dod/SKILL.md"
exit 0
