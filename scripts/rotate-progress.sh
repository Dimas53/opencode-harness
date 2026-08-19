#!/bin/bash
# scripts/rotate-progress.sh [--file PATH] [--max-lines N] [--keep N] [--dry-run]
#
# Moves old session entries out of PROGRESS.md into docs/progress-archive/,
# keeping the most recent ones in place.
#
# Why (T-J2, F5). PROGRESS.md is read in full at Session Start, every session,
# and it never shrinks: 1,831 lines here and 212,691 characters in a live
# client project — ~70% of the whole cold-start context budget in both, as
# measured by scripts/context-budget.sh. It is the one defect that gets worse
# with no change to any code: every session makes the next one more expensive.
# What the next session actually needs is the last few entries; the rest is
# history, valuable to a person and dead weight to a cold start.
#
# Section detection is by DATE IN THE HEADING, not by a fixed template. Three
# spellings are already live in the wild and a rule tied to one of them would
# quietly rotate nothing in the other two:
#   templates/PROGRESS.md   ### 2026-08-19
#   this repo               ## Session 2026-08-07 (report audit)
#   a client project        ## Current session — WAF unblocked (2026-08-14)
#
# Everything above the first dated heading is the file's header — title,
# `Chat language:`, Current Status, Known Issues, Next Session — and is never
# archived. `Chat language:` in particular is read by Session Start step 3;
# archiving it would silently change how the agent talks.
set -euo pipefail

command -v python3 >/dev/null 2>&1 || {
  echo "✗ python3 is required to rotate PROGRESS.md." >&2
  exit 1
}

FILE="PROGRESS.md"
MAX_LINES="${PROGRESS_MAX_LINES:-400}"
KEEP="${PROGRESS_KEEP_SESSIONS:-10}"
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --file)      FILE="${2:-}"; shift 2 ;;
    --max-lines) MAX_LINES="${2:-}"; shift 2 ;;
    --keep)      KEEP="${2:-}"; shift 2 ;;
    --dry-run)   DRY_RUN=1; shift ;;
    -h|--help)
      echo "Usage: rotate-progress.sh [--file PATH] [--max-lines N] [--keep N] [--dry-run]"
      echo "  Env: PROGRESS_MAX_LINES (default 400), PROGRESS_KEEP_SESSIONS (default 10)"
      exit 0 ;;
    *) echo "✗ unknown argument: $1" >&2; exit 1 ;;
  esac
done

python3 - "$FILE" "$MAX_LINES" "$KEEP" "$DRY_RUN" <<'PY'
import os
import re
import sys

path, max_lines, keep, dry_run = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4] == "1"

if not os.path.isfile(path):
    print(f"  · {path} not found — nothing to rotate")
    sys.exit(0)

with open(path, encoding="utf-8") as fh:
    lines = fh.read().split("\n")

if len(lines) <= max_lines:
    print(f"  ✓ {path}: {len(lines)} lines, under the {max_lines}-line threshold")
    sys.exit(0)

DATE = re.compile(r"(\d{4})-(\d{2})-\d{2}")
HEADING = re.compile(r"^#{2,3} ")

starts = [i for i, line in enumerate(lines) if HEADING.match(line) and DATE.search(line)]

if not starts:
    print(f"  ⚠ {path}: {len(lines)} lines but no dated session headings found.")
    print("    Rotation needs '## ' or '### ' headings containing a YYYY-MM-DD date.")
    print("    Nothing moved — a file this script cannot parse is one it must not rewrite.")
    sys.exit(0)

# Below this, there is nothing to gain and continuity to lose: a log holding
# two entries no longer answers "what happened recently".
MIN_SESSIONS = 3

if len(starts) <= MIN_SESSIONS:
    print(f"  ⚠ {path}: {len(lines)} lines over threshold, but only {len(starts)} "
          f"session section(s) — keeping all.")
    sys.exit(0)

header = lines[: starts[0]]
sections = []
for idx, start in enumerate(starts):
    end = starts[idx + 1] if idx + 1 < len(starts) else len(lines)
    sections.append(lines[start:end])

# Newest first is the convention in every PROGRESS.md seen so far, so the ones
# to keep are at the top. If a file were ever written oldest-first this would
# archive the wrong end — hence the check below rather than a silent guess.
first_date = DATE.search(sections[0][0])
last_date = DATE.search(sections[-1][0])
if first_date and last_date and first_date.group(0) < last_date.group(0):
    print(f"  ⚠ {path}: sections run oldest-first, which this script does not handle.")
    print("    Nothing moved — rotating the wrong end would delete recent history.")
    sys.exit(0)

# `keep` is a ceiling, not a target. Keeping 10 sessions of this repo's own
# PROGRESS.md still left 840 lines against a 400-line threshold — sessions are
# not the same size, so a fixed count cannot honour a line budget. Trim further
# until the threshold is met, never below MIN_SESSIONS.
keep = min(keep, len(sections))
header_len = starts[0]
while keep > MIN_SESSIONS:
    projected = header_len + sum(len(s) for s in sections[:keep])
    if projected <= max_lines:
        break
    keep -= 1

kept, archived = sections[:keep], sections[keep:]

by_month = {}
for section in archived:
    match = DATE.search(section[0])
    month = f"{match.group(1)}-{match.group(2)}" if match else "undated"
    by_month.setdefault(month, []).append(section)

archive_dir = os.path.join(os.path.dirname(os.path.abspath(path)), "docs", "progress-archive")

if dry_run:
    print(f"  · dry run — would archive {len(archived)} section(s) from {path}:")
    for month, sections_in_month in sorted(by_month.items()):
        print(f"      {month}.md  ← {len(sections_in_month)} section(s)")
    print(f"    {path} would keep the header plus {len(kept)} most recent section(s)")
    sys.exit(0)

os.makedirs(archive_dir, exist_ok=True)

for month, sections_in_month in sorted(by_month.items()):
    target = os.path.join(archive_dir, f"{month}.md")
    exists = os.path.isfile(target)
    with open(target, "a", encoding="utf-8") as fh:
        if not exists:
            fh.write(f"# Progress archive — {month}\n\n")
            fh.write("Moved out of PROGRESS.md by scripts/rotate-progress.sh so that\n")
            fh.write("Session Start stays cheap. Append-only: nothing here is rewritten.\n\n")
        for section in sections_in_month:
            fh.write("\n".join(section).rstrip("\n") + "\n\n")
    print(f"  ✓ archived {len(sections_in_month)} section(s) → docs/progress-archive/{month}.md")

pointer = "> Older sessions: [docs/progress-archive/](docs/progress-archive/)"
header = [line for line in header if not line.startswith("> Older sessions:")]

# The pointer goes after the title so it is visible immediately, but never
# before it — a file whose first line is not its heading reads as broken.
insert_at = 1 if header and header[0].startswith("# ") else 0
header = header[:insert_at] + ["", pointer] + header[insert_at:]
while len(header) > 1 and header[-1].strip() == "":
    header.pop()

new_lines = header + [""] + [line for section in kept for line in section]

# Preserve mtime: session-end.sh checks "was PROGRESS.md updated today", and
# rotation is bookkeeping, not an update. Touching the timestamp here would
# make that check pass on a day nobody wrote anything — the check would go
# green precisely when it should complain.
stat = os.stat(path)
with open(path, "w", encoding="utf-8") as fh:
    fh.write("\n".join(new_lines).rstrip("\n") + "\n")
os.utime(path, (stat.st_atime, stat.st_mtime))

with open(path, encoding="utf-8") as fh:
    now = fh.read().count("\n") + 1
print(f"  ✓ {path}: {len(lines)} → {now} lines, {len(kept)} recent session(s) kept")
PY
