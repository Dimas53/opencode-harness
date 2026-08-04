#!/bin/bash
set -euo pipefail
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

# Copies src -> dst. If dst already exists and differs from src, backs it up
# to dst.bak first so nothing is silently lost. Never skips the copy — adopt
# always installs the latest template; the backup is the safety net.
safe_copy_file() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && ! diff -q "$src" "$dst" >/dev/null 2>&1; then
    cp "$dst" "$dst.bak"
    echo "  ⚠ $dst already existed and differed — backed up to $dst.bak"
  fi
  cp "$src" "$dst"
}

echo ""
echo "  Copying harness templates to adopt project..."
mkdir -p "$PROJECT/docs" "$PROJECT/memory"
cp -rn "$HARNESS_PATH/templates/docs/." "$PROJECT/docs/"
cp -rn "$HARNESS_PATH/templates/memory/." "$PROJECT/memory/"
safe_copy_file "$HARNESS_PATH/templates/AGENTS.md"    "$PROJECT/AGENTS.md"
safe_copy_file "$HARNESS_PATH/templates/MEMORY.md"    "$PROJECT/MEMORY.md"
safe_copy_file "$HARNESS_PATH/templates/PLAN.md"      "$PROJECT/PLAN.md"
safe_copy_file "$HARNESS_PATH/templates/PROGRESS.md"  "$PROJECT/PROGRESS.md"
safe_copy_file "$HARNESS_PATH/templates/HARNESS.md"   "$PROJECT/HARNESS.md"
safe_copy_file "$HARNESS_PATH/templates/.agentignore" "$PROJECT/.agentignore"
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
