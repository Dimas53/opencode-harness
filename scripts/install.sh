#!/bin/bash
echo "=== OpenCode Harness Setup ==="

if ! command -v node &> /dev/null; then
	echo "Node.js not found. Install: https://nodejs.org"
	exit 1
fi

npm install -g opencode-ai

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

npx playwright install
opencode plugin add superpowers@git+https://github.com/obra/superpowers.git

mkdir -p ~/.config/opencode/skills

cp global/AGENTS.md ~/.config/opencode/AGENTS.md
cp global/opencode-config.example.jsonc ~/.config/opencode/opencode.jsonc
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
