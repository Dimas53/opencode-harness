#!/bin/bash
echo "=== OpenCode Harness — Update ==="

# Pull latest
git pull origin main

# Update global AGENTS.md only if user hasn't modified it
if command -v md5 &>/dev/null; then
  MD5_CMD="md5 -q"
elif command -v md5sum &>/dev/null; then
  MD5_CMD="md5sum"
else
  MD5_CMD=""
fi

if [ -n "$MD5_CMD" ]; then
  LOCAL_HASH=$(eval "$MD5_CMD" ~/.config/opencode/AGENTS.md 2>/dev/null | cut -d' ' -f1)
  REPO_HASH=$(eval "$MD5_CMD" global/AGENTS.md 2>/dev/null | cut -d' ' -f1)
fi

if [ "$LOCAL_HASH" = "$REPO_HASH" ]; then
  cp global/AGENTS.md ~/.config/opencode/AGENTS.md
  echo "✓ AGENTS.md updated"
else
  echo "⚠ Your ~/.config/opencode/AGENTS.md has local changes."
  echo "  Review diff: diff ~/.config/opencode/AGENTS.md global/AGENTS.md"
  echo "  Then manually copy if needed."
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
