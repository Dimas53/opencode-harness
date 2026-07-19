#!/bin/bash
# Scaffold a new project and open OpenCode TUI for harness-init
# Usage: make init PROJECT=/path/to/project [--no-open]

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
cp -r templates/docs/ "$PROJECT/docs/"
cp -r templates/memory/ "$PROJECT/memory/"
cp templates/AGENTS.md "$PROJECT/AGENTS.md"
cp templates/MEMORY.md "$PROJECT/MEMORY.md"
cp templates/PLAN.md "$PROJECT/PLAN.md"
cp templates/PROGRESS.md "$PROJECT/PROGRESS.md"
cp templates/HARNESS.md "$PROJECT/HARNESS.md"

if [ ! -f "$PROJECT/.gitignore" ]; then
  cp templates/.gitignore "$PROJECT/.gitignore"
  echo "  ✓ .gitignore copied"
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
