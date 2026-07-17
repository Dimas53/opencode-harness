setup() {
  export HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "templates/AGENTS.md exists and non-empty" {
  [ -f "$HARNESS_ROOT/templates/AGENTS.md" ]
  [ -s "$HARNESS_ROOT/templates/AGENTS.md" ]
}

@test "templates/HARNESS.md exists and non-empty" {
  [ -f "$HARNESS_ROOT/templates/HARNESS.md" ]
  [ -s "$HARNESS_ROOT/templates/HARNESS.md" ]
}

@test "templates/PROGRESS.md exists and non-empty" {
  [ -f "$HARNESS_ROOT/templates/PROGRESS.md" ]
  [ -s "$HARNESS_ROOT/templates/PROGRESS.md" ]
}

@test "templates/MEMORY.md exists and non-empty" {
  [ -f "$HARNESS_ROOT/templates/MEMORY.md" ]
  [ -s "$HARNESS_ROOT/templates/MEMORY.md" ]
}

@test "templates/PLAN.md exists and non-empty" {
  [ -f "$HARNESS_ROOT/templates/PLAN.md" ]
  [ -s "$HARNESS_ROOT/templates/PLAN.md" ]
}

@test "templates do not contain unfilled [TODO] placeholders" {
  run grep -r "\[TODO\]" "$HARNESS_ROOT/templates/"
  [ "$status" -ne 0 ]
}
