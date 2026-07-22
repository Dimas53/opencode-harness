#!/bin/bash
OS=$(uname -s)
echo "=== OpenCode Harness Setup ==="

if ! command -v node &> /dev/null; then
	echo "Node.js not found. Install: https://nodejs.org"
	exit 1
fi

npm install -g opencode-ai

REQUIRED_VERSION="v1.18.4"
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
if [[ "$OS" == "Darwin" ]]; then
  brew install uv
  echo "✓ uv installed"
elif [[ "$OS" == "Linux" ]]; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo "✓ uv installed"
else
  echo "⚠ uv not installed — install manually: https://docs.astral.sh/uv/"
  echo "  Required for git MCP server and fetch MCP server"
fi

# RTK — token optimization for OpenCode
if [[ "$OS" == "Darwin" ]]; then
	echo "Installing RTK..."
	brew install rtk-ai/tap/rtk
	rtk init -g --opencode
	echo "✓ RTK installed. Run 'rtk gain' to see token savings."
elif [[ "$OS" == "Linux" ]]; then
	echo "Installing RTK..."
	curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
	export PATH="$HOME/.local/bin:$PATH"
	rtk init -g --opencode
	echo "✓ RTK installed. Run 'rtk gain' to see token savings."
	echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
	echo "✓ PATH updated in ~/.bashrc"
else
	echo "⚠ RTK skipped — unsupported OS: $OS. Install manually: https://github.com/rtk-ai/rtk"
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

ln -sf "$(pwd)" ~/.opencode-harness
echo "✓ Symlink created: ~/.opencode-harness → $(pwd)"

# Git identity check
if [ -z "$(git config --global user.email)" ]; then
  echo ""
  echo "⚠️  Git identity not set."
  read -p "  Enter your email for git: " GIT_EMAIL
  read -p "  Enter your name for git: " GIT_NAME
  git config --global user.email "$GIT_EMAIL"
  git config --global user.name "$GIT_NAME"
  echo "✓ Git identity configured"
fi

echo ""
echo "✓ Done. Next steps:"
echo "1. opencode auth login"
echo "2. Check ~/.config/opencode/opencode.jsonc — replace /YOUR/HOME/PATH"
echo "   (If you don't use Directus — delete the YOUR_DIRECTUS_TOKEN line)"
echo "3. On first run — select your model"
