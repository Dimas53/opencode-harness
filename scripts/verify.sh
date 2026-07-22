#!/bin/bash
echo "=== OpenCode Harness — Verification ==="
echo ""

PASS=0
FAIL=0

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

WRONG_PERMS=$(git ls-files -s scripts/*.sh | awk '$1 != "100755"' | awk '{print $4}')
if [ -n "$WRONG_PERMS" ]; then
  fail "Script permissions" "run: git update-index --chmod=+x $WRONG_PERMS"
else
  pass "Script permissions"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
  echo "⚠ Fix failed checks before using the harness."
  exit 1
else
  echo "✓ All checks passed. Run: opencode in your project."
fi
