# tests/unadopt.bats — regression test for T-H0
#
# T-H0 (implementation-plan-2 Wave H): `unadopt` used to leave the
# post-commit rollback guard installed, which then rolled back every
# future commit in the project (dod.sh step 4 fails on the now-deleted
# PROGRESS.md -> post-commit guard resets the commit). This test proves
# a commit made after unadopt survives.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  SCRATCH="$(mktemp -d)"
  export SCRATCH
  cd "$SCRATCH" || return 1
  git init -q
  git config user.email "test@test"
  git config user.name "test"
}

teardown() {
  cd "$HARNESS_ROOT" || true
  rm -rf "$SCRATCH"
}

@test "unadopt removes both git hooks and a later commit is not rolled back" {
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open
  [ -f "$SCRATCH/.git/hooks/post-commit" ]
  [ -f "$SCRATCH/.git/hooks/pre-commit" ]

  printf 'n\n' | bash "$HARNESS_ROOT/scripts/unadopt.sh"
  [ ! -f "$SCRATCH/.git/hooks/post-commit" ]
  [ ! -f "$SCRATCH/.git/hooks/pre-commit" ]

  echo "x" > f.txt
  git add f.txt
  run git commit -q -m "test commit after unadopt"
  [ "$status" -eq 0 ]
  [ "$(git log --oneline | wc -l | tr -d ' ')" -ge 1 ]
}
