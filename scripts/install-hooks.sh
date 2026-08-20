#!/bin/bash
# scripts/install-hooks.sh
# Installs pre-commit AND post-commit hooks into the target project's
# .git/hooks/.
# Usage: ./scripts/install-hooks.sh /path/to/project
#        (called by init-project.sh and init-adopt.sh)
#
# Both hooks are meant to run in every project:
# - pre-commit: the DoD gate (scripts/dod.sh), blocks a bad commit.
# - post-commit: the DoD *guard* — catches `git commit --no-verify` (or any
#   other pre-commit bypass) and rolls the commit back. This used to be
#   installed ONLY in the harness's own repo, on the reasoning that its
#   other job (mirroring global/skills/ to ~/.config/opencode/) only makes
#   sense there. That reasoning went stale the moment the rollback-guard
#   responsibility was added to the same file (Wave 3, T3.1) — the
#   mirroring half is a harmless no-op in a client project (no global/
#   directory there to match), but the rollback-guard half is real
#   protection every project should have. Installing the unified hook
#   everywhere is the correct fix, not splitting it into two files.
set -euo pipefail

TARGET_PROJECT="${1:-$(pwd)}"
GIT_HOOKS_DIR="$TARGET_PROJECT/.git/hooks"
HARNESS_PATH="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$TARGET_PROJECT/.git" ]; then
  echo "⚠ No .git directory in $TARGET_PROJECT — skipping hook install"
  exit 0
fi

mkdir -p "$GIT_HOOKS_DIR"

install_hook() {
  local name="$1"
  local source="$HARNESS_PATH/hooks/$name"
  local dest="$GIT_HOOKS_DIR/$name"

  # Back up ONLY a hook that is not ours, and only when there is no backup
  # yet. The old code moved whatever was there to .bak unconditionally, every
  # run — so the second `update-project` (which re-runs this script on hook
  # drift) overwrote the project's real pre-harness hook with a copy of the
  # harness hook. `unadopt` then "restored" that copy, leaving the rollback
  # guard behind in a de-adopted project: exactly the silent brick T-H0 was
  # written to prevent, reached by another road (T-I3).
  # Recognising our own hook cannot rely on the signature alone: it was added
  # by T-I3, so every project adopted before that has an unsigned harness hook
  # that looks exactly like a stranger's. Both live client projects are in that
  # state, and without this branch their first `update-project` would "back up"
  # a harness hook as if it were the user's — more debris, from the fix meant to
  # stop debris. The pre-T-I3 header is a reliable second marker: it names the
  # installer and the gate it calls.
  is_ours() {
    grep -q "harness-managed-hook" "$1" && return 0
    grep -q "Installed by: scripts/install-hooks.sh" "$1" \
      && grep -qE "dod\.sh|OPENCODE_HARNESS_PATH" "$1" && return 0
    return 1
  }

  # A .bak that is itself a harness hook is debris from the clobbering bug,
  # not a backup worth protecting. Say so — silently working around it would
  # leave the user with a file they cannot explain, and deleting it here would
  # be a destructive act this script has no mandate for. `unadopt` discards it.
  if [ -f "$dest.bak" ] && is_ours "$dest.bak"; then
    echo "  note: $name.bak is itself a harness hook (debris from the pre-T-I3 bug),"
    echo "        not a pre-harness backup. Safe to delete; unadopt discards it."
  fi

  if [ -f "$dest" ]; then
    if is_ours "$dest"; then
      echo "  $name hook is already a harness hook — replacing in place (backup untouched)"
    elif [ -f "$dest.bak" ]; then
      echo "⚠ $name.bak already exists (a real pre-harness hook) — NOT overwriting it"
      echo "  Current $name saved to $name.harness-old instead"
      mv "$dest" "$dest.harness-old"
    else
      echo "⚠ Existing $name hook found — backing up to $name.bak"
      mv "$dest" "$dest.bak"
    fi
  fi

  cp "$source" "$dest"
  chmod +x "$dest"

  # Bake in HARNESS_PATH so the hook can find dod.sh without the env var
  sed -i.sedbak "s|OPENCODE_HARNESS_PATH:-\$HOME/.opencode-harness|OPENCODE_HARNESS_PATH:-$HARNESS_PATH|g" \
    "$dest" && rm -f "$dest.sedbak"

  echo "✓ $name hook installed in $GIT_HOOKS_DIR"
}

install_hook "pre-commit"
install_hook "post-commit"

echo "  Every commit now runs the DoD gate (pre-commit) and the"
echo "  no-verify rollback guard (post-commit)."