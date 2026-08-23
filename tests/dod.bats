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

# The one-line case above cannot catch the failure this covers. The scan used
# to end in `grep -q`, which leaves at the first match; the greps upstream then
# took SIGPIPE, `set -o pipefail` turned the pipeline into status 141, and the
# `if` read false — Cyrillic present, nothing reported. It only shows when the
# diff is large enough that the writer is still writing when `-q` leaves, so a
# short fixture passed on macOS for months while CI (GNU grep, which leaves at
# once) failed. Keep this file big.
@test "dod.sh cyrillic scan fails on a large staged file, not only a short one" {
  python3 - > big.js <<'PY'
print('const label = "Готово";')
for i in range(20000):
    print(f'const filler{i} = "line {i}";')
PY
  git add big.js
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
  # Skill-only fallback is a harness-repo CODE_DIRS mechanic (T-H1's
  # client-profile branch treats any *.md, including SKILL.md, as
  # documentation by design — see is_doc_file() in dod.sh) — mark this
  # fixture as the harness repo so it exercises that path, not T-H1's.
  mkdir -p scripts global/skills/some-skill instructions
  touch scripts/init-project.sh
  printf '# CHANGELOG\n' > instructions/CHANGELOG.md
  git add scripts global instructions
  git commit -q -m "init"
  printf 'updated body\n' >> global/skills/some-skill/SKILL.md 2>/dev/null || printf 'body\n' > global/skills/some-skill/SKILL.md
  git add global/skills/some-skill/SKILL.md
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Code changed but no docs update found"* ]]
}

@test "dod.sh docs-matrix passes on skill-only change with same-day CHANGELOG entry" {
  mkdir -p scripts global/skills/some-skill instructions
  touch scripts/init-project.sh
  printf '# CHANGELOG\n' > instructions/CHANGELOG.md
  git add scripts global instructions
  git commit -q -m "init"
  printf 'body\n' > global/skills/some-skill/SKILL.md
  today="$(date +%Y-%m-%d)"
  printf '\n## %s\n- changed some-skill\n' "$today" >> instructions/CHANGELOG.md
  git add global/skills/some-skill/SKILL.md instructions/CHANGELOG.md
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
}

# ── Step 5: Docs matrix — client profile (T-H1/H-DEC-1) ────────────────────

@test "dod.sh docs-matrix fails in a client project when no doc at all was touched" {
  mkdir -p app
  printf '<template>x</template>\n' > app/placeholder.vue
  git add app
  git commit -q -m "init"
  printf '<template>changed</template>\n' > app/placeholder.vue
  git add app/placeholder.vue
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Code changed but no docs update found"* ]]
}

@test "dod.sh docs-matrix warns (not fails) in a client project when only PROGRESS.md was touched" {
  mkdir -p app
  printf '<template>x</template>\n' > app/placeholder.vue
  printf '# Progress\n' > PROGRESS.md
  git add app PROGRESS.md
  git commit -q -m "init"
  printf '<template>changed</template>\n' > app/placeholder.vue
  printf '# Progress\n- did a thing\n' > PROGRESS.md
  git add app/placeholder.vue PROGRESS.md
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"only PROGRESS.md updated"* ]]
}

@test "dod.sh docs-matrix passes in a client project when a real doc was touched" {
  mkdir -p app docs
  printf '<template>x</template>\n' > app/placeholder.vue
  git add app
  git commit -q -m "init"
  printf '<template>changed</template>\n' > app/placeholder.vue
  printf '# Feature\n' > docs/feature.md
  git add app/placeholder.vue docs/feature.md
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Code changes accompanied by docs update"* ]]
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

# ── docs-lag: one commit must get one verdict (T-I27) ─────────────────────
#
# The gate ran in two modes that disagreed about the same commit: pre-commit
# counted the lag before the commit existed (3 -> pass), the post-commit
# guard counted it after (4 -> fail) and rolled back a commit pre-commit had
# just approved, blaming --no-verify. No fixture ever stacked 4 non-docs
# commits in a row, which is why two code audits missed it.

lag_setup() {
  mkdir -p docs
  echo "initial docs" > docs/README.md
  git add docs/README.md
  git commit -q -m "docs: initial"
  for i in 1 2 3; do
    echo "$i" > "file$i.txt"
    git add "file$i.txt"
    git commit -q -m "chore: commit $i"
  done
}

@test "docs-lag: pre-commit blocks the 4th non-docs commit instead of letting the guard roll it back" {
  lag_setup
  echo "4" > file4.txt
  git add file4.txt

  # Pre-commit sees 3 landed commits + the one being created = 4 > 3 -> block.
  DOD_SKIP="progress,docs-matrix,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"would be 4 commits behind"* ]]
}

@test "docs-lag: pre-commit and post-commit agree on the same commit" {
  lag_setup
  echo "4" > file4.txt
  git add file4.txt
  git commit -q -m "chore: commit 4" --no-verify

  # Same commit, both modes: post-commit (manual) sees 4 landed commits.
  DOD_SKIP="progress,docs-matrix,tests,self-check" run bash "$HARNESS_ROOT/scripts/dod.sh"
  local manual_status="$status"

  git reset -q --soft HEAD~1
  DOD_SKIP="progress,docs-matrix,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq "$manual_status" ]
}

@test "docs-lag: a docs commit still passes pre-commit at the boundary" {
  lag_setup
  echo "more docs" >> docs/README.md
  git add docs/README.md
  DOD_SKIP="progress,docs-matrix,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
}

@test "post-commit guard does not roll back a commit the pre-commit gate passed" {
  lag_setup
  bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH" >/dev/null

  # A passing pre-commit run, recorded in .dod-run.log, then a DoD state the
  # manual mode fails: the guard must warn, not reset.
  printf '%s|pre-commit|pass=8|fail=0|warn=0|skip=none|pass\n' "$(date '+%Y-%m-%dT%H:%M:%S')" >> .dod-run.log
  echo "4" > file4.txt
  git add file4.txt
  git commit -q -m "chore: commit 4" --no-verify
  local head_before
  head_before="$(git rev-parse HEAD)"

  run bash .git/hooks/post-commit
  [ "$(git rev-parse HEAD)" = "$head_before" ]
  [ "$(git reflog | grep -c 'reset: moving to HEAD~1')" -eq 0 ]
}

@test "post-commit guard still rolls back when no pre-commit run is recorded" {
  lag_setup
  bash "$HARNESS_ROOT/scripts/install-hooks.sh" "$SCRATCH" >/dev/null
  rm -f .dod-run.log

  echo "4" > file4.txt
  git add file4.txt
  git commit -q -m "chore: commit 4" --no-verify
  local head_before
  head_before="$(git rev-parse HEAD)"

  run bash .git/hooks/post-commit
  [ "$(git rev-parse HEAD)" != "$head_before" ]
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

# ── Step 5: lock files are not code that owes documentation (T-J24) ───────
#
# In a client project is_doc_file() inverts the test — anything that is not a
# .md or under docs/ is code — so `package-lock.json` demanded a docs update.
# That leaves an empty line in docs/ or --no-verify, and the gate should hand
# out neither. It kept `ci` red in harness-ci-live: npm ci needs the lock file,
# the lock file could not be committed.

@test "dod.sh docs-matrix passes a lock-file-only commit in a client project" {
  mkdir -p app
  printf '<template>x</template>\n' > app/placeholder.vue
  git add app
  git commit -q -m "init"
  printf '{"lockfileVersion":3}\n' > package-lock.json
  git add package-lock.json
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Only generated files changed"* ]]
  [[ "$output" != *"Code changed but no docs update found"* ]]
}

@test "dod.sh docs-matrix ignores a lock file nested in a monorepo subdir" {
  mkdir -p frontend
  printf 'x\n' > frontend/keep.txt
  git add frontend
  git commit -q -m "init"
  printf 'lockfileVersion: 6\n' > frontend/pnpm-lock.yaml
  git add frontend/pnpm-lock.yaml
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Only generated files changed"* ]]
}

# The exemption must not launder the code sitting next to the lock file.
@test "dod.sh docs-matrix still fails when real code rides along with a lock file" {
  mkdir -p app
  printf '<template>x</template>\n' > app/placeholder.vue
  git add app
  git commit -q -m "init"
  printf '<template>changed</template>\n' > app/placeholder.vue
  printf '{"lockfileVersion":3}\n' > package-lock.json
  git add app/placeholder.vue package-lock.json
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Code changed but no docs update found"* ]]
}

# package.json is where a dependency decision worth documenting is made.
@test "dod.sh docs-matrix still fails on package.json alone" {
  mkdir -p app
  printf 'x\n' > app/keep.txt
  git add app
  git commit -q -m "init"
  printf '{"dependencies":{"left-pad":"^1.0.0"}}\n' > package.json
  git add package.json
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Code changed but no docs update found"* ]]
}

@test "dod.sh docs-matrix says out loud when it ignored a generated file" {
  mkdir -p app docs
  printf '<template>x</template>\n' > app/placeholder.vue
  git add app
  git commit -q -m "init"
  printf '<template>changed</template>\n' > app/placeholder.vue
  printf '# Feature\n' > docs/feature.md
  printf '{"lockfileVersion":3}\n' > package-lock.json
  git add app/placeholder.vue docs/feature.md package-lock.json
  DOD_SKIP="docs-lag,progress,tests,self-check" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"generated files not counted as code: package-lock.json"* ]]
}

# ── A freshly adopted project must survive its own first commit (T-J20) ───
#
# init-adopt leaves memory/ holding nothing but .gitkeep and a MEMORY.md with
# no index — so the memory-index warning's guard was true, `memory/*.md`
# matched nothing, `ls` exited 1, pipefail carried it out and set -e killed
# the gate on the assignment. Every adopted project's first commit was blocked,
# and the output named no failing check because the script died before the
# summary. No fixture had ever run the gate on an empty memory/.
#
# Assert on reaching the summary, not on the exit code: a fresh adopt may
# legitimately fail a check. Crash and verdict both exit 1 — "Results:" is
# what tells them apart.

@test "dod.sh survives a freshly adopted project (empty memory/, unindexed MEMORY.md)" {
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open >/dev/null 2>&1
  [ -f "$SCRATCH/memory/.gitkeep" ]
  [ ! -e "$SCRATCH/memory/2000-01-01.md" ]        # the glob really matches nothing
  run grep -q "MEMORY-INDEX START" "$SCRATCH/MEMORY.md"
  [ "$status" -ne 0 ]                              # and the warning branch is really entered

  printf 'ok\n' > normal.txt
  git add normal.txt
  DOD_SKIP="docs-lag,progress,docs-matrix,tests,self-check" PRE_COMMIT=1 \
    run bash "$HARNESS_ROOT/scripts/dod.sh"
  [[ "$output" == *"Results:"* ]]
  [[ "$output" != *"ABORTED"* ]]
  [[ "$output" == *"MEMORY.md has no index — 0 note(s)"* ]]
}

@test "dod.sh counts real notes in memory/ once they exist" {
  bash "$HARNESS_ROOT/scripts/init-adopt.sh" "$SCRATCH" --no-open >/dev/null 2>&1
  printf '# note\n' > memory/2026-08-23.md
  printf '# note\n' > memory/topic.md
  printf 'ok\n' > normal.txt
  git add normal.txt
  DOD_SKIP="docs-lag,progress,docs-matrix,tests,self-check" PRE_COMMIT=1 \
    run bash "$HARNESS_ROOT/scripts/dod.sh"
  [[ "$output" == *"MEMORY.md has no index — 2 note(s)"* ]]
}

# The fix above closes one crash; the trap catches the next one. T-J20 cost
# several traced runs to diagnose precisely because a crash and a FAIL are
# indistinguishable from outside — same exit 1, and the crash prints less.
# Inject a crash into a copy of the real script and check the gate says so.
@test "dod.sh reports a crash as a crash, naming the line, not as a silent exit 1" {
  cp "$HARNESS_ROOT/scripts/dod.sh" ./dod-crash.sh
  # Fail on a plain assignment mid-run — the exact shape of T-J20.
  awk '/^echo "=== DoD Check ==="$/ && !done { print "BOOM=$(ls /nonexistent-abcxyz | wc -l)"; done=1 } { print }' \
    ./dod-crash.sh > ./dod-crash.tmp && mv ./dod-crash.tmp ./dod-crash.sh
  grep -q '^BOOM=' ./dod-crash.sh                  # the injection landed

  printf 'ok\n' > normal.txt
  git add normal.txt
  DOD_SKIP="docs-lag,progress,docs-matrix,tests,self-check" PRE_COMMIT=1 \
    run bash ./dod-crash.sh
  [ "$status" -ne 0 ]
  # A real line number and a real exit code, not the "?" fallback or an
  # empty $? — the whole point is that the next reader gets a place to look.
  [[ "$output" =~ DoD\ ABORTED\ at\ dod\.sh:[0-9]+\ \(exit\ [1-9][0-9]*\) ]]
  [[ "$output" == *"the gate crashed"* ]]
  [[ "$output" != *"Results:"* ]]
}

@test "dod.sh does not report a crash on an ordinary failed check" {
  printf 'const label = "Готово";\n' > file.js
  git add file.js
  DOD_SKIP="$QUIET_SKIP" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Results:"* ]]
  [[ "$output" != *"ABORTED"* ]]
}

# ── Step 7: syntax check on paths with spaces (T-I19) ─────────────────────
# `bash -n $SH_STAGED` word-split on spaces, so a client project with an
# ordinary path like "src/My Component/build.sh" got a missing-file error
# instead of the real verdict.
@test "dod.sh step 7 syntax-checks a staged shell file whose path contains a space" {
  mkdir -p "src/My Component"
  printf '#!/bin/bash\nif [ 1 -eq 1 ]\n' > "src/My Component/build.sh"   # missing fi
  git add "src/My Component/build.sh"

  DOD_SKIP="docs-lag,progress,docs-matrix,tests" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Self-check (syntax)"* ]]
  [[ "$output" != *"No such file or directory"* ]]
}

@test "dod.sh step 7 passes a valid staged shell file whose path contains a space" {
  mkdir -p "src/My Component"
  printf '#!/bin/bash\nif [ 1 -eq 1 ]; then echo ok; fi\n' > "src/My Component/build.sh"
  git add "src/My Component/build.sh"

  DOD_SKIP="docs-lag,progress,docs-matrix,tests" PRE_COMMIT=1 run bash "$HARNESS_ROOT/scripts/dod.sh"
  [[ "$output" == *"Self-check (syntax on changed shell files)"* ]]
}
