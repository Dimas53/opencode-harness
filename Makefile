SHELL := /bin/bash

.PHONY: help link setup init init-adopt analyze verify update dod mcp self-check uninstall uninstall-lite unadopt check-docs-sync check-docs-refs check-propagation check-skill-triggers context-budget memory-index test test-quick session-end start

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
	@echo "  make check-docs-sync -- verify DoD + Session Start match global/rules/protocols.yaml"
	@echo "  make check-docs-refs -- verify skill references and inventory match the disk"
	@echo "  make check-propagation -- verify delivered files reference nothing harness-only"
	@echo "  make context-budget -- measure what Session Start costs before the first word"
	@echo "  make memory-index   -- refresh the memory/ index inside MEMORY.md"
	@echo "  make check-skill-triggers -- verify no trigger word routes to two skills"
	@echo "                        PROJECT=/path/to/project (default: this repo)"
	@echo "  make test-quick     -- syntax-check scripts + run every tests/*.bats suite"
	@echo "  make test           -- same as test-quick (full suite)"
	@echo "  make self-check     -- verify syntax, permissions and diff before committing"
	@echo "  make uninstall      -- remove everything (harness + OpenCode + RTK + uv)"
	@echo "  make uninstall-lite -- remove harness only, keep OpenCode and RTK"
	@echo "  make unadopt        -- remove all harness files from current project"
	@echo ""
	@echo "  make link          -- create ~/.opencode-harness symlink"
	@echo "  make session-end   -- run Session End protocol"
	@echo "  make start         -- same as make mcp, then launch OpenCode"
	@echo "  make mcp           -- generate opencode.jsonc from .env"
	@echo ""
	@echo "  Inside OpenCode (type these commands):"
	@echo "  new               -- start new project (interview + docs)"
	@echo "  adopt             -- connect harness to existing project"
	@echo "  analyze           -- read-only audit, full project"
	@echo "  analyze <path>    -- focused audit of a file or folder"
	@echo "  fix               -- fix findings from last analysis report"
	@echo "  fix <path>        -- fix findings only for a specific file/folder"
	@echo "  update-harness    -- pull latest harness updates"
	@echo "  update-project    -- bring current project up to date with the harness"
	@echo "  dod               -- run Definition of Done checks"
	@echo "  docs              -- run session-end + update docs"

setup:
	@chmod +x scripts/*.sh
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

check-docs-sync:
	@./scripts/check-dod-sync.sh

check-docs-refs:
	@./scripts/check-docs-refs.sh

check-propagation:
	@./scripts/check-propagation.sh

# T-J0: the numbers that make every compaction ticket checkable. Takes the same
# PROJECT=... convention as `make init`, so measuring a client project reads the
# same way as scaffolding one.
context-budget:
	@./scripts/context-budget.sh $(if $(PROJECT),--project $(PROJECT),)

# T-J4: one line per note in MEMORY.md, so memory/ stops being write-only.
memory-index:
	@./scripts/index-memory.sh

# T-J5: no trigger word may route to two domains — "load all matches" made
# ambiguity expensive in exactly the model that follows rules literally.
check-skill-triggers:
	@./scripts/check-skill-triggers.sh

self-check:
	@echo "=== Self-Check ==="
	@chmod +x scripts/*.sh 2>/dev/null
	@bash -n scripts/*.sh || (echo "✗ syntax error in scripts"; exit 1)
	@echo "✓ Syntax OK"
	@git ls-files -s scripts/*.sh | awk '$$1 != "100755" {print "✗ missing +x: " $$4}' | grep . && exit 1 || echo "✓ Permissions OK"
	@git diff --stat
	@echo "✓ Self-check passed — ready to commit"

uninstall:
	@echo "=== Removing opencode-harness ==="
	@rm -f ~/.opencode-harness
	@rm -rf ~/.config/opencode
	@echo "✓ Config files removed"
	@npm uninstall -g opencode-ai 2>/dev/null && echo "✓ OpenCode CLI removed" || echo "  OpenCode CLI (not installed)"
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		brew uninstall rtk 2>/dev/null && echo "✓ RTK removed" || echo "  RTK (not installed)"; \
		brew uninstall uv 2>/dev/null && echo "✓ uv removed" || echo "  uv (not installed)"; \
	else \
		rm -f ~/.local/bin/rtk && echo "✓ RTK removed" || echo "  RTK (not found)"; \
		rm -f ~/.local/bin/uv ~/.local/bin/uvx && echo "✓ uv removed" || echo "  uv (not found)"; \
	fi
	@rm -rf ~/.config/rtk ~/.config/uv
	@echo ""
	@echo "  Last step: rm -rf $(CURDIR)"

uninstall-lite:
	@echo "=== Removing harness files ==="
	@rm -f ~/.opencode-harness
	@rm -rf ~/.config/opencode
	@echo "✓ Harness files removed. OpenCode and RTK kept."
	@echo ""
	@echo "  Last step: rm -rf $(CURDIR)"

unadopt:
	@bash $(CURDIR)/scripts/unadopt.sh

session-end:
	@./scripts/session-end.sh

test-quick:
	@echo "=== Quick Tests ==="
	@# bats runs each test body as a function under `set -e`. bash 3.2 — which
	@# is still what macOS ships — does not fire errexit inside a function, so
	@# only the LAST command of a test decides its verdict and every earlier
	@# assertion is decorative. Measured 2026-08-22 on this suite: 75 of 105
	@# tests carried more than one assertion, 116 assertions never rendered a
	@# verdict, and three tests had been green for weeks while asserting text
	@# no script printed. A green run under bash 3.x is worse than no run: it
	@# reports a number that means something else. Refuse it.
	@bash -c 'v=$${BASH_VERSINFO[0]}; \
	  if [ "$$v" -lt 4 ]; then \
	    echo "✗ bash $$BASH_VERSION runs these tests, and it cannot fail them."; \
	    echo "  bats needs errexit inside functions; bash 3.x does not provide it,"; \
	    echo "  so only the last assertion of each test would be checked."; \
	    echo "  Install a current bash and make sure it precedes /bin on PATH:"; \
	    echo "      brew install bash"; \
	    echo "  On Linux and in CI this is already the case — nothing to do there."; \
	    exit 1; \
	  fi; \
	  echo "  ✓ bash $$BASH_VERSION — assertions are enforced"'
	@echo "[bash -n] Checking script syntax..."
	@for s in scripts/*.sh; do bash -n "$$s" || exit 1; done
	@echo "  ✓ All scripts pass syntax check"
	@echo "[bats] Running all suites in tests/..."
	@# Glob, not a hand-written list: tests/dod.bats and tests/unadopt.bats
	@# existed for weeks without ever being run because nobody added them
	@# here (T-I5). A new tests/*.bats file is now picked up automatically.
	@bats tests/*.bats

test: test-quick

start:
	@bash scripts/start.sh

mcp:
	@bash scripts/gen-opencode.sh $(PROJECT)