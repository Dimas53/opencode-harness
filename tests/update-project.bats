# tests/update-project.bats — regression tests for T-I14 step 3
#
# The optional CI gate (H-DEC-4: "never installed silently") was only ever
# offered by `new`/`adopt`, so a project adopted before it existed had no way
# to hear about it. update-project.sh now offers it — but as a question of its
# own, because folding it into the bulk "apply the updates above? (y/n)"
# prompt would install it as a side effect of agreeing to something else,
# which is exactly what H-DEC-4 forbids.

setup() {
  HARNESS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HARNESS_ROOT
  export OPENCODE_HARNESS_PATH="$HARNESS_ROOT"
  SCRATCH="$(mktemp -d)"
  export SCRATCH
  cd "$SCRATCH" || return 1
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  git remote add origin "git@github.com:someone/proj.git"
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open >/dev/null 2>&1
}

teardown() {
  cd "$HARNESS_ROOT" || true
  rm -rf "$SCRATCH"
}

@test "update-project offers the CI gate when it is not installed" {
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" == *"CI gate — not installed"* ]]
  [[ "$output" == *"[none / github / gitlab]"* ]]
}

@test "answering none installs no CI file" {
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [ ! -f "$SCRATCH/.github/workflows/dod.yml" ]
  [ ! -f "$SCRATCH/.gitlab-ci.yml" ]
}

@test "answering github installs the workflow" {
  run bash -c "printf 'n\ngithub\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [ -f "$SCRATCH/.github/workflows/dod.yml" ]
  grep -q "bash .opencode-harness-ci/scripts/dod.sh" "$SCRATCH/.github/workflows/dod.yml"
}

@test "an installed CI gate is not offered again" {
  bash -c "printf 'n\ngithub\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" != *"CI gate — not installed"* ]]
}

# The point of the separate question: bulk-declining must not decline the CI
# gate, and bulk-accepting must not install it.
@test "the CI gate is asked separately from the bulk update" {
  rm -f "$SCRATCH/PLAN.md"
  run bash -c "printf 'y\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [ -f "$SCRATCH/PLAN.md" ]                        # bulk 'y' still applied
  [ ! -f "$SCRATCH/.github/workflows/dod.yml" ]    # CI 'none' respected
}

# GitLab pipelines are the project's entire CI definition; adding one job is
# not worth clobbering it, so an existing file is reported, never replaced.
@test "an existing .gitlab-ci.yml is never overwritten" {
  printf 'stages:\n  - test\nbuild:\n  script: echo hi\n' > "$SCRATCH/.gitlab-ci.yml"
  run bash -c "printf 'n\ngitlab\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" == *"not overwritten"* ]]
  grep -q "script: echo hi" "$SCRATCH/.gitlab-ci.yml"
  ! grep -q "opencode-harness-ci" "$SCRATCH/.gitlab-ci.yml"
}

# A .gitlab-ci.yml that already carries a dod job counts as installed — the
# check is the job, not the filename.
@test "a .gitlab-ci.yml with a dod job counts as installed" {
  printf 'dod:\n  script: echo gate\n' > "$SCRATCH/.gitlab-ci.yml"
  run bash -c "printf 'n\nnone\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [[ "$output" != *"CI gate — not installed"* ]]
}

# An agent cannot forward the user's keystrokes into a subprocess, and it is
# forbidden from answering for them. Without these flags the script ran, hit
# EOF and silently did nothing — indistinguishable from "already up to date",
# which is how the first live run in a client project ended.
@test "--dry-run prints the plan and changes nothing" {
  rm -f "$SCRATCH/PLAN.md"
  run bash -c "bash '$HARNESS_ROOT/scripts/update-project.sh' --dry-run"
  [ "$status" -eq 0 ]
  [[ "$output" == *"dry run — nothing applied"* ]]
  [ ! -f "$SCRATCH/PLAN.md" ]
}

@test "--yes applies without a prompt, --ci carries the CI answer" {
  rm -f "$SCRATCH/PLAN.md"
  run bash -c "bash '$HARNESS_ROOT/scripts/update-project.sh' --yes --ci=none < /dev/null"
  [ "$status" -eq 0 ]
  [ -f "$SCRATCH/PLAN.md" ]
  [ ! -f "$SCRATCH/.github/workflows/dod.yml" ]
}

@test "--ci=github installs the workflow without any prompt" {
  run bash -c "bash '$HARNESS_ROOT/scripts/update-project.sh' --yes --ci=github < /dev/null"
  [ "$status" -eq 0 ]
  [ -f "$SCRATCH/.github/workflows/dod.yml" ]
}

# The important half: no flags and no terminal must NOT look like success.
@test "no flags and no terminal exits with a message, not a silent no-op" {
  rm -f "$SCRATCH/PLAN.md"
  run bash -c "bash '$HARNESS_ROOT/scripts/update-project.sh' < /dev/null"
  [ "$status" -eq 2 ]
  [[ "$output" == *"not a terminal"* ]]
  [[ "$output" == *"Do NOT answer on the user's behalf"* ]]
  [ ! -f "$SCRATCH/PLAN.md" ]
}

@test "--refresh-agents honours --yes and refuses silently-nothing without it" {
  cp "$HARNESS_ROOT/templates/AGENTS.md" "$SCRATCH/AGENTS.md"
  python3 - "$SCRATCH/AGENTS.md" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("## Git Workflow", "## Git Workflow\n\n- project-specific line", 1)
open(p, "w").write(s)
PY
  run bash -c "bash '$HARNESS_ROOT/scripts/update-project.sh' --refresh-agents < /dev/null"
  [ "$status" -eq 2 ]
  [[ "$output" == *"not a terminal"* ]]

  run bash -c "bash '$HARNESS_ROOT/scripts/update-project.sh' --refresh-agents --yes < /dev/null"
  [ "$status" -eq 0 ]
  [[ "$output" == *"refreshed"* ]]
}

# ── --seed-markers (T-J17.3) ─────────────────────────────────────────────────
# Marking up a pre-T-G-U6 AGENTS.md was done by hand three times before it was
# scripted. What makes it worth a test rather than a one-liner: --refresh-agents
# matches regions by POSITION, so a seeded file with the wrong count or order
# would let the next refresh overwrite project content with template
# placeholders — silently, and only on the run after the mistake.

@test "seed-markers wraps existing sections and seeds absent ones" {
  python3 - "$SCRATCH/AGENTS.md" <<'PY'
import sys
# An AGENTS.md shaped like the ones adopted before markers existed: it has
# the DoD checklist, Git Workflow and Docs Update Matrix, but no Database
# Migrations section at all.
open(sys.argv[1], "w").write("""# Proj — Project Rules

## Stack Skills
- something project-specific

### CONTEXT.md — update if session includes any of:
```
[ ] New collection
```

### Hard rules — no exceptions:
```
RULE 1: no
```

---

## Git Workflow

### When to commit
- after a milestone

---

## MCP Servers Available

| MCP | Use for |
|-----|---------|

---

## Docs Update Matrix

| File | Updated by | Trigger |
|------|-----------|---------|
""")
PY
  run bash "$HARNESS_ROOT/scripts/update-project.sh" --seed-markers
  [ "$status" -eq 0 ]
  [ "$(grep -cF '# === HARNESS-MANAGED START' "$SCRATCH/AGENTS.md")" -eq 4 ]
  [ "$(grep -cF '# === HARNESS-MANAGED END ===' "$SCRATCH/AGENTS.md")" -eq 4 ]
  # project content survives, outside the markers
  grep -q "something project-specific" "$SCRATCH/AGENTS.md"
  grep -q "MCP Servers Available" "$SCRATCH/AGENTS.md"
}

@test "seed-markers then refresh fills the seeded region from the template" {
  cp "$HARNESS_ROOT/templates/AGENTS.md" "$SCRATCH/AGENTS.md"
  python3 - "$SCRATCH/AGENTS.md" <<'PY'
import sys
# strip the markers to simulate a project that predates them
p = sys.argv[1]
lines = [l for l in open(p).read().split("\n")
         if not l.startswith("# === HARNESS-MANAGED")]
open(p, "w").write("\n".join(lines))
PY
  run bash "$HARNESS_ROOT/scripts/update-project.sh" --seed-markers
  [ "$status" -eq 0 ]
  run bash "$HARNESS_ROOT/scripts/update-project.sh" --refresh-agents --yes
  [ "$status" -eq 0 ]
  grep -q "Database Migrations" "$SCRATCH/AGENTS.md"
  grep -q "down.sql" "$SCRATCH/AGENTS.md"
}

@test "seed-markers refuses to run twice" {
  cp "$HARNESS_ROOT/templates/AGENTS.md" "$SCRATCH/AGENTS.md"
  run bash "$HARNESS_ROOT/scripts/update-project.sh" --seed-markers
  [ "$status" -eq 0 ]
  [[ "$output" == *"already has HARNESS-MANAGED markers"* ]]
  [ "$(grep -cF '# === HARNESS-MANAGED START' "$SCRATCH/AGENTS.md")" -eq 4 ]
}

# ── project-root guard (T-J17.1) ─────────────────────────────────────────────
# The script creates files in $(pwd). Run from a parent directory it used to
# scaffold a whole project there, silently — which is what happened to a
# scratch folder on 2026-08-20.

@test "update-project stops when cwd does not look like a project root" {
  NOT_A_ROOT="$(mktemp -d)"
  cd "$NOT_A_ROOT" || return 1
  run bash -c "printf 'n\n' | bash '$HARNESS_ROOT/scripts/update-project.sh'"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not look like a project root"* ]]
  [ ! -f "$NOT_A_ROOT/PROGRESS.md" ]
  [ ! -f "$NOT_A_ROOT/AGENTS.md" ]
  cd "$HARNESS_ROOT" || true
  rm -rf "$NOT_A_ROOT"
}

@test "update-project exits with a named flag when nobody answers the root question" {
  NOT_A_ROOT="$(mktemp -d)"
  cd "$NOT_A_ROOT" || return 1
  run bash -c "bash '$HARNESS_ROOT/scripts/update-project.sh' < /dev/null"
  [ "$status" -eq 2 ]
  [[ "$output" == *"--yes"* ]]
  cd "$HARNESS_ROOT" || true
  rm -rf "$NOT_A_ROOT"
}
