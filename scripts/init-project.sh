#!/bin/bash
# Scaffold a new project and open OpenCode TUI for harness-init
# Usage: make init PROJECT=/path/to/project

PROJECT=$1

if ! command -v opencode &>/dev/null; then
  echo "✗ opencode not found. Run: make setup"
  exit 1
fi

if [ -z "$PROJECT" ]; then
	echo "Usage: make init PROJECT=/path/to/project"
	exit 1
fi

mkdir -p "$PROJECT"
cp -r templates/docs/ "$PROJECT/docs/"
cp templates/AGENTS.md "$PROJECT/AGENTS.md"
cp templates/HARNESS.md "$PROJECT/HARNESS.md"

echo ""
echo "  Project scaffold created at $PROJECT"
echo "  Templates: docs/ + AGENTS.md + HARNESS.md"
echo ""
echo "  Opening OpenCode now..."
echo ""

cd "$PROJECT" || exit 1
opencode --prompt "Load ~/.config/opencode/skills/harness-init/agent-new-project.md" || {
  echo "✗ OpenCode failed to start. Check: opencode --version"
  exit 1
}
