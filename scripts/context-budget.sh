#!/bin/bash
# scripts/context-budget.sh [--project PATH] [--check MAX] [--quiet]
#
# Measures what Session Start costs before the user's first word: every file
# the protocol reads, in characters and estimated tokens.
#
# Why this exists (T-J0, notes/Harness/implementation-plan-2/13-*.md, F1/F2).
# global/AGENTS.md was 436 lines when it was first flagged as too big, then
# 467, then 497, then 517 — while the roadmap target was ~220. Every one of
# those steps looked small from inside the diff. Nothing measured the total,
# so nothing objected. A budget that is never printed is not a budget.
#
# The estimate is deliberately crude and stable rather than exact: ~4 chars
# per token for Latin text and ~2.5 for Cyrillic, which tokenizes far worse.
# The two are counted separately rather than switching the whole file to the
# worse rate on first sight of Cyrillic — the harness's own PROGRESS.md is
# 103k characters of English with 406 Cyrillic ones left over from old
# entries, and the flag-style rule inflated it by 15k tokens. What matters is
# the direction between two runs, not agreement with any particular tokenizer.
set -euo pipefail

cd "$(dirname "$0")/.."
HARNESS_ROOT="$(pwd)"

command -v python3 >/dev/null 2>&1 || {
  echo "✗ python3 is required to measure the context budget." >&2
  exit 1
}

PROJECT=""
CHECK_MAX=""
QUIET=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2:-}"; shift 2 ;;
    --check)   CHECK_MAX="${2:-}"; shift 2 ;;
    --quiet)   QUIET=1; shift ;;
    -h|--help)
      echo "Usage: context-budget.sh [--project PATH] [--check MAX] [--quiet]"
      echo "  --project PATH  measure a client project (default: this harness repo)"
      echo "  --check MAX     exit 1 if the total estimate exceeds MAX tokens"
      echo "  --quiet         print only the TOTAL line"
      exit 0 ;;
    *) echo "✗ unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [ -n "$PROJECT" ]; then
  [ -d "$PROJECT" ] || { echo "✗ not a directory: $PROJECT" >&2; exit 1; }
  PROJECT="$(cd "$PROJECT" && pwd)"
else
  PROJECT="$HARNESS_ROOT"
fi

python3 - "$HARNESS_ROOT" "$PROJECT" "$CHECK_MAX" "$QUIET" <<'PY'
import os
import re
import sys
from datetime import date, timedelta

harness_root, project, check_max, quiet = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "1"
home = os.path.expanduser("~")

# The mirrored copy is what an agent actually reads in a client project; the
# repo copy is what it reads here. Measure whichever is in play, so the number
# describes the session that will really happen.
mirror_agents = os.path.join(home, ".config/opencode/AGENTS.md")
repo_agents = os.path.join(harness_root, "global/AGENTS.md")
is_harness_repo = os.path.abspath(project) == os.path.abspath(harness_root)
global_agents = repo_agents if is_harness_repo or not os.path.exists(mirror_agents) else mirror_agents

mirror_skills = os.path.join(home, ".config/opencode/skills")
repo_skills = os.path.join(harness_root, "global/skills")
skills_root = repo_skills if is_harness_repo or not os.path.isdir(mirror_skills) else mirror_skills

# Source of truth for this list: "## Session Start" in global/AGENTS.md. It is
# spelled out here rather than parsed because the protocol names files in
# prose, with conditions ("if they exist", "for today or yesterday") that a
# regex would get wrong in both directions. The drift check below is what
# keeps the two honest: a new .md named in the protocol and missing here is
# reported, which is the failure mode this whole script exists to prevent.
targets = [
    ("global AGENTS.md", global_agents, "always"),
    ("project AGENTS.md", os.path.join(project, "AGENTS.md"), "always"),
    ("using-agent-skills/SKILL.md", os.path.join(skills_root, "using-agent-skills/SKILL.md"), "step 2"),
    ("docs/skills-cheatsheet.md", os.path.join(project, "docs/skills-cheatsheet.md"), "step 2"),
    ("PROGRESS.md", os.path.join(project, "PROGRESS.md"), "step 3"),
    ("docs/roadmap.md", os.path.join(project, "docs/roadmap.md"), "step 4"),
    ("MEMORY.md", os.path.join(project, "MEMORY.md"), "step 5"),
]

# Step 5 reads today's and yesterday's memory file, if present.
for delta, label in ((0, "today"), (1, "yesterday")):
    day = (date.today() - timedelta(days=delta)).isoformat()
    targets.append((f"memory/{day}.md ({label})", os.path.join(project, "memory", f"{day}.md"), "step 5"))

targets.append(("HARNESS.md", os.path.join(project, "HARNESS.md"), "step 6"))

CYRILLIC = re.compile(r"[Ѐ-ӿ]")


def measure(path):
    if not os.path.isfile(path):
        return None
    with open(path, encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    lines = text.count("\n") + (0 if text.endswith("\n") or not text else 1)
    chars = len(text)
    cyrillic = len(CYRILLIC.findall(text))
    tokens = int((chars - cyrillic) / 4.0 + cyrillic / 2.5)
    return lines, chars, tokens


rows = []
total_tokens = 0
for label, path, when in targets:
    result = measure(path)
    if result is None:
        rows.append((label, when, None))
        continue
    lines, chars, tokens = result
    total_tokens += tokens
    rows.append((label, when, (lines, chars, tokens)))

if not quiet:
    print(f"Context budget — Session Start, project: {project}")
    print(f"  global AGENTS.md read from: {global_agents}")
    print("")
    print(f"{'File':<34}{'When':<9}{'Lines':>7}{'Chars':>9}{'~Tokens':>9}{'% total':>9}")
    print("-" * 77)
    for label, when, data in rows:
        if data is None:
            print(f"{label:<34}{when:<9}{'—':>7}{'—':>9}{'—':>9}{'absent':>9}")
            continue
        lines, chars, tokens = data
        share = (tokens / total_tokens * 100) if total_tokens else 0
        print(f"{label:<34}{when:<9}{lines:>7}{chars:>9}{tokens:>9}{share:>8.1f}%")
    print("-" * 77)

print(f"TOTAL ~{total_tokens} tokens before the first word of the task.")

# Drift check: if the protocol starts naming a file this script does not
# measure, the number silently stops describing reality. Cheap to detect, so
# there is no reason to find out later from a surprise.
protocol_source = repo_agents if os.path.exists(repo_agents) else global_agents
if os.path.exists(protocol_source):
    with open(protocol_source, encoding="utf-8", errors="replace") as fh:
        body = fh.read()
    section = re.search(r"^## Session Start$(.*?)^## ", body, re.M | re.S)
    if section:
        named = set(re.findall(r"[A-Za-z0-9_./-]*\.md", section.group(1)))
        known = {os.path.basename(p) for _, p, _ in targets}
        known |= {"docs/roadmap.md", "docs/skills-cheatsheet.md", "memory/YYYY-MM-DD.md"}
        # AGENTS.md is named in several forms; SKILL.md paths belong to step 2;
        # directus-mcp-setup.md appears inside a warning the agent prints to the
        # user, not as something it reads.
        ignore = {"AGENTS.md", "SKILL.md", "startup/SKILL.md",
                  "using-agent-skills/SKILL.md", "opencode.jsonc",
                  "directus-mcp-setup.md"}
        known_lower = {k.lower() for k in known}
        unknown = sorted(n for n in named
                         if n.lower() not in known_lower
                         and os.path.basename(n).lower() not in known_lower
                         and os.path.basename(n) not in ignore
                         and n not in ignore)
        if unknown:
            print("")
            print("⚠ Session Start names files this script does not measure:", ", ".join(unknown))
            print("  Add them to `targets` in scripts/context-budget.sh, or the total is wrong.")

if check_max:
    try:
        limit = int(check_max)
    except ValueError:
        print(f"✗ --check expects an integer, got: {check_max}", file=sys.stderr)
        sys.exit(2)
    if total_tokens > limit:
        print(f"✗ context budget {total_tokens} exceeds the limit of {limit} tokens.", file=sys.stderr)
        sys.exit(1)
    print(f"✓ within the {limit}-token budget.")
PY
