#!/bin/bash
# Runs harness-init skill for a new project
# Usage: make init PROJECT=/path/to/project

PROJECT=$1

if [ -z "$PROJECT" ]; then
	echo "Usage: make init PROJECT=/path/to/project"
	exit 1
fi

mkdir -p "$PROJECT"
cp -r templates/docs/ "$PROJECT/docs/"
cd "$PROJECT" || exit 1
opencode run "Load ~/.config/opencode/skills/harness-init/SKILL.md and run it."
