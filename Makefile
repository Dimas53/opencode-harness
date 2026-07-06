.PHONY: setup setup-lite init init-existing docs-only

setup:
	@./scripts/install.sh

setup-lite:
	@cp global/AGENTS.md ~/.config/opencode/AGENTS.md
	@cp global/opencode-config.jsonc ~/.config/opencode/opencode.jsonc
	@cp -r global/skills/* ~/.config/opencode/skills/
	@echo "✓ Global files copied."

init:
	@./scripts/init-project.sh $(PROJECT)

init-existing:
	@./scripts/init-existing.sh $(PROJECT)

docs-only:
	@cp -r templates/docs/ $(PROJECT)/docs/
	@echo "✓ Doc templates copied to $(PROJECT)/docs/"
