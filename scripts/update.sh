#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== OpenCode Harness — Update ==="

# Pull latest — abort on failure
git pull origin main || { echo "✗ git pull failed — aborting"; exit 1; }

# Update AGENTS.md — surgical merge, never a blind overwrite (T-G-U1).
# global/AGENTS.md is wrapped in HARNESS-MANAGED START/END markers. Only the
# region between them is ever touched; anything a user added above START or
# below END (their own rules, appended by hand or by an older install.sh)
# survives every update untouched.
GLOBAL_AGENTS="$HOME/.config/opencode/AGENTS.md"
REPO_AGENTS="global/AGENTS.md"
MARK_START="# === HARNESS-MANAGED START"
MARK_END="# === HARNESS-MANAGED END ==="

if [ ! -f "$GLOBAL_AGENTS" ]; then
  cp "$REPO_AGENTS" "$GLOBAL_AGENTS"
  echo "✓ AGENTS.md installed (fresh install)"
elif diff -q "$GLOBAL_AGENTS" "$REPO_AGENTS" > /dev/null 2>&1; then
  echo "✓ AGENTS.md is up to date — no changes"
elif grep -qF "$MARK_START" "$GLOBAL_AGENTS" && grep -qF "$MARK_END" "$GLOBAL_AGENTS"; then
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
  echo "  (showing first 20 changed lines — only the HARNESS-MANAGED region"
  echo "   is replaced; anything you added outside it is untouched)"
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

  TMP_AGENTS=$(mktemp)
  awk -v m="$MARK_START" 'index($0, m) { exit } { print }' "$GLOBAL_AGENTS" > "$TMP_AGENTS"
  cat "$REPO_AGENTS" >> "$TMP_AGENTS"
  awk -v m="$MARK_END" 'found { print } index($0, m) { found = 1 }' "$GLOBAL_AGENTS" >> "$TMP_AGENTS"
  mv "$TMP_AGENTS" "$GLOBAL_AGENTS"
  echo -e "${GREEN}✓ AGENTS.md updated successfully (HARNESS-MANAGED region only)${NC}"
else
  # No markers found: an old-style install (plain copy, or install.sh's old
  # unmarked append). Surgical merge is impossible without knowing where the
  # harness-managed content starts and ends — never silently overwrite, and
  # never auto-apply on a no-TTY run, unlike the old behavior.
  echo ""
  echo -e "${YELLOW}⚠ $GLOBAL_AGENTS has no HARNESS-MANAGED markers.${NC}"
  echo "  This is an old-style install — automatic surgical merge isn't safe."
  cp "$GLOBAL_AGENTS" "$GLOBAL_AGENTS.bak"
  echo "  Backed up to: $GLOBAL_AGENTS.bak"
  echo ""
  echo "  Diff (repo version vs. yours):"
  diff "$GLOBAL_AGENTS" "$REPO_AGENTS" | head -30
  echo ""
  if [ -t 1 ] && [ -t 0 ]; then
    printf "\033[1;33mReplace $GLOBAL_AGENTS entirely with the repo version? (y/n):\033[0m "
    read -r answer
    if [ "$answer" = "y" ]; then
      cp "$REPO_AGENTS" "$GLOBAL_AGENTS"
      echo -e "${GREEN}✓ AGENTS.md replaced (backup kept at $GLOBAL_AGENTS.bak)${NC}"
    else
      echo -e "${YELLOW}Skipped — AGENTS.md unchanged. Merge manually, or delete it and rerun to get a fresh marked install.${NC}"
    fi
  else
    echo -e "${YELLOW}No TTY detected — skipping (never auto-apply without markers). Run interactively to resolve.${NC}"
  fi
fi

# Update skills — copy all from repo, overwriting existing
rsync -a --exclude-from=scripts/mirror-excludes.txt global/skills/ "$HOME/.config/opencode/skills/"
echo "✓ Skills updated from repo"
STALE_SKILLS=$(comm -23 \
    <(find "$HOME/.config/opencode/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort) \
    <(find global/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
if [ -n "$STALE_SKILLS" ]; then
    echo -e "${YELLOW}⚠ Skills in ~/.config/opencode/skills/ not in this repo's global/skills/ (kept, not auto-removed):${NC}"
    echo "$STALE_SKILLS" | sed 's/^/    /'
fi

# Propagate opencode.jsonc (MCP servers + permission block) — T-G-U2.
# install.sh does this on a fresh/existing install; update-harness never
# did, so new MCP servers (or Wave E's permission config, once it lands)
# only reached the machine via a fresh `make setup`, never via update.
GLOBAL_OPENCODE_CFG="$HOME/.config/opencode/opencode.jsonc"
if [ -f "$GLOBAL_OPENCODE_CFG" ]; then
  TEMPLATE_TMP=$(mktemp)
  sed "s|/YOUR/HOME/PATH|$HOME|g" global/opencode-config.example.jsonc > "$TEMPLATE_TMP"
  echo "→ Merging MCP servers + permission config into opencode.jsonc..."
  bash "$(dirname "$0")/merge-opencode-config.sh" "$TEMPLATE_TMP" "$GLOBAL_OPENCODE_CFG"
  rm -f "$TEMPLATE_TMP"
else
  echo "⚠ $GLOBAL_OPENCODE_CFG not found — run 'make setup' first for a fresh install"
fi

# Install post-commit hook (for auto-mirror on future commits)
cp hooks/post-commit .git/hooks/post-commit
chmod +x .git/hooks/post-commit
echo "✓ post-commit hook installed"

echo ""
echo "✓ Update complete. Run 'make verify' to check installation."
