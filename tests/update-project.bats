# tests/update-project.bats — regression tests for T-I14 step 3
#
# The optional CI gate (H-DEC-4: "never installed silently") was only ever
# offered by `new`/`adopt`, so a project adopted before it existed had no way
# to hear about it. update-project.sh now offers it — but as a question of its
# own, because folding it into the bulk "apply the updates above? (y/n)"
# prompt would install it as a side effect of agreeing to something else,
# which is exactly what H-DEC-4 forbids.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  export OPENCODE_HARNESS_PATH="$HARNESS_ROOT"
  SCRATCH="$(mktemp -d)"
  export SCRATCH
  cd "$SCRATCH" || return 1
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  git remote add origin "git@github.com:someone/proj.git"
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open >/dev/null 2>&1
}

teardown() {
  cd "$HARNESS_ROOT" || true
  rm -rf "$SCRATCH"
}

@test "update-project offers the CI gate when it is not installed" {
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" == *"CI gate — not installed"* ]]
  [[ "$output" == *"[none / github / gitlab]"* ]]
}

@test "answering none installs no CI file" {
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [ ! -f "$SCRATCH/.github/workflows/dod.yml" ]
  [ ! -f "$SCRATCH/.gitlab-ci.yml" ]
}

@test "answering github installs the workflow" {
  run bash -c "printf 'n\ngithub\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [ -f "$SCRATCH/.github/workflows/dod.yml" ]
  grep -q "bash .opencode-harness-ci/scripts/dod.sh" "$SCRATCH/.github/workflows/dod.yml"
}

@test "an installed CI gate is not offered again" {
  bash -c "printf 'n\ngithub\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" != *"CI gate — not installed"* ]]
}

# The point of the separate question: bulk-declining must not decline the CI
# gate, and bulk-accepting must not install it.
@test "the CI gate is asked separately from the bulk update" {
  rm -f "$SCRATCH/PLAN.md"
  run bash -c "printf 'y\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [ -f "$SCRATCH/PLAN.md" ]                        # bulk 'y' still applied
  [ ! -f "$SCRATCH/.github/workflows/dod.yml" ]    # CI 'none' respected
}

# GitLab pipelines are the project's entire CI definition; adding one job is
# not worth clobbering it, so an existing file is reported, never replaced.
@test "an existing .gitlab-ci.yml is never overwritten" {
  printf 'stages:\n  - test\nbuild:\n  script: echo hi\n' > "$SCRATCH/.gitlab-ci.yml"
  run bash -c "printf 'n\ngitlab\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" == *"not overwritten"* ]]
  grep -q "script: echo hi" "$SCRATCH/.gitlab-ci.yml"
  ! grep -q "opencode-harness-ci" "$SCRATCH/.gitlab-ci.yml"
}

# A .gitlab-ci.yml that already carries a dod job counts as installed — the
# check is the job, not the filename.
@test "a .gitlab-ci.yml with a dod job counts as installed" {
  printf 'dod:\n  script: echo gate\n' > "$SCRATCH/.gitlab-ci.yml"
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" != *"CI gate — not installed"* ]]
}
