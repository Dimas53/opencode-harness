# tests/index-memory.bats — T-J4
#
# Session Start used to read memory/ by date ("today or yesterday"), so a
# project with 14 notes could reach 2. The index is what makes the rest
# reachable, which means an index that silently misses a file is worse than no
# index at all — it looks like coverage. These tests are mostly about that.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  SCRATCH="$(mktemp -d)"
  export SCRATCH
  cd "$SCRATCH" || return 1
  mkdir -p memory
  printf '# Long-term Memory\n\n## Project Preferences\n- something\n' > MEMORY.md
}

teardown() {
  cd "$HARNESS_ROOT" || true
  rm -rf "$SCRATCH"
}

@test "every note in memory/ gets a line in the index" {
  printf '# 2026-08-01 — first note\n' > memory/2026-08-01.md
  printf '# 2026-08-02 — second note\n' > memory/2026-08-02.md
  printf '# 2026-08-03 — third note\n' > memory/2026-08-03.md
  run bash "$HARNESS_ROOT/scripts/index-memory.sh"
  [ "$status" -eq 0 ]
  [ "$(grep -c '](memory/' MEMORY.md)" -eq 3 ]
  grep -q "first note" MEMORY.md
  grep -q "third note" MEMORY.md
}

@test "existing prose in MEMORY.md is preserved" {
  printf '# 2026-08-01 — a note\n' > memory/2026-08-01.md
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  grep -q "^## Project Preferences" MEMORY.md
  grep -q "^- something" MEMORY.md
}

# A bare date heading is what every existing note actually has, and it says
# nothing the filename does not — so the summary falls through to the body.
@test "a note titled only with a date is summarized from its body" {
  printf '# 2026-08-01\n\n## Session summary\n- Fixed the push token refresh\n' > memory/2026-08-01.md
  run bash "$HARNESS_ROOT/scripts/index-memory.sh"
  [[ "$output" == *"no topic in their heading"* ]]
  grep -q "Fixed the push token refresh" MEMORY.md
}

@test "frontmatter description wins over the heading" {
  printf -- '---\nname: push-tokens\ndescription: Push tokens expire silently after 60 days\n---\n\n# Notes\n' > memory/push-tokens.md
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  grep -q "Push tokens expire silently after 60 days" MEMORY.md
}

@test "re-running does not duplicate the index" {
  printf '# 2026-08-01 — a note\n' > memory/2026-08-01.md
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  run bash "$HARNESS_ROOT/scripts/index-memory.sh"
  [[ "$output" == *"already current"* ]]
  [ "$(grep -c 'MEMORY-INDEX START' MEMORY.md)" -eq 1 ]
  [ "$(grep -c '](memory/' MEMORY.md)" -eq 1 ]
}

@test "a new note is picked up by a later run" {
  printf '# 2026-08-01 — first\n' > memory/2026-08-01.md
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  printf '# 2026-08-02 — second\n' > memory/2026-08-02.md
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  [ "$(grep -c '](memory/' MEMORY.md)" -eq 2 ]
}

@test "--check fails on an unindexed note and passes once indexed" {
  printf '# 2026-08-01 — first\n' > memory/2026-08-01.md
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  printf '# 2026-08-02 — second\n' > memory/2026-08-02.md
  run bash "$HARNESS_ROOT/scripts/index-memory.sh" --check
  [ "$status" -eq 1 ]
  [[ "$output" == *"out of date"* ]]
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  run bash "$HARNESS_ROOT/scripts/index-memory.sh" --check
  [ "$status" -eq 0 ]
}

@test "--check fails when MEMORY.md has no index at all" {
  printf '# 2026-08-01 — first\n' > memory/2026-08-01.md
  run bash "$HARNESS_ROOT/scripts/index-memory.sh" --check
  [ "$status" -eq 1 ]
  [[ "$output" == *"no memory index"* ]]
}

@test "an empty or missing memory/ is not an error" {
  run bash "$HARNESS_ROOT/scripts/index-memory.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no .md files"* ]]
  rm -rf memory
  run bash "$HARNESS_ROOT/scripts/index-memory.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "notes are listed newest first" {
  printf '# 2026-08-01 — older\n' > memory/2026-08-01.md
  printf '# 2026-08-09 — newer\n' > memory/2026-08-09.md
  bash "$HARNESS_ROOT/scripts/index-memory.sh"
  run bash -c "grep '](memory/' MEMORY.md | head -1"
  [[ "$output" == *"newer"* ]]
}

@test "session-end regenerates the index" {
  git init -q .
  git config user.email t@t
  git config user.name t
  printf '# 2026-08-01 — a note\n' > memory/2026-08-01.md
  printf 'x\ny\nz\n' > "memory/$(date +%Y-%m-%d).md"
  run bash "$HARNESS_ROOT/scripts/session-end.sh"
  [[ "$output" == *"memory/ index"* ]]
  [ "$(grep -c '](memory/' MEMORY.md)" -eq 2 ]
}
