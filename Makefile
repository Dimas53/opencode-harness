.PHONY: setup init init-existing analyze verify update

setup:
	@./scripts/install.sh

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
