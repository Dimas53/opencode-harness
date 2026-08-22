# tests/rotate-progress.bats — T-J2
#
# PROGRESS.md is read in full at every Session Start and never shrinks — ~70%
# of the cold-start context budget in both this repo and a live client project.
# Rotation is the fix, but a script that rewrites the one file holding a
# project's continuity has to be provably conservative: these tests exist for
# what it must NOT do (lose a line, archive the header, touch mtime, guess at a
# format it does not recognise) at least as much as for what it must.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  SCRATCH="$(mktemp -d)"
  export SCRATCH
  cd "$SCRATCH" || return 1
}

teardown() {
  cd "$HARNESS_ROOT" || true
  rm -rf "$SCRATCH"
}

# Newest first, the convention every live PROGRESS.md follows.
make_progress() {
  local sessions="${1:-30}" fmt="${2:-## Session }"
  python3 - "$sessions" "$fmt" <<'PY' > PROGRESS.md
import sys
from datetime import date, timedelta

count, fmt = int(sys.argv[1]), sys.argv[2]
print("# Progress Log")
print()
print("Chat language: Russian")
print()
print("## Current Status")
print("Phase: testing")
print()
day = date(2026, 8, 19)
for i in range(count):
    print(f"{fmt}{day - timedelta(days=i)} (session {count - i})")
    print(f"- Done: work item {count - i}")
    print("- Next: something")
    print()
PY
}

@test "a short PROGRESS.md is left alone" {
  make_progress 3
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"under the"*"threshold"* ]]
  [ ! -d docs/progress-archive ]
}

@test "a long PROGRESS.md is rotated down to the kept sessions" {
  make_progress 120
  before="$(wc -l < PROGRESS.md)"
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  [ "$status" -eq 0 ]
  after="$(wc -l < PROGRESS.md)"
  [ "$after" -lt "$before" ]
  [ -d docs/progress-archive ]
  [ "$(grep -c '^## Session' PROGRESS.md)" -eq 10 ]
}

# The single most important property: rotation moves text, never drops it.
@test "no non-empty line is lost between PROGRESS.md and the archive" {
  make_progress 120
  cp PROGRESS.md original.md
  bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  run python3 - <<'PY'
import collections, glob
orig = [l for l in open("original.md").read().split("\n") if l.strip()]
kept = open("PROGRESS.md").read().split("\n")
arch = []
for f in glob.glob("docs/progress-archive/*.md"):
    arch += open(f).read().split("\n")
have = collections.Counter(l for l in kept + arch if l.strip())
missing = sum(v - have[k] for k, v in collections.Counter(orig).items() if have[k] < v)
print(missing)
PY
  [ "$output" = "0" ]
}

@test "the header and Chat language stay in PROGRESS.md" {
  make_progress 120
  bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  grep -q "^# Progress Log" PROGRESS.md
  grep -q "^Chat language: Russian" PROGRESS.md
  grep -q "^## Current Status" PROGRESS.md
  grep -q "progress-archive" PROGRESS.md
}

# session-end.sh step 2 asks "was PROGRESS.md updated today". Rotation is
# bookkeeping; if it moved the timestamp, that check would pass on a day
# nobody wrote anything.
@test "rotation preserves mtime" {
  make_progress 120
  touch -t 202601010101 PROGRESS.md
  before="$(python3 -c "import os;print(int(os.stat('PROGRESS.md').st_mtime))")"
  bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  after="$(python3 -c "import os;print(int(os.stat('PROGRESS.md').st_mtime))")"
  [ "$before" = "$after" ]
}

@test "rotation is idempotent — a second run archives nothing new" {
  make_progress 120
  bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  cp PROGRESS.md after-first.md
  first_archive="$(cat docs/progress-archive/*.md | wc -l)"
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  [ "$status" -eq 0 ]
  diff after-first.md PROGRESS.md
  [ "$(cat docs/progress-archive/*.md | wc -l)" -eq "$first_archive" ]
}

@test "the template's ### YYYY-MM-DD heading style rotates too" {
  make_progress 120 "### "
  bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  [ "$(grep -c '^### 2026-' PROGRESS.md)" -eq 10 ]
  [ -d docs/progress-archive ]
}

# A file it cannot parse is a file it must not rewrite.
@test "a long file with no dated headings is refused, not mangled" {
  { echo "# Progress Log"; for i in $(seq 1 600); do echo "line $i"; done; } > PROGRESS.md
  cp PROGRESS.md before.md
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no dated session headings"* ]]
  diff before.md PROGRESS.md
}

@test "an oldest-first file is refused instead of archiving the wrong end" {
  python3 - <<'PY' > PROGRESS.md
from datetime import date, timedelta
print("# Progress Log")
print()
day = date(2026, 1, 1)
# 200, not 120: at 120 the file is 363 lines, under the 400-line threshold, so
# rotate-progress.sh returned "under the threshold" and never reached the order
# check this test exists to exercise. It passed anyway — the assertion that
# would have caught it was not the last command in the body, and bash 3.2's
# errexit does not fire inside a function, so bats reported ok. Fixed once the
# suite was run under bash 5 (2026-08-22).
for i in range(200):
    print(f"## Session {day + timedelta(days=i)} (session {i})")
    print(f"- Done: work item {i}")
    print()
PY
  cp PROGRESS.md before.md
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  [[ "$output" == *"oldest-first"* ]]
  diff before.md PROGRESS.md
}

@test "--dry-run changes nothing" {
  make_progress 120
  cp PROGRESS.md before.md
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"dry run"* ]]
  diff before.md PROGRESS.md
  [ ! -d docs/progress-archive ]
}

@test "the archive is append-only across months" {
  make_progress 120
  bash "$HARNESS_ROOT/scripts/rotate-progress.sh"
  ls docs/progress-archive/ | grep -q "2026-"
  head -1 docs/progress-archive/*.md | grep -q "Progress archive"
}

@test "session-end runs rotation and reports it" {
  git init -q .
  git config user.email t@t
  git config user.name t
  make_progress 120
  mkdir -p memory docs
  echo "x" > "memory/$(date +%Y-%m-%d).md"
  run bash "$HARNESS_ROOT/scripts/session-end.sh"
  [[ "$output" == *"PROGRESS.md rotation"* ]]
  [ "$(grep -c '^## Session' PROGRESS.md)" -eq 10 ]
}

# --keep is a ceiling, not a target: sessions differ wildly in size, so a fixed
# count cannot honour a line budget. This repo's own file kept 840 lines under
# a 400-line threshold when the count alone decided.
@test "the line threshold wins over the session count, down to a floor of 3" {
  python3 - <<'PY' > PROGRESS.md
from datetime import date, timedelta
print("# Progress Log")
print()
day = date(2026, 8, 19)
for i in range(30):
    print(f"## Session {day - timedelta(days=i)} (session {30 - i})")
    for n in range(60):
        print(f"- long entry line {n}")
    print()
PY
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh" --max-lines 400
  [ "$status" -eq 0 ]
  # Fewer than the default ceiling of 10, and actually under the threshold —
  # the count bends to the budget rather than the other way round.
  [ "$(grep -c '^## Session' PROGRESS.md)" -lt 10 ]
  [ "$(grep -c '^## Session' PROGRESS.md)" -ge 3 ]
  [ "$(wc -l < PROGRESS.md)" -le 400 ]
}

@test "a file with three or fewer sections is never trimmed further" {
  python3 - <<'PY' > PROGRESS.md
from datetime import date, timedelta
print("# Progress Log")
print()
day = date(2026, 8, 19)
for i in range(3):
    print(f"## Session {day - timedelta(days=i)} (session {3 - i})")
    for n in range(300):
        print(f"- long entry line {n}")
    print()
PY
  cp PROGRESS.md before.md
  run bash "$HARNESS_ROOT/scripts/rotate-progress.sh" --max-lines 100
  [ "$status" -eq 0 ]
  [[ "$output" == *"keeping all"* ]]
  diff before.md PROGRESS.md
}
