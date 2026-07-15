#!/bin/bash
echo "=== OpenCode Harness Setup ==="

if ! command -v node &> /dev/null; then
	echo "Node.js not found. Install: https://nodejs.org"
	exit 1
fi

npm install -g opencode-ai

REQUIRED_VERSION="v1.17.20"
INSTALLED_VERSION=$(opencode --version 2>&1 | head -1)
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
  echo "⚠️  OpenCode version mismatch."
  echo "    Expected: $REQUIRED_VERSION"
  echo "    Installed: $INSTALLED_VERSION"
  echo "    Harness tested on $REQUIRED_VERSION — continue? (y/n)"
  read -r answer
  [ "$answer" = "y" ] || exit 1
fi

# Install uv (required for git and fetch MCP servers)
if command -v brew &> /dev/null; then
  brew install uv
  echo "✓ uv installed"
else
  echo "⚠ uv not installed — install manually: https://docs.astral.sh/uv/"
  echo "  Required for git MCP server and fetch MCP server"
fi

# RTK — token optimization for OpenCode
if command -v brew &> /dev/null; then
	echo "Installing RTK..."
	brew install rtk-ai/tap/rtk
	rtk init -g --opencode
	echo "✓ RTK installed. Run 'rtk gain' to see token savings."
else
	echo "⚠ RTK skipped — brew not found. Install manually: https://github.com/rtk-ai/rtk"
fi

npm install -g @modelcontextprotocol/server-filesystem
# git MCP runs via uvx — no npm install needed
# fetch MCP runs via uvx — no npm install needed
# context7 is remote — no install needed
npm install -g @playwright/mcp
npm install -g @modelcontextprotocol/server-sequential-thinking
echo "✓ Sequential thinking MCP installed"

# Chrome DevTools MCP (optional — for browser inspection)
npm install -g chrome-devtools-mcp
echo "✓ Chrome DevTools MCP installed"

npx playwright install
opencode plugin add superpowers@git+https://github.com/obra/superpowers.git

# Verify superpowers installed correctly
SKILL_COUNT=$(ls ~/.config/opencode/skills/ 2>/dev/null | wc -l)
if [ "$SKILL_COUNT" -lt 10 ]; then
  echo "⚠ Superpowers may not have installed correctly."
  echo "  Skills found: $SKILL_COUNT (expected 40+)"
  echo "  Try manually: opencode plugin add superpowers@git+https://github.com/obra/superpowers.git"
  echo "  Or check: https://github.com/obra/superpowers"
else
  echo "✓ Skills installed: $SKILL_COUNT"
fi

mkdir -p ~/.config/opencode/skills

cp global/AGENTS.md ~/.config/opencode/AGENTS.md
if [ ! -f ~/.config/opencode/opencode.jsonc ]; then
    cp global/opencode-config.example.jsonc ~/.config/opencode/opencode.jsonc
    echo "  → Created ~/.config/opencode/opencode.jsonc"
else
    echo "  → ~/.config/opencode/opencode.jsonc already exists — not overwritten"
fi
echo "✏️  Edit ~/.config/opencode/opencode.jsonc — replace /YOUR/HOME/PATH and YOUR_DIRECTUS_TOKEN"
cp -r global/skills/* ~/.config/opencode/skills/

echo ""
echo "✓ Done. Manual steps:"
echo "1. opencode auth login"
echo "2. Copy and rename config:"
echo "   cp global/opencode-config.example.jsonc ~/.config/opencode/opencode.jsonc"
echo "   Then edit: replace /YOUR/HOME/PATH and YOUR_DIRECTUS_TOKEN"
echo "   Skip if opencode.jsonc already exists — do NOT overwrite"
echo "3. On first run — select your model"
echo "4. opencode mcp list — verify servers"
