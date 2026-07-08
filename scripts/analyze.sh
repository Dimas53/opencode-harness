#!/bin/bash
# Open OpenCode TUI in a project for analysis only
# Usage: make analyze PROJECT=/path/to/project

PROJECT=$1

if [ -z "$PROJECT" ]; then
    echo "Usage: make analyze PROJECT=/path/to/project"
    exit 1
fi

echo ""
echo "  Opening OpenCode in project: $PROJECT"
echo ""
echo "  When OpenCode opens, type:"
echo ""
echo "    Load ~/.config/opencode/skills/harness-init/agent-analyze.md"
echo ""

cd "$PROJECT" || exit 1
opencode
