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

# T-I3: install-hooks.sh used to `mv $dest $dest.bak` unconditionally, so the
# second run (update-project re-runs it on hook drift) overwrote the project's
# real hook backup with a copy of the harness hook — and unadopt then
# "restored" the rollback guard into a de-adopted project.
@test "install-hooks is idempotent: a real pre-harness hook survives two runs" {
  printf '#!/bin/bash\necho MY-OWN-HOOK\n' > .git/hooks/post-commit
  chmod +x .git/hooks/post-commit

  bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH"
  bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH"

  grep -q "MY-OWN-HOOK" "$SCRATCH/.git/hooks/post-commit.bak"
  grep -q "harness-managed-hook" "$SCRATCH/.git/hooks/post-commit"
}

@test "unadopt restores the project's own hook, not a harness copy" {
  printf '#!/bin/bash\necho MY-OWN-HOOK\n' > .git/hooks/post-commit
  chmod +x .git/hooks/post-commit

  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open
  bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH"

  printf 'n\n' | bash "$HARNESS_ROOT/scripts/unadopt.sh"
  [ -f "$SCRATCH/.git/hooks/post-commit" ]
  grep -q "MY-OWN-HOOK" "$SCRATCH/.git/hooks/post-commit"
  ! grep -q "harness-managed-hook" "$SCRATCH/.git/hooks/post-commit"
}

# T-I3, other half: when the .bak IS a harness hook (debris from the old bug),
# unadopt must discard it rather than reinstall the rollback guard.
@test "unadopt discards a stale harness backup instead of restoring it" {
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open
  cp "$SCRATCH/.git/hooks/post-commit" "$SCRATCH/.git/hooks/post-commit.bak"

  printf 'n\n' | bash "$HARNESS_ROOT/scripts/unadopt.sh"
  [ ! -f "$SCRATCH/.git/hooks/post-commit" ]
  [ ! -f "$SCRATCH/.git/hooks/post-commit.bak" ]
}
