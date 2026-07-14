#!/bin/bash
# Open OpenCode TUI in a project for analysis only
# Usage: make analyze PROJECT=/path/to/project

PROJECT=$1

if ! command -v opencode &>/dev/null; then
  echo "✗ opencode not found. Run: make setup"
  exit 1
fi

if [ -z "$PROJECT" ]; then
    echo "Usage: make analyze PROJECT=/path/to/project"
    exit 1
fi

echo ""
echo "  Opening OpenCode in project: $PROJECT"
echo ""

cd "$PROJECT" || exit 1
opencode --prompt "Load ~/.config/opencode/skills/harness-init/agent-analyze.md" || {
  echo "✗ OpenCode failed to start. Check: opencode --version"
  exit 1
}
