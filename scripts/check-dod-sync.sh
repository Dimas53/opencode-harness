#!/bin/bash
# scripts/check-dod-sync.sh
# Verifies global/AGENTS.md ## Definition of Done and
# global/skills/dod/SKILL.md stay in sync (same step count, same order).
# Exits 1 with a diff if they diverge. Run via: make check-docs-sync
set -euo pipefail

AGENTS_FILE="global/AGENTS.md"
SKILL_FILE="global/skills/dod/SKILL.md"

# Extract step titles from AGENTS.md: lines like "5. **Commit Gate:** ..."
# inside the ## Definition of Done section only (stop at next "## " heading).
agents_steps=$(awk '/^## Definition of Done/{flag=1; next} /^## /{flag=0} flag' "$AGENTS_FILE" \
  | grep -oE '^[0-9]+\. \*\*[^*]+\*\*' \
  | sed -E 's/^([0-9]+)\. \*\*([^*]+)\*\*/\1|\2/')

# Extract step titles from dod/SKILL.md: lines like "### STEP 5 — Commit Gate".
# Truncate at "## Checklist format" first — that section deliberately reuses
# "### STEP 1"/"### STEP 2" as a formatting EXAMPLE, not a real step, and
# would otherwise inflate the count (see implementation-plan T1.1 verify notes).
skill_steps=$(awk '/^## Checklist format/{exit} {print}' "$SKILL_FILE" \
  | grep -oE '^### STEP [0-9]+ — .+$' \
  | sed -E 's/^### STEP ([0-9]+) — (.+)$/\1|\2/')

agents_count=$(echo "$agents_steps" | grep -c . || true)
skill_count=$(echo "$skill_steps" | grep -c . || true)

if [ "$agents_count" != "$skill_count" ]; then
  echo "✗ DoD step count mismatch: AGENTS.md has $agents_count, dod/SKILL.md has $skill_count"
  echo "--- AGENTS.md steps ---"
  echo "$agents_steps"
  echo "--- dod/SKILL.md steps ---"
  echo "$skill_steps"
  exit 1
fi

mismatch=0
i=1
while [ "$i" -le "$agents_count" ]; do
  a_title=$(echo "$agents_steps" | sed -n "${i}p" | cut -d'|' -f2)
  s_title=$(echo "$skill_steps" | sed -n "${i}p" | cut -d'|' -f2)
  # Loose match: skill title should start with the same first word as agents title.
  # Strip a trailing colon: single-word AGENTS.md titles like "**JSDoc:**" carry
  # the colon into the first (and only) word, but SKILL.md headers never have one.
  a_word=$(echo "$a_title" | awk '{print $1}' | sed 's/:$//')
  s_word=$(echo "$s_title" | awk '{print $1}' | sed 's/:$//')
  if [ "$a_word" != "$s_word" ]; then
    echo "✗ Step $i title mismatch: AGENTS.md=\"$a_title\" vs dod/SKILL.md=\"$s_title\""
    mismatch=1
  fi
  i=$((i + 1))
done

if [ "$mismatch" = "1" ]; then
  exit 1
fi

echo "✓ DoD sync OK — $agents_count steps match between AGENTS.md and dod/SKILL.md"
exit 0
