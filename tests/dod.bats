# tests/dod.bats — behavioral tests for scripts/dod.sh
#
# T-D2 (implementation-plan-2 Wave D): the pre-existing test layer only
# checked file existence / bash -n / grep-for-TODO — never that the gate
# actually blocks or passes the right things. These tests run dod.sh
# against real scratch git repos and check exit codes + output, so a
# regression in the cyrillic scan, the .agentignore matcher, or the
# docs-matrix skill-only fallback fails a test instead of staying green.
#
# Each test builds an isolated scratch repo via mktemp -d — nothing here
# touches the real harness repo's git state or ~/.config/opencode.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  SCRATCH="$(mktemp -d)"
  export SCRATCH
  cd "$SCRATCH" || return 1
  git init -q
  git config user.email "test@test"
  git config user.name "test"
}

teardown() {
  cd "$HARNESS_ROOT" || true
  rm -rf "$SCRATCH"
}

# Steps not under test are skipped via DOD_SKIP so each test isolates one
# behavior. cyrillic, uncommitted, and .agentignore are never skippable
# (see scripts/dod.sh header) — that's intentional, they're the ones tested.
QUIET_SKIP="docs-lag,progress,docs-matrix,tests,self-check"

# ── Step 2: Cyrillic scan ─────────────────────────────────────────────────

@test "dod.sh cyrillic scan fails on staged Cyrillic text" {
  printf 'const label = "Готово";\n' > file.js
  git add file.js
  DOD_SKIP="$QUIET_SKIP" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Cyrillic"* ]]
}

@test "dod.sh cyrillic scan passes on clean staged file" {
  printf 'const label = "Done";\n' > file.js
  git add file.js
  DOD_SKIP="$QUIET_SKIP" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
}

# ── Step 8: .agentignore file-level check ──────────────────────────────────

@test "dod.sh .agentignore step fails on staged restricted path" {
  printf 'backups/\n' > .agentignore
  git add .agentignore
  git commit -q -m "add agentignore"
  mkdir -p backups
  printf 'dump' > backups/db.sql
  git add backups/db.sql
  DOD_SKIP="$QUIET_SKIP" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"restricted pattern"* ]]
}

@test "dod.sh .agentignore step passes on staged normal file" {
  printf 'backups/\n' > .agentignore
  git add .agentignore
  git commit -q -m "add agentignore"
  printf 'ok' > normal.txt
  git add normal.txt
  DOD_SKIP="$QUIET_SKIP" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No staged files match .agentignore restrictions"* ]]
}

@test "dod.sh .agentignore step warns (not passes) when the file is absent" {
  printf 'ok' > normal.txt
  git add normal.txt
  DOD_SKIP="$QUIET_SKIP" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"backstop is INACTIVE"* ]]
  [[ "$output" != *"No staged files match .agentignore restrictions"* ]]
}

# ── Step 6: tests — client profile must not fake a pass (T-H1 step 2) ─────
# (deliberately does NOT include "tests" in DOD_SKIP — that's the step under test)

@test "dod.sh step 6 warns TESTS NOT RUN in a client project with a declared test command" {
  printf -- '- **Tests:** `npm run test`\n' > HARNESS.md
  git add HARNESS.md
  DOD_SKIP="docs-lag,progress,docs-matrix,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TESTS NOT RUN"* ]]
  [[ "$output" == *"npm run test"* ]]
}

@test "dod.sh step 6 warns with a setup hint in a client project with no declared test command" {
  printf 'ok' > normal.txt
  git add normal.txt
  DOD_SKIP="docs-lag,progress,docs-matrix,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No test command declared"* ]]
}

# ── Step 5: Docs matrix — skill-only fallback ──────────────────────────────

@test "dod.sh docs-matrix fails on skill-only change without same-day CHANGELOG entry" {
  mkdir -p global/skills/some-skill instructions
  printf '# CHANGELOG\n' > instructions/CHANGELOG.md
  git add global instructions
  git commit -q -m "init"
  printf 'updated body\n' >> global/skills/some-skill/SKILL.md 2>/dev/null || printf 'body\n' > global/skills/some-skill/SKILL.md
  git add global/skills/some-skill/SKILL.md
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Code changed but no docs update found"* ]]
}

@test "dod.sh docs-matrix passes on skill-only change with same-day CHANGELOG entry" {
  mkdir -p global/skills/some-skill instructions
  printf '# CHANGELOG\n' > instructions/CHANGELOG.md
  git add global instructions
  git commit -q -m "init"
  printf 'body\n' > global/skills/some-skill/SKILL.md
  today="$(date +%Y-%m-%d)"
  printf '\n## %s\n- changed some-skill\n' "$today" >> instructions/CHANGELOG.md
  git add global/skills/some-skill/SKILL.md instructions/CHANGELOG.md
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
}

# ── pre-commit hook actually blocks a bad commit ───────────────────────────

@test "pre-commit hook blocks a commit containing Cyrillic" {
  bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH" >/dev/null
  printf 'const label = "Готово";\n' > file.js
  git add file.js
  run git commit -q -m "test"
  [ "$status" -ne 0 ]
  [ "$(git log --oneline | wc -l | tr -d ' ')" -eq 0 ]
}

# ── init-adopt idempotency + .gitignore merge (also exercises T-C1) ───────

@test "init-adopt.sh is idempotent and merges .gitignore with opencode.jsonc" {
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open >/dev/null 2>&1

  [ -f "$SCRATCH/AGENTS.md" ]
  [ -f "$SCRATCH/HARNESS.md" ]
  [ -f "$SCRATCH/PROGRESS.md" ]
  grep -qxF "opencode.jsonc" "$SCRATCH/.gitignore"

  # Second run must not clobber a file that now differs from the template —
  # safe_copy_file backs it up instead of silently overwriting.
  printf '\nCUSTOM LOCAL EDIT\n' >> "$SCRATCH/AGENTS.md"
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open >/dev/null 2>&1
  [ -f "$SCRATCH/AGENTS.md.bak" ]
  grep -q "CUSTOM LOCAL EDIT" "$SCRATCH/AGENTS.md.bak"
}
