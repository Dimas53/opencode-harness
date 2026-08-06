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
# BSD cp (macOS) exits 1 when -n skips an existing file; GNU cp exits 0.
# -n's whole point is "skip, don't overwrite" — that's success, not a
# failure to propagate under set -e. The `|| true` makes both cp
# implementations behave the same: never fail a second/idempotent adopt run.
cp -rn "$HARNESS_PATH/templates/docs/." "$PROJECT/docs/" || true
cp -rn "$HARNESS_PATH/templates/memory/." "$PROJECT/memory/" || true

# design.md is a UI design-system reference — pure noise in a backend-only
# project (API, CLI, background jobs). Minimal-safe heuristic (T-G3): only
# keep it if this looks like a frontend project (root or nested package.json
# — cheap to check, doesn't need real dependency parsing for a first pass).
# Only remove the copy cp -rn just made (byte-identical to the template) —
# never touch a pre-existing project design.md that cp -rn's -n left alone.
if [ ! -f "$PROJECT/package.json" ] && ! find "$PROJECT" -maxdepth 2 -name package.json -not -path '*/node_modules/*' 2>/dev/null | grep -q .; then
  if [ -f "$PROJECT/docs/design.md" ] && diff -q "$HARNESS_PATH/templates/docs/design.md" "$PROJECT/docs/design.md" >/dev/null 2>&1; then
    rm -f "$PROJECT/docs/design.md"
    echo "  ⚠ No package.json found — skipped docs/design.md (backend/non-UI project)"
  fi
fi
safe_copy_file "$HARNESS_PATH/templates/AGENTS.md"    "$PROJECT/AGENTS.md"
safe_copy_file "$HARNESS_PATH/templates/MEMORY.md"    "$PROJECT/MEMORY.md"
safe_copy_file "$HARNESS_PATH/templates/PLAN.md"      "$PROJECT/PLAN.md"
safe_copy_file "$HARNESS_PATH/templates/PROGRESS.md"  "$PROJECT/PROGRESS.md"
safe_copy_file "$HARNESS_PATH/templates/HARNESS.md"   "$PROJECT/HARNESS.md"
safe_copy_file "$HARNESS_PATH/templates/.agentignore" "$PROJECT/.agentignore"

# Ensure opencode.jsonc (and other secret-bearing patterns) are git-ignored.
# Without this, an adopted project with its own pre-existing .gitignore
# (the common case) never gets these patterns, and gen-opencode.sh's live
# Directus Bearer token can end up staged by `git add -A`.
GI="$PROJECT/.gitignore"
if [ ! -f "$GI" ]; then
  cp "$HARNESS_PATH/templates/.gitignore" "$GI"
  echo "  ✓ .gitignore created from template"
else
  for pat in "opencode.jsonc" ".env"; do
    grep -qxF "$pat" "$GI" || { printf '%s\n' "$pat" >> "$GI"; echo "  ✓ .gitignore: added '$pat'"; }
  done
fi

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
