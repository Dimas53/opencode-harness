.PHONY: help link setup init init-adopt analyze verify update dod mcp uninstall uninstall-full

.DEFAULT_GOAL := help

help:
	@echo "opencode-harness -- commands:"
	@echo ""
	@echo "  make setup          -- install harness on a new machine"
	@echo "  make init           -- initialize a new project"
	@echo "                        PROJECT=/path/to/project"
	@echo "  make init-adopt     -- connect harness to existing project"
	@echo "                        PROJECT=/path/to/project"
	@echo "  make analyze        -- run project analysis"
	@echo "                        PROJECT=/path/to/project"
	@echo "  make verify         -- verify harness installation"
	@echo "  make update         -- update harness from repository"
	@echo "  make dod            -- run Definition of Done checks"
	@echo "                        (uncommitted check + cyrillic scan + docs lag)"
	@echo "  make uninstall      -- remove harness files (symlink, skills, AGENTS.md)"
	@echo "  make uninstall-full -- remove harness + OpenCode CLI + RTK"
	@echo ""
	@echo "  make link          -- create ~/.opencode-harness symlink"
	@echo ""
	@echo "  Primary path: shortcuts new / adopt / analyze inside OpenCode"

setup:
	@echo "Setting up opencode-harness..."
	@./scripts/install.sh
	@echo "✓ Setup complete. Run: make verify"

link:
	@ln -sf "$(shell pwd)" ~/.opencode-harness
	@echo "✓ Symlink created: ~/.opencode-harness → $(shell pwd)"
	@echo "  Run this once after cloning to enable update-harness shortcut"

init:
	@test -n "$(PROJECT)" || (echo "✗ PROJECT required. Usage: make init PROJECT=/path/to/project"; exit 1)
	@mkdir -p "$(PROJECT)"
	@./scripts/init-project.sh $(PROJECT)

init-adopt:
	@test -n "$(PROJECT)" || (echo "✗ PROJECT required. Usage: make init-adopt PROJECT=/path/to/existing"; exit 1)
	@test -d "$(PROJECT)" || (echo "✗ Directory not found: $(PROJECT)"; exit 1)
	@./scripts/init-adopt.sh $(PROJECT)

analyze:
	@test -n "$(PROJECT)" || (echo "✗ PROJECT required. Usage: make analyze PROJECT=/path/to/project"; exit 1)
	@test -d "$(PROJECT)" || (echo "✗ Directory not found: $(PROJECT)"; exit 1)
	@./scripts/analyze.sh $(PROJECT)

verify:
	@./scripts/verify.sh

update:
	@./scripts/update.sh

dod:
	@./scripts/dod.sh

uninstall:
	@echo "Removing opencode-harness files..."
	@rm -f ~/.opencode-harness
	@rm -rf ~/.config/opencode/skills
	@rm -f ~/.config/opencode/AGENTS.md
	@echo "✓ Harness files removed."
	@echo "  ~/.config/opencode/opencode.jsonc kept (may contain project tokens)."
	@echo "  Delete manually if you want a clean slate."

uninstall-full: uninstall
	@echo "Removing OpenCode CLI..."
	@npm uninstall -g opencode-ai 2>/dev/null && echo "✓ OpenCode removed" || echo "  (not installed)"
	@echo "Removing RTK..."
	@brew uninstall rtk 2>/dev/null && echo "✓ RTK removed" || echo "  (not installed)"
	@echo "✓ Full uninstall complete. The repo directory remains."

session-end:
	@./scripts/session-end.sh

test-quick:
	@echo "=== Quick Tests ==="
	@echo "[bash -n] Checking script syntax..."
	@for s in scripts/*.sh; do bash -n "$$s" || exit 1; done
	@echo "  ✓ All scripts pass syntax check"
	@echo "[bats] Running template tests..."
	@bats tests/templates.bats
	@echo "[bats] Running agent tests..."
	@bats tests/agents.bats

test: test-quick

start:
	@bash scripts/start.sh

mcp:
	@bash scripts/gen-opencode.sh $(PROJECT)