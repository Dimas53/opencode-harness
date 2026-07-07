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

check "OpenCode installed" "opencode --version" "run: npm install -g opencode-ai"
check "RTK installed" "rtk --version" "run: brew install rtk-ai/tap/rtk"
check "uv installed" "uv --version" "run: brew install uv"
check "Playwright installed" "npx playwright --version" "run: npm install -g @playwright/mcp"
check "Skills present" "[ $(ls ~/.config/opencode/skills/ | wc -l) -gt 10 ]" "run: make setup (superpowers plugin)"
check "Global AGENTS.md exists" "[ -f ~/.config/opencode/AGENTS.md ]" "run: make setup"
check "opencode.jsonc exists" "[ -f ~/.config/opencode/opencode.jsonc ]" "copy from global/opencode-config.example.jsonc"
check "opencode run works" "opencode run 'echo ok' 2>/dev/null" "opencode run not supported"

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
  echo "⚠ Fix failed checks before using the harness."
  exit 1
else
  echo "✓ All checks passed. Run: opencode in your project."
fi
