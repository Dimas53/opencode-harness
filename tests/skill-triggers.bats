# tests/skill-triggers.bats — T-J5
#
# The Auto-Loading table is edited by hand every time a skill is added, and a
# new collision is invisible in the diff — you would have to remember all 152
# trigger words to spot one. That is what this checker is for, so it needs a
# test proving it actually fails on a collision rather than passing everything.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  SCRATCH="$(mktemp -d)"
  export SCRATCH
}

teardown() {
  rm -rf "$SCRATCH"
}

@test "the live table has no colliding triggers" {
  run bash "$HARNESS_ROOT/scripts/check-skill-triggers.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no collisions"* ]]
}

@test "a duplicated trigger word is reported with both domains" {
  {
    echo "| Domain | Triggers | Path |"
    echo "|---|---|---|"
    echo "| Alpha | refactor, tidy | alpha/SKILL.md |"
    echo "| Beta | refactor, rework | beta/SKILL.md |"
  } > "$SCRATCH/table.md"
  run bash "$HARNESS_ROOT/scripts/check-skill-triggers.sh" --file "$SCRATCH/table.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"refactor"* ]]
  [[ "$output" == *"Alpha"* ]]
  [[ "$output" == *"Beta"* ]]
}

@test "case and backticks do not hide a collision" {
  {
    echo "| Domain | Triggers | Path |"
    echo "|---|---|---|"
    echo "| Alpha | Docker, tidy | alpha/SKILL.md |"
    echo "| Beta | \`docker\`, rework | beta/SKILL.md |"
  } > "$SCRATCH/table.md"
  run bash "$HARNESS_ROOT/scripts/check-skill-triggers.sh" --file "$SCRATCH/table.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"docker"* ]]
}

@test "distinct triggers pass" {
  {
    echo "| Domain | Triggers | Path |"
    echo "|---|---|---|"
    echo "| Alpha | deploy secrets, tidy | alpha/SKILL.md |"
    echo "| Beta | deploy, rework | beta/SKILL.md |"
  } > "$SCRATCH/table.md"
  run bash "$HARNESS_ROOT/scripts/check-skill-triggers.sh" --file "$SCRATCH/table.md"
  [ "$status" -eq 0 ]
}

# If the table is moved or renamed, silence would read as success.
@test "a file with no Auto-Loading rows fails instead of passing empty" {
  printf '# Nothing here\n' > "$SCRATCH/table.md"
  run bash "$HARNESS_ROOT/scripts/check-skill-triggers.sh" --file "$SCRATCH/table.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no Auto-Loading rows"* ]]
}
