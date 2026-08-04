#!/bin/bash
set -euo pipefail
# Scaffold a new project and open OpenCode TUI for harness-init
# Usage: make init PROJECT=/path/to/project [--no-open]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

PROJECT=""
NO_OPEN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-open)
      NO_OPEN=1
      shift
      ;;
    *)
      if [ -z "$PROJECT" ]; then
        PROJECT="$1"
      fi
      shift
      ;;
  esac
done

if ! command -v opencode &>/dev/null; then
  echo "✗ opencode not found. Run: make setup"
  exit 1
fi

if [ -z "$PROJECT" ]; then
	echo "Usage: make init PROJECT=/path/to/project [--no-open]"
	exit 1
fi

mkdir -p "$PROJECT"

# Copies src -> dst. If dst already exists and differs from src, backs it up
# to dst.bak first so nothing is silently lost. Never skips the copy — init
# always installs the latest template; the backup is the safety net.
safe_copy_file() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && ! diff -q "$src" "$dst" >/dev/null 2>&1; then
    cp "$dst" "$dst.bak"
    echo "  ⚠ $dst already existed and differed — backed up to $dst.bak"
  fi
  cp "$src" "$dst"
}

mkdir -p "$PROJECT/docs" "$PROJECT/memory"
cp -rn "$TEMPLATES_DIR/docs/." "$PROJECT/docs/"
cp -rn "$TEMPLATES_DIR/memory/." "$PROJECT/memory/"
safe_copy_file "$TEMPLATES_DIR/AGENTS.md"    "$PROJECT/AGENTS.md"
safe_copy_file "$TEMPLATES_DIR/MEMORY.md"    "$PROJECT/MEMORY.md"
safe_copy_file "$TEMPLATES_DIR/PLAN.md"      "$PROJECT/PLAN.md"
safe_copy_file "$TEMPLATES_DIR/PROGRESS.md"  "$PROJECT/PROGRESS.md"
safe_copy_file "$TEMPLATES_DIR/HARNESS.md"   "$PROJECT/HARNESS.md"
safe_copy_file "$TEMPLATES_DIR/.agentignore" "$PROJECT/.agentignore"

if [ ! -f "$PROJECT/.gitignore" ]; then
  cp "$TEMPLATES_DIR/.gitignore" "$PROJECT/.gitignore"
  echo "  ✓ .gitignore copied"
fi

ENV_FILE="$PROJECT/.env"
if [ ! -f "$ENV_FILE" ]; then
  cp "$TEMPLATES_DIR/.env.example" "$ENV_FILE"
  echo "  ✓ .env created from template (fill DIRECTUS_URL + MCP_DIRECTUS_TOKEN)"
else
  # Never overwrite an existing .env — only append the Directus MCP vars if missing.
  added=0
  if ! grep -q '^DIRECTUS_URL=' "$ENV_FILE"; then
    printf '\n# Directus MCP\nDIRECTUS_URL=\n' >> "$ENV_FILE"; added=1
  fi
  if ! grep -q '^MCP_DIRECTUS_TOKEN=' "$ENV_FILE"; then
    printf 'MCP_DIRECTUS_TOKEN=\n' >> "$ENV_FILE"; added=1
  fi
  if [ "$added" -eq 1 ]; then
    echo "  ✓ .env updated: added DIRECTUS_URL + MCP_DIRECTUS_TOKEN (fill them in)"
  else
    echo "  ✓ .env already has Directus MCP vars"
  fi
fi

if [ ! -d "$PROJECT/.git" ]; then
  cd "$PROJECT" && git init && git add . && \
  git commit -m "chore: initialize project with harness scaffold" >/dev/null 2>&1
  cd "$OLDPWD" || true
  echo "  ✓ Git repository initialized"
fi

echo ""
echo "  Project scaffold created at $PROJECT"
echo ""

bash "$(dirname "$0")/install-hooks.sh" "$PROJECT"

if [ "$NO_OPEN" -eq 1 ]; then
  echo "  Skipping OpenCode launch (--no-open)."
  exit 0
fi

echo ""
echo "  Opening OpenCode now..."
echo ""

cd "$PROJECT" || exit 1
opencode --prompt "Load ~/.config/opencode/skills/harness-init/agent-new-project.md" || {
  echo "✗ OpenCode failed to start. Check: opencode --version"
  exit 1
}
