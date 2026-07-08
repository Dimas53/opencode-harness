.PHONY: setup init init-existing analyze verify update

setup:
	@./scripts/install.sh

init:
	@./scripts/init-project.sh $(PROJECT)

init-existing:
	@./scripts/init-existing.sh $(PROJECT)

analyze:
	@./scripts/analyze.sh $(PROJECT)

verify:
	@./scripts/verify.sh

update:
	@./scripts/update.sh
