#!/bin/bash
echo "=== OpenCode Harness — Verification ==="
echo ""

PASS=0
FAIL=0
WARN=0

check() {
  if eval "$2" &>/dev/null; then
    echo "✓ $1"
    PASS=$((PASS + 1))
  else
    echo "✗ $1 — $3"
    FAIL=$((FAIL + 1))
  fi
}

pass() {
  echo "✓ $1"
  PASS=$((PASS + 1))
}

warn() {
  echo "⚠ $1"
  WARN=$((WARN + 1))
}

fail() {
  echo "✗ $1 — $2"
  FAIL=$((FAIL + 1))
}

check "OpenCode installed" "opencode --version" "run: npm install -g opencode-ai"
if rtk --version &>/dev/null; then
  pass "RTK installed"
else
  if [[ "$(uname -s)" == "Darwin" ]]; then
    fail "RTK installed" "run: brew install rtk-ai/tap/rtk"
  else
    fail "RTK installed" "run: curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh"
  fi
fi
if uv --version &>/dev/null; then
  pass "uv installed"
else
  if [[ "$(uname -s)" == "Darwin" ]]; then
    fail "uv installed" "run: brew install uv"
  else
    fail "uv installed" "run: curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
fi
check "Playwright installed" "npx playwright --version" "run: npm install -g @playwright/mcp"
check "Skills present" "[ $(ls ~/.config/opencode/skills/ | wc -l) -gt 10 ]" "run: make setup"
check "Global AGENTS.md exists" "[ -f ~/.config/opencode/AGENTS.md ]" "run: make setup"
check "opencode.jsonc exists" "[ -f ~/.config/opencode/opencode.jsonc ]" "copy from global/opencode-config.example.jsonc"
check "opencode run works" "opencode run 'echo ok' 2>/dev/null" "opencode run not supported"

check "node available" "command -v node" "install Node.js — merge-opencode-config.sh needs it"
check "python3 available" "command -v python3" "install Python 3 — gen-opencode.sh and update-project.sh need it"

# ── MCP reachability (T-I24) ──────────────────────────────────────────────
# The seven MCP servers were the one finding of two audit passes that never
# got a ticket: verify.sh checked that opencode.jsonc EXISTS but never that
# anything in it comes up. Warnings, never failures — an MCP server that is
# down does not make the harness installation wrong, and `make verify` must
# stay usable offline.
MCP_CONFIG="$HOME/.config/opencode/opencode.jsonc"
if [ ! -f "$MCP_CONFIG" ]; then
  warn "MCP servers — no $MCP_CONFIG to read"
elif ! command -v node >/dev/null 2>&1; then
  warn "MCP servers — node not available to parse the config"
else
  MCP_LIST=$(bash "$(dirname "$0")/merge-opencode-config.sh" --list-mcp "$MCP_CONFIG" 2>/dev/null || true)
  if [ -z "$MCP_LIST" ]; then
    warn "MCP servers — none declared in $MCP_CONFIG"
  else
    while IFS='"'"'|'"'"' read -r name type what; do
      [ -z "$name" ] && continue
      case "$type" in
        local)
          if [ -z "$what" ]; then
            warn "MCP $name — no command declared"
          elif command -v "$what" >/dev/null 2>&1; then
            pass "MCP $name (local, via $what)"
          else
            warn "MCP $name — launcher $what not found in PATH"
          fi
          ;;
        remote)
          # Network only on request, so the default run stays offline.
          if [ "${1:-}" = "--network" ]; then
            if curl -sSf -m 5 -o /dev/null "$what" 2>/dev/null; then
              pass "MCP $name (remote, reachable)"
            else
              warn "MCP $name — $what did not respond within 5s"
            fi
          else
            pass "MCP $name (remote, not contacted — use --network to test)"
          fi
          ;;
        *)
          warn "MCP $name — unknown type: $type"
          ;;
      esac
    done <<< "$MCP_LIST"
  fi
fi

WRONG_PERMS=$(git ls-files -s scripts/*.sh | awk '$1 != "100755"' | awk '{print $4}')
if [ -n "$WRONG_PERMS" ]; then
  fail "Script permissions" "run: git update-index --chmod=+x $WRONG_PERMS"
else
  pass "Script permissions"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed, $WARN warning(s)"

if [ $FAIL -gt 0 ]; then
  echo "⚠ Fix failed checks before using the harness."
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "✓ All required checks passed ($WARN warning(s) above — not blocking)."
  echo "  Run: opencode in your project."
else
  echo "✓ All checks passed. Run: opencode in your project."
fi
