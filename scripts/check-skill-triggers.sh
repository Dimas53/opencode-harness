#!/bin/bash
# scripts/check-skill-triggers.sh [--file global/AGENTS.md]
#
# Fails if one trigger word routes to more than one domain in the Skills
# Auto-Loading table.
#
# Why (T-J5, F3). The table is the harness's skill router, and AGENTS.md is
# honest that nothing automates it: the model must scan every incoming message
# against it by hand. The problem measured here is worse than discipline —
# `refactor` appeared in three rows and eleven other words in two, with no rule
# for choosing. The standing instruction ("multiple matches → load all of them")
# then turns one word into three SKILL.md reads, so a model following the rule
# correctly spends MORE context than one that half-ignores it. A rule that
# punishes correct execution cannot be fixed by asking for more discipline; the
# data has to stop being ambiguous.
#
# This checker is what keeps it unambiguous after the fix — the table is edited
# by hand every time a skill is added, and nothing else would notice a new
# collision.
set -euo pipefail

cd "$(dirname "$0")/.."

command -v python3 >/dev/null 2>&1 || {
  echo "✗ python3 is required to check skill triggers." >&2
  exit 1
}

FILE="global/AGENTS.md"
[ "${1:-}" = "--file" ] && FILE="${2:-}"

python3 - "$FILE" <<'PY'
import collections
import sys

path = sys.argv[1]

with open(path, encoding="utf-8") as fh:
    lines = fh.read().split("\n")

rows = [l for l in lines if l.startswith("|") and "SKILL.md" in l]
if not rows:
    print(f"✗ {path}: no Auto-Loading rows found — has the table moved?", file=sys.stderr)
    sys.exit(1)

triggers = collections.defaultdict(list)
for row in rows:
    cells = [c.strip() for c in row.strip("|").split("|")]
    if len(cells) < 3:
        continue
    domain, trigger_cell = cells[0], cells[1]
    for trigger in trigger_cell.split(","):
        trigger = trigger.strip().strip("`").lower()
        if trigger:
            triggers[trigger].append(domain)

conflicts = {t: d for t, d in triggers.items() if len(d) > 1}

if conflicts:
    print(f"✗ {path}: {len(conflicts)} trigger(s) route to more than one domain.", file=sys.stderr)
    for trigger, domains in sorted(conflicts.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        print(f"    {len(domains)}x  {trigger!r} → {', '.join(domains)}", file=sys.stderr)
    print("", file=sys.stderr)
    print("  Give each word one home. If two domains genuinely need the same", file=sys.stderr)
    print("  concept, make one of them more specific ('deploy' vs 'deploy secrets')", file=sys.stderr)
    print("  rather than leaving the choice to the model at read time.", file=sys.stderr)
    sys.exit(1)

print(f"✓ check-skill-triggers: {len(triggers)} triggers across {len(rows)} rows, no collisions")
PY
