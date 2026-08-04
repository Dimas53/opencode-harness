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
if [[ "$OS" == "Linux" ]]; then
  sudo npx playwright install-deps 2>/dev/null || true
fi

mkdir -p ~/.config/opencode/skills

# ── AGENTS.md merge ──
if [ -f ~/.config/opencode/AGENTS.md ]; then
  echo ""
  echo "  → ~/.config/opencode/AGENTS.md already exists"
  printf "    Add harness rules to the end of your existing file? (y/n): "
  read -r answer
  if [ "$answer" = "y" ]; then
    cp ~/.config/opencode/AGENTS.md ~/.config/opencode/AGENTS.md.bak
    {
      echo ""
      echo "# --- Harness Rules (appended by install.sh) ---"
      cat global/AGENTS.md
    } >> ~/.config/opencode/AGENTS.md
    echo "  ✓ Harness rules appended (backup: AGENTS.md.bak)"
  else
    echo "  ⚠ Skipped — harness may work suboptimally without global rules"
  fi
else
  cp global/AGENTS.md ~/.config/opencode/AGENTS.md
  echo "  → Created ~/.config/opencode/AGENTS.md"
fi

# ── opencode.jsonc merge ──
if [ ! -f ~/.config/opencode/opencode.jsonc ]; then
    cp global/opencode-config.example.jsonc ~/.config/opencode/opencode.jsonc
    sed -i.bak "s|/YOUR/HOME/PATH|$HOME|g" ~/.config/opencode/opencode.jsonc
    rm -f ~/.config/opencode/opencode.jsonc.bak
    echo "  → Created ~/.config/opencode/opencode.jsonc"
else
    echo ""
    echo "  → Merging MCP servers into ~/.config/opencode/opencode.jsonc..."
    TEMPLATE_TMP=$(mktemp)
    sed "s|/YOUR/HOME/PATH|$HOME|g" global/opencode-config.example.jsonc > "$TEMPLATE_TMP"
    node -e '
      const fs = require("fs");
      const tplPath = process.argv[1];
      const cfgPath = process.argv[2];

      function parseJSONC(filePath) {
        const raw = fs.readFileSync(filePath, "utf8");
        const clean = raw.replace(/\/\/.*$/gm, "").replace(/,\s*([}\]])/g, "$1");
        return JSON.parse(clean);
      }

      const existing = parseJSONC(cfgPath);
      const template = parseJSONC(tplPath);

      existing.mcp = existing.mcp || {};
      const tplMcp = template.mcp || {};
      const added = [];

      for (const [key, value] of Object.entries(tplMcp)) {
        if (!existing.mcp[key]) {
          existing.mcp[key] = value;
          added.push(key);
        }
      }

      if (added.length > 0) {
        fs.writeFileSync(cfgPath, JSON.stringify(existing, null, 2) + "\n");
        console.log("  ✓ Added MCP servers: " + added.join(", "));
      } else {
        console.log("  ✓ All harness MCP servers already present");
      }
    ' "$TEMPLATE_TMP" ~/.config/opencode/opencode.jsonc
    rm -f "$TEMPLATE_TMP"
fi
cp -r global/skills/* ~/.config/opencode/skills/

ln -sf "$(pwd)" ~/.opencode-harness
echo "✓ Symlink created: ~/.opencode-harness → $(pwd)"

# post-commit is installed ONLY here (harness's own repo), never into
# adopted projects via install-hooks.sh — its job (mirror global/skills/)
# only makes sense where global/skills/ actually exists, i.e. this repo.
# See scripts/install-hooks.sh header for the pre-commit installation path,
# which IS meant to run in every project.
cp hooks/post-commit .git/hooks/post-commit
chmod +x .git/hooks/post-commit
echo "✓ post-commit hook installed"

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

# ── Playwright availability check (project context only) ──
if [ -f package.json ]; then
  if ! npx playwright --version >/dev/null 2>&1; then
    echo ""
    echo "⚠️  @playwright/test not found in this project."
    echo "    Required for e2e UI verification via agent-e2e."
    printf "    Install now? (y/n): "
    read -r answer
    if [ "$answer" = "y" ]; then
      npm install -D @playwright/test && npx playwright install
      echo "✓ Playwright installed"
    else
      echo "  ⚠ Skipped — e2e UI verification will not work until installed."
      echo "    Run later: npm install -D @playwright/test && npx playwright install"
    fi
  fi
fi

echo ""
echo "✓ Done. Next steps:"
echo "1. opencode auth login"
echo "2. Check ~/.config/opencode/opencode.jsonc — verify MCP servers are correct"
echo "3. On first run — select your model"
