#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== OpenCode Harness — Update ==="

# Pull latest — abort on failure
git pull origin main || { echo "✗ git pull failed — aborting"; exit 1; }

# Update AGENTS.md with diff preview
GLOBAL_AGENTS="$HOME/.config/opencode/AGENTS.md"
REPO_AGENTS="global/AGENTS.md"

if [ ! -f "$GLOBAL_AGENTS" ]; then
  cp "$REPO_AGENTS" "$GLOBAL_AGENTS"
  echo "✓ AGENTS.md installed (fresh install)"
elif diff -q "$GLOBAL_AGENTS" "$REPO_AGENTS" > /dev/null 2>&1; then
  echo "✓ AGENTS.md is up to date — no changes"
else
  echo ""
  echo -e "${BLUE}┌─────────────────────────────────────┐${NC}"
  echo -e "${BLUE}│        AGENTS.md has updates        │${NC}"
  echo -e "${BLUE}└─────────────────────────────────────┘${NC}"
  echo ""
  echo "New lines in repo version:"
  diff "$GLOBAL_AGENTS" "$REPO_AGENTS" | grep "^>" | sed 's/^> //' | \
    while IFS= read -r line; do
      echo -e "  ${GREEN}+${NC} $line"
    done | head -20
  echo ""
  echo "  (showing first 20 changed lines)"
  echo ""

  if [ -t 1 ] && [ -t 0 ]; then
    printf "\033[1;33mApply changes? (y/n):\033[0m "
    read -r answer
    if [ "$answer" != "y" ]; then
      echo -e "${YELLOW}Skipped — AGENTS.md unchanged${NC}"
      exit 0
    fi
  else
    echo "No TTY detected — auto-applying changes"
  fi
  cp "$REPO_AGENTS" "$GLOBAL_AGENTS"
  echo -e "${GREEN}✓ AGENTS.md updated successfully${NC}"
fi

# Update skills — copy all from repo, overwriting existing
cp -r global/skills/* "$HOME/.config/opencode/skills/"
echo "✓ Skills updated from repo"

echo ""
echo "✓ Update complete. Run 'make verify' to check installation."
