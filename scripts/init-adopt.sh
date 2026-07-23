#!/bin/bash
# Open OpenCode TUI in an adopt project for harness-init
# Usage: make init-adopt PROJECT=/path/to/project [--no-open]

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
	echo "Usage: make init-adopt PROJECT=/path/to/project"
	exit 1
fi

HARNESS_PATH="$(cd "$(dirname "$0")/.." && pwd)"

echo ""
echo "  Copying harness templates to adopt project..."
cp -r "$HARNESS_PATH/templates/docs/" "$PROJECT/docs/"
cp -r "$HARNESS_PATH/templates/memory/" "$PROJECT/memory/"
cp "$HARNESS_PATH/templates/AGENTS.md" "$PROJECT/AGENTS.md"
cp "$HARNESS_PATH/templates/MEMORY.md" "$PROJECT/MEMORY.md"
cp "$HARNESS_PATH/templates/PLAN.md" "$PROJECT/PLAN.md"
cp "$HARNESS_PATH/templates/PROGRESS.md" "$PROJECT/PROGRESS.md"
cp "$HARNESS_PATH/templates/HARNESS.md" "$PROJECT/HARNESS.md"
echo "  Done."
echo ""

bash "$(dirname "$0")/install-hooks.sh" "$PROJECT"

if [ "$NO_OPEN" -eq 1 ]; then
  echo "  Templates copied. Skipping OpenCode launch."
  exit 0
fi

cd "$PROJECT" || exit 1
opencode --prompt "Load ~/.config/opencode/skills/harness-init/agent-adopt.md" || {
  echo "✗ OpenCode failed to start. Check: opencode --version"
  exit 1
}
