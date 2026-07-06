#!/bin/bash
echo "=== OpenCode Harness Setup ==="

if ! command -v node &> /dev/null; then
	echo "Node.js not found. Install: https://nodejs.org"
	exit 1
fi

npm install -g opencode-ai
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-git
npm install -g @playwright/mcp

npx playwright install
npx superpowers install

mkdir -p ~/.config/opencode/skills

cp global/AGENTS.md ~/.config/opencode/AGENTS.md
cp global/opencode-config.jsonc ~/.config/opencode/opencode.jsonc
cp -r global/skills/* ~/.config/opencode/skills/

echo ""
echo "✓ Done. Manual steps:"
echo "1. opencode auth login"
echo "2. Add API key to ~/.config/opencode/.env"
echo "3. On first run — select your model"
echo "4. opencode mcp list — verify servers"
