#!/bin/bash
# tests/behavior/fixtures/_lib/make-client-project.sh
# T-H5 (implementation-plan-2 Wave H): shared base fixture for scenarios
# about agent behavior in a CLIENT project — as opposed to the harness's
# own repo. Before this, scenarios cloned the harness itself
# (tests/behavior/fixtures/*/setup.sh used `git clone ... "$HARNESS_ROOT"`),
# which tests a starting state impossible in real client work (see
# 09-propagation-audit.md §1/§6). Scenarios that are genuinely about the
# harness's own mechanics (skill-only-commit, broken-harness-path) keep
# cloning the harness on purpose — this fixture is for everything else.
#
# Creates a minimal scratch git repo, adopts it with the harness
# (init-adopt.sh — installs both hooks, templates, HARNESS.md/memory/),
# and prints ONLY the fixture directory path to stdout (everything else
# to stderr), matching the convention every other fixture here follows.
set -euo pipefail

HARNESS_ROOT="$(git rev-parse --show-toplevel)"

FIXTURE=$(mktemp -d)
cd "$FIXTURE"
git init --quiet >&2
git config user.email "test@test" >&2
git config user.name "test" >&2

mkdir -p app
cat > package.json <<'EOF'
{
  "name": "client-fixture-project",
  "version": "0.0.0",
  "scripts": { "test": "echo no tests yet && exit 0" }
}
EOF
echo "<template/>" > app/placeholder.vue
git add -A >&2
git commit --quiet -m "chore: initial client project scaffold" >&2

bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$FIXTURE" --no-open >&2

echo "$FIXTURE"
