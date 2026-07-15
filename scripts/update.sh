#!/bin/bash
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
  echo "┌─────────────────────────────────────┐"
  echo "│        AGENTS.md has updates        │"
  echo "└─────────────────────────────────────┘"
  echo ""
  echo "New lines in repo version:"
  diff "$GLOBAL_AGENTS" "$REPO_AGENTS" | grep "^>" | sed 's/^> /  + /' | head -20
  echo ""
  echo "  (showing first 20 changed lines)"
  echo ""
  printf "Apply changes to ~/.config/opencode/AGENTS.md? (y/n): "
  read -r answer < /dev/tty
  if [ "$answer" = "y" ]; then
    cp "$REPO_AGENTS" "$GLOBAL_AGENTS"
    echo ""
    echo "✓ AGENTS.md updated successfully"
    echo ""
  else
    echo "Skipped — AGENTS.md unchanged"
  fi
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
