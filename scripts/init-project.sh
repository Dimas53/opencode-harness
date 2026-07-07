#!/bin/bash
# Scaffold a new project and open OpenCode TUI for harness-init
# Usage: make init PROJECT=/path/to/project

PROJECT=$1

if [ -z "$PROJECT" ]; then
	echo "Usage: make init PROJECT=/path/to/project"
	exit 1
fi

mkdir -p "$PROJECT"
cp -r templates/docs/ "$PROJECT/docs/"
cp templates/AGENTS.md "$PROJECT/AGENTS.md"

echo ""
echo "  Project scaffold created at $PROJECT"
echo "  Templates: docs/ + AGENTS.md"
echo ""
echo "  Opening OpenCode now..."
echo ""
echo "  When OpenCode opens, type:"
echo ""
echo "    Load ~/.config/opencode/skills/harness-init/SKILL.md and run it."
echo ""

cd "$PROJECT" || exit 1
opencode
