setup() {
  export HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "scripts/dod.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/dod.sh" ]
  [ -s "$HARNESS_ROOT/scripts/dod.sh" ]
}

@test "scripts/session-end.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/session-end.sh" ]
  [ -s "$HARNESS_ROOT/scripts/session-end.sh" ]
}

@test "scripts/start.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/start.sh" ]
  [ -s "$HARNESS_ROOT/scripts/start.sh" ]
}

@test "scripts/install.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/install.sh" ]
  [ -s "$HARNESS_ROOT/scripts/install.sh" ]
}

@test "scripts/verify.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/verify.sh" ]
  [ -s "$HARNESS_ROOT/scripts/verify.sh" ]
}

@test "scripts/update.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/update.sh" ]
  [ -s "$HARNESS_ROOT/scripts/update.sh" ]
}

@test "scripts/init-project.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/init-project.sh" ]
  [ -s "$HARNESS_ROOT/scripts/init-project.sh" ]
}

@test "scripts/init-adopt.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/init-adopt.sh" ]
  [ -s "$HARNESS_ROOT/scripts/init-adopt.sh" ]
}

@test "scripts/analyze.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/analyze.sh" ]
  [ -s "$HARNESS_ROOT/scripts/analyze.sh" ]
}

@test "scripts/install-hooks.sh exists and non-empty" {
  [ -f "$HARNESS_ROOT/scripts/install-hooks.sh" ]
  [ -s "$HARNESS_ROOT/scripts/install-hooks.sh" ]
}

@test "hooks/pre-commit exists and non-empty" {
  [ -f "$HARNESS_ROOT/hooks/pre-commit" ]
  [ -s "$HARNESS_ROOT/hooks/pre-commit" ]
}

@test "all scripts pass bash -n syntax check" {
  for script in "$HARNESS_ROOT"/scripts/*.sh; do
    bash -n "$script" || return 1
  done
}

@test "hooks/pre-commit passes bash -n syntax check" {
  bash -n "$HARNESS_ROOT/hooks/pre-commit"
}

@test "scripts do not contain TODO placeholders" {
  run grep -r "TODO" "$HARNESS_ROOT/scripts/" --include="*.sh"
  [ "$status" -ne 0 ]
}
