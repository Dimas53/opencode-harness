#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== OpenCode Harness — Update ==="

# Pull latest
git pull origin main

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

# Update skills — only ADD new ones, never overwrite existing
for skill_dir in global/skills/*/; do
  skill_name=$(basename "$skill_dir")
  target="$HOME/.config/opencode/skills/$skill_name"
  if [ ! -d "$target" ]; then
    cp -r "$skill_dir" "$target"
    echo "✓ New skill added: $skill_name"
  else
    echo "→ Skill already exists (skipped): $skill_name"
  fi
done

echo ""
echo "✓ Update complete. Run 'make verify' to check installation."
