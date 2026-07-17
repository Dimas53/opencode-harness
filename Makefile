.PHONY: help link setup init init-existing analyze verify update dod

.DEFAULT_GOAL := help

help:
	@echo "opencode-harness -- commands:"
	@echo ""
	@echo "  make setup          -- install harness on a new machine"
	@echo "  make init           -- initialize a new project"
	@echo "                        PROJECT=/path/to/project"
	@echo "  make init-existing  -- connect harness to existing project"
	@echo "                        PROJECT=/path/to/project"
	@echo "  make analyze        -- run project analysis"
	@echo "                        PROJECT=/path/to/project"
	@echo "  make verify         -- verify harness installation"
	@echo "  make update         -- update harness from repository"
	@echo "  make dod            -- run Definition of Done checks"
	@echo "                        (uncommitted check + cyrillic scan + docs lag)"
	@echo ""
	@echo "  make link          -- create ~/.opencode-harness symlink"
	@echo ""
	@echo "  Primary path: shortcuts new / existing / analyze inside OpenCode"

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

init-existing:
	@test -n "$(PROJECT)" || (echo "✗ PROJECT required. Usage: make init-existing PROJECT=/path/to/existing"; exit 1)
	@test -d "$(PROJECT)" || (echo "✗ Directory not found: $(PROJECT)"; exit 1)
	@./scripts/init-existing.sh $(PROJECT)

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