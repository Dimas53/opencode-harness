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


# T-I16: unadopt keyed on MEMORY.md alone, so a project adopted without it
# could not be un-adopted at all; and it left .agentignore plus the two state
# files behind in a project that no longer has anything to explain them.
@test "unadopt works without MEMORY.md and removes .agentignore and state files" {
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open
  rm -f MEMORY.md
  touch .session-ended .dod-run.log
  [ -f "$SCRATCH/.agentignore" ]

  printf 'n\n' | bash "$HARNESS_ROOT/scripts/unadopt.sh"

  [ ! -f "$SCRATCH/.agentignore" ]
  [ ! -f "$SCRATCH/.session-ended" ]
  [ ! -f "$SCRATCH/.dod-run.log" ]
  [ -f "$SCRATCH/.harness-unadopt-backup/.agentignore" ]
}

# T-J12: .harness/ is the agent's scratch space. It is git-ignored working
# state, so leaving it in a de-adopted project means a directory nobody can
# account for — the same reason .session-ended and .dod-run.log are removed.
@test "unadopt removes the .harness scratch directory" {
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open
  mkdir -p "$SCRATCH/.harness/scratch"
  echo "temp" > "$SCRATCH/.harness/scratch/notes.txt"

  printf 'n\n' | bash "$HARNESS_ROOT/scripts/unadopt.sh"

  [ ! -d "$SCRATCH/.harness" ]
}

# T-I3 follow-up: the signature was added by T-I3 itself, so every project
# adopted before it has an UNSIGNED harness hook that looks like a stranger's.
# Both live client projects are in that state; without recognising the older
# header, their first update-project would "back up" a harness hook as if it
# were the user's — debris produced by the fix meant to stop debris.
@test "an unsigned pre-T-I3 harness hook is recognised as ours, not backed up" {
  cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/bash
# .git/hooks/pre-commit
# Installed by: scripts/install-hooks.sh
# Blocks commit if DoD checks fail.
HARNESS_PATH="${OPENCODE_HARNESS_PATH:-/some/path}"
DOD_SCRIPT="$HARNESS_PATH/scripts/dod.sh"
PRE_COMMIT=1 bash "$DOD_SCRIPT"
HOOK
  chmod +x .git/hooks/pre-commit

  run bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already a harness hook"* ]]
  [ ! -f "$SCRATCH/.git/hooks/pre-commit.bak" ]
  [ ! -f "$SCRATCH/.git/hooks/pre-commit.harness-old" ]
  grep -q "harness-managed-hook" "$SCRATCH/.git/hooks/pre-commit"
}

@test "a harness hook sitting in .bak is reported as debris, not treated as a backup" {
  bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH" >/dev/null
  cp "$SCRATCH/.git/hooks/pre-commit" "$SCRATCH/.git/hooks/pre-commit.bak"

  run bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH"
  [[ "$output" == *"debris from the pre-T-I3 bug"* ]]
  [ -f "$SCRATCH/.git/hooks/pre-commit.bak" ]
}

# The first version of is_ours matched only "Installed by: scripts/install-hooks.sh"
# and so recognised pre-commit but not post-commit, whose older header reads
# "Installed by: scripts/install.sh, scripts/update.sh". On a live project that
# meant one hook replaced cleanly and the other filed away as a stranger's
# backup — same repo, two headers, one assumption.
@test "the older post-commit header is recognised too, not just install-hooks.sh" {
  cat > .git/hooks/post-commit <<'HOOK'
#!/bin/bash
# .git/hooks/post-commit
# Installed by: scripts/install.sh, scripts/update.sh
#
# Mirrors global/skills/ to ~/.config/opencode/skills/ after each commit.
DOD_SCRIPT="${OPENCODE_HARNESS_PATH:-$HOME/.opencode-harness}/scripts/dod.sh"
HOOK
  chmod +x .git/hooks/post-commit

  run bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"post-commit hook is already a harness hook"* ]]
  [ ! -f "$SCRATCH/.git/hooks/post-commit.bak" ]
  [ ! -f "$SCRATCH/.git/hooks/post-commit.harness-old" ]
}
