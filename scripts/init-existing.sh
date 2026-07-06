#!/bin/bash
# Runs harness-init skill for an existing project
# Usage: make init-existing PROJECT=/path/to/project

PROJECT=$1

if [ -z "$PROJECT" ]; then
	echo "Usage: make init-existing PROJECT=/path/to/project"
	exit 1
fi

cp -r templates/docs/ "$PROJECT/docs/"
cd "$PROJECT" || exit 1
opencode run "Load ~/.config/opencode/skills/harness-init/SKILL.md and run it in existing-project mode."
