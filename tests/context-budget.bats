# tests/context-budget.bats — T-J0
#
# The script exists because nothing measured the cost of Session Start, so
# global/AGENTS.md grew 436 → 467 → 497 → 517 against a target of ~220 without
# anything objecting. A measurement nobody checks decays the same way, hence
# these tests — in particular the drift one: if the protocol starts reading a
# file the script does not know about, the total silently stops being true.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  SCRATCH="$(mktemp -d)"
  export SCRATCH
}

teardown() {
  cd "$HARNESS_ROOT" || true
  rm -rf "$SCRATCH"
}

@test "context-budget prints a total for the harness repo" {
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --quiet
  [ "$status" -eq 0 ]
  [[ "$output" =~ TOTAL\ ~[0-9]+\ tokens ]]
}

@test "context-budget measures an arbitrary project directory" {
  printf '# Project\n' > "$SCRATCH/AGENTS.md"
  printf 'x%.0s' {1..4000} > "$SCRATCH/PROGRESS.md"
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --project "$SCRATCH"
  [ "$status" -eq 0 ]
  progress_row="$(echo "$output" | grep '^PROGRESS.md')"
  [ -n "$progress_row" ]
  [[ "$progress_row" != *absent* ]]
}

@test "a missing file is reported as absent, not as an error" {
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --project "$SCRATCH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"absent"* ]]
}

@test "--check passes under the limit and fails over it" {
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --check 10000000 --quiet
  [ "$status" -eq 0 ]
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --check 1 --quiet
  [ "$status" -eq 1 ]
  [[ "$output" == *"exceeds the limit"* ]]
}

@test "--check rejects a non-numeric limit instead of ignoring it" {
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --check abc --quiet
  [ "$status" -eq 2 ]
}

# Cyrillic tokenizes worse than Latin, but counting a whole file at the worse
# rate on first sight of one Cyrillic character inflated the harness's own
# 103k-char PROGRESS.md by 15k tokens over 406 stray characters.
@test "token estimate counts Cyrillic proportionally, not by flag" {
  printf 'a%.0s' {1..1000} > "$SCRATCH/PROGRESS.md"
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --project "$SCRATCH" --quiet
  latin="$(echo "$output" | grep -oE '[0-9]+' | head -1)"
  printf 'a%.0s' {1..999} > "$SCRATCH/PROGRESS.md"
  # Written by codepoint, not as a literal: the DoD gate's Cyrillic scan
  # covers this repo's own files, and it is right to — a test that needs one
  # Cyrillic character should say so explicitly rather than smuggle it in.
  python3 -c "import sys;sys.stdout.write(chr(0x0444))" >> "$SCRATCH/PROGRESS.md"
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --project "$SCRATCH" --quiet
  mixed="$(echo "$output" | grep -oE '[0-9]+' | head -1)"
  [ "$mixed" -ge "$latin" ]
  [ $((mixed - latin)) -lt 100 ]
}

@test "the drift check reports a protocol file the script does not measure" {
  cp "$HARNESS_ROOT/global/AGENTS.md" "$SCRATCH/AGENTS.backup"
  python3 - "$HARNESS_ROOT/global/AGENTS.md" <<'PY'
import sys
path = sys.argv[1]
text = open(path).read()
old = "4. **Roadmap:** read `docs/roadmap.md`"
assert text.count(old) == 1
open(path, "w").write(text.replace(old, old + " and `docs/backlog.md`", 1))
PY
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --quiet
  cp "$SCRATCH/AGENTS.backup" "$HARNESS_ROOT/global/AGENTS.md"
  [[ "$output" == *"docs/backlog.md"* ]]
  [[ "$output" == *"does not measure"* ]]
}

@test "no drift warning when the protocol and the script agree" {
  run bash "$HARNESS_ROOT/scripts/context-budget.sh" --quiet
  [[ "$output" != *"does not measure"* ]]
}
