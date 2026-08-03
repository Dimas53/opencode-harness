#!/bin/bash
# scripts/update-harness-shortcut.sh
# Body of the `update-harness` AGENTS.md shortcut — extracted so AGENTS.md
# stays a rules document, not a script. Invoked by OpenCode when the user
# types `update-harness`. See global/AGENTS.md "Harness Shortcuts".
set -euo pipefail

cd ~/.opencode-harness
GIT_OUTPUT=$(git pull 2>&1)
if echo "$GIT_OUTPUT" | grep -q "Already up to date"; then
  echo "✓ git pull: up to date"
else
  echo "✓ git pull: commits pulled"
fi
make update
echo "✓ AGENTS.md: check output above"
echo "✓ Skills: check output above"
