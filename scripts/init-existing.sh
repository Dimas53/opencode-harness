#!/bin/bash
# Open OpenCode TUI in an existing project for harness-init
# Usage: make init-existing PROJECT=/path/to/project

PROJECT=$1

if ! command -v opencode &>/dev/null; then
  echo "✗ opencode not found. Run: make setup"
  exit 1
fi

if [ -z "$PROJECT" ]; then
	echo "Usage: make init-existing PROJECT=/path/to/project"
	exit 1
fi

HARNESS_PATH="$(cd "$(dirname "$0")/.." && pwd)"

echo ""
echo "  Copying harness templates to existing project..."
cp "$HARNESS_PATH/templates/HARNESS.md" "$PROJECT/HARNESS.md" 2>/dev/null || true
cp "$HARNESS_PATH/templates/MEMORY.md" "$PROJECT/MEMORY.md" 2>/dev/null || true
cp "$HARNESS_PATH/templates/PROGRESS.md" "$PROJECT/PROGRESS.md" 2>/dev/null || true
mkdir -p "$PROJECT/memory"
echo "  Done."
echo ""

cd "$PROJECT" || exit 1
opencode --prompt "Load ~/.config/opencode/skills/harness-init/agent-init-existing.md" || {
  echo "✗ OpenCode failed to start. Check: opencode --version"
  exit 1
}
