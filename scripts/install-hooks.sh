#!/bin/bash
# scripts/install-hooks.sh
# Installs pre-commit hook into the target project's .git/hooks/.
# Usage: ./scripts/install-hooks.sh /path/to/project
#        (called by init-project.sh and init-existing.sh)
set -euo pipefail

TARGET_PROJECT="${1:-$(pwd)}"
GIT_HOOKS_DIR="$TARGET_PROJECT/.git/hooks"
HARNESS_PATH="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_SOURCE="$HARNESS_PATH/hooks/pre-commit"

if [ ! -d "$TARGET_PROJECT/.git" ]; then
  echo "⚠ No .git directory in $TARGET_PROJECT — skipping hook install"
  exit 0
fi

mkdir -p "$GIT_HOOKS_DIR"

if [ -f "$GIT_HOOKS_DIR/pre-commit" ]; then
  echo "⚠ pre-commit hook already exists — not overwriting"
  echo "  To reinstall: rm $GIT_HOOKS_DIR/pre-commit && make install-hooks PROJECT=$TARGET_PROJECT"
  exit 0
fi

cp "$HOOK_SOURCE" "$GIT_HOOKS_DIR/pre-commit"
chmod +x "$GIT_HOOKS_DIR/pre-commit"

# Bake in HARNESS_PATH so hook can find dod.sh without env var
sed -i.bak "s|OPENCODE_HARNESS_PATH:-\$HOME/.opencode-harness|OPENCODE_HARNESS_PATH:-$HARNESS_PATH|g" \
  "$GIT_HOOKS_DIR/pre-commit" && rm -f "$GIT_HOOKS_DIR/pre-commit.bak"

echo "✓ pre-commit hook installed in $GIT_HOOKS_DIR"
echo "  Every commit will now run: make dod"