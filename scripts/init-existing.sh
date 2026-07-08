#!/bin/bash
# Open OpenCode TUI in an existing project for harness-init
# Usage: make init-existing PROJECT=/path/to/project

PROJECT=$1

if [ -z "$PROJECT" ]; then
	echo "Usage: make init-existing PROJECT=/path/to/project"
	exit 1
fi

echo ""
echo "  Opening OpenCode in existing project: $PROJECT"
echo ""
echo "  When OpenCode opens, type:"
echo ""
echo "    Load ~/.config/opencode/skills/harness-init/agent-init-existing.md"
echo ""

cd "$PROJECT" || exit 1
opencode
