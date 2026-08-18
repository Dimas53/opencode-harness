#!/bin/bash
# scripts/check-propagation.sh
# T-H4 (implementation-plan-2 Wave H) — mechanical backstop for the
# principle in 10-waveH-propagation.md §0: a delivered file (K1/K2/K3 —
# global/AGENTS.md, global/skills/, templates/) must not reference a path
# or command that only exists in the harness's own repo. H0-H3 fixed the
# known instances by hand; this stops them from silently coming back.
#
# Deliberately conservative (per the ticket): false negatives (missing a
# real regression) are acceptable, false positives (blocking a legitimate
# commit) are not. When in doubt, this script skips.
set -euo pipefail

cd "$(dirname "$0")/.."

FAIL=0
fail() {
  echo "✗ $1" >&2
  FAIL=1
}

# ── Rule 1: unreachable `make <target>` commands ───────────────────────────
# Commands legitimately run from inside the harness repo itself (the
# Fallback block, or a self-referential mention with a nearby caveat).
MAKE_ALLOWLIST="init|init-adopt|analyze|setup|update|link|start"

check_make_commands() {
  local file="$1"
  [ -f "$file" ] || return 0
  # Cheap pre-filter: the per-line loop below costs several subprocesses per
  # line, and most files contain no `make` command at all. Without this, the
  # widened traversal (T-I10) pushed a full run past a minute.
  grep -q '`make ' "$file" || return 0
  local lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    # Require a literal backtick before `make` — otherwise this matches
    # plain English ("make a plan", "make changes"), not a CLI command.
    local target
    target=$(echo "$line" | grep -oE '`make [a-zA-Z-]+' | head -1 | sed -E 's/`make //') || true
    [ -z "$target" ] && continue

    if echo "$target" | grep -qE "^($MAKE_ALLOWLIST)$"; then
      continue
    fi

    # Not on the allowlist — legitimate only if a nearby caveat explains
    # this only applies in the harness repo. Window: 4 lines before/after,
    # to tolerate prose wrapping across lines (natural in a .md file).
    local lo=$((lineno > 4 ? lineno - 4 : 1))
    local hi=$((lineno + 4))
    local window
    window=$(sed -n "${lo},${hi}p" "$file")
    if echo "$window" | grep -qiE "harness repo|harness-repo|meta-repo|Makefile"; then
      continue
    fi

    fail "$file:$lineno — unreachable \`make $target\` (no Makefile in a client project). Use \`bash ~/.opencode-harness/scripts/<script>.sh\` — or add a nearby caveat explaining this is harness-repo-only."
  done < "$file"
}

# ── Rule 2: unreachable relative paths (instructions/, notes/, tests/, ─────
#    .github/, unprefixed scripts/, Makefile) in harness-authored files
#    only — other vendored skills legitimately use these words for the
#    USER'S project (see T-H4 spec, 10-waveH-propagation.md).
PATH_TARGETS="global/AGENTS.md global/skills/harness-init global/skills/dod global/skills/session-end global/skills/startup templates"

check_unreachable_paths() {
  local file="$1"
  [ -f "$file" ] || return 0
  # Same pre-filter as above — skip whole files that cannot match.
  grep -qE '(instructions/|notes/Harness|tests/behavior/|\.github/|scripts/[a-zA-Z])' "$file" || return 0
  local lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    # Already-prefixed references are fine.
    # Bare "Makefile" is deliberately NOT matched here — it's an
    # extremely common generic word (a project's own Makefile, an
    # example filename in a Safety Gate list) with near-zero signal on
    # its own. `make <target>` is covered by Rule 1 instead.
    local stripped
    stripped=$(echo "$line" | sed -E 's#~/\.opencode-harness/[a-zA-Z0-9_./-]*##g; s#~/\.config/opencode/[a-zA-Z0-9_./-]*##g')
    echo "$stripped" | grep -qE '(^|[^a-zA-Z0-9_./~-])(instructions/|notes/Harness|tests/behavior/|\.github/|scripts/[a-zA-Z])' || continue

    local lo=$((lineno > 4 ? lineno - 4 : 1))
    local hi=$((lineno + 4))
    local window
    window=$(sed -n "${lo},${hi}p" "$file")
    if echo "$window" | grep -qiE "harness repo|harness-repo|meta-repo"; then
      continue
    fi
    # propagation-ok: same escape hatch as Rule 3, extended here — for a
    # path that's genuinely reachable but for a reason this heuristic
    # can't see on its own (e.g. a target path being CREATED inside the
    # client project, like templates/ci/*.yml's `cp ... .github/workflows/`,
    # not a reference assuming something already exists there).
    if echo "$window" | grep -q "propagation-ok:"; then
      continue
    fi

    fail "$file:$lineno — path unreachable from a client project (no \`~/.opencode-harness/\` prefix, no harness-repo caveat nearby): $(echo "$line" | sed 's/^ *//' | cut -c1-100)"
  done < "$file"
}

for f in $PATH_TARGETS; do
  if [ -f "$f" ]; then
    check_make_commands "$f"
    check_unreachable_paths "$f"
  elif [ -d "$f" ]; then
    # Every file, not just *.md/*.sh: the non-markdown layer is exactly what
    # ships to a client project (templates/.agentignore, .gitignore,
    # .env.example, ci/*.yml) and it was entirely outside the lint — which is
    # how templates/.agentignore came to cite a bare `scripts/dod.sh` path,
    # the very bug this script exists to catch, in a file it could not see
    # (T-I10). Binary extensions are excluded so the lint never reads images.
    while IFS= read -r -d '' sub; do
      case "$sub" in
        *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.webp|*.woff|*.woff2|*.ttf|*.eot|*.pdf|*.zip|*.tar|*.gz|*.mp4|*.mov) continue ;;
        # Never delivered: rsync excludes *.bak, and node_modules/notes are
        # working-tree debris (T-I13 removes the mirroring half of this).
        *.bak|*.sedbak|*/node_modules/*|*/.git/*) continue ;;
      esac
      check_make_commands "$sub"
      check_unreachable_paths "$sub"
    done < <(find "$f" -type f -print0)
  fi
done

# ── Rule 2b: channel K4 (README.md, INSTALL.md) ────────────────────────────
# User-facing docs were outside the lint entirely, which is where the user
# actually copies commands from — that is how README kept teaching
# `make unadopt` in a client project long after the Makefile stopped being
# installed there (T-I15).
#
# These two files legitimately live in the harness repo and describe it:
# `make help`, `make mcp`, links to instructions/ are all correct in that
# context, and flagging them produced 12 false positives on the first run.
# So the rule is inverted here — instead of demanding a harness-repo caveat,
# it fires only when the surrounding lines are explicitly talking about a
# CLIENT project, where no Makefile exists.
K4_TARGETS="README.md INSTALL.md"
CLIENT_CONTEXT="from a project|client project|in your project|your own project|/path/to/project|cd /path/to|adopted project"

check_k4_client_commands() {
  local file="$1"
  [ -f "$file" ] || return 0
  grep -q 'make ' "$file" || return 0
  local lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    local target
    target=$(echo "$line" | grep -oE '`?make [a-zA-Z-]+' | head -1 | sed -E 's/`?make //') || true
    [ -z "$target" ] && continue
    echo "$target" | grep -qE "^($MAKE_ALLOWLIST)$" && continue

    local lo=$((lineno > 3 ? lineno - 3 : 1))
    local hi=$((lineno + 3))
    local window
    window=$(sed -n "${lo},${hi}p" "$file")
    echo "$window" | grep -qiE "$CLIENT_CONTEXT" || continue
    echo "$window" | grep -q "propagation-ok:" && continue

    fail "$file:$lineno — \`make $target\` shown for a CLIENT project, which has no Makefile by design. Use \`bash ~/.opencode-harness/scripts/<script>.sh\`."
  done < "$file"
}

for f in $K4_TARGETS; do
  check_k4_client_commands "$f"
done

# ── Rule 4: the shortcut / auto-loading lists must match the disk ──────────
# Nothing checked either direction: not that a listed shortcut points at
# something that exists, nor that a new script/protocol made it into the
# list. Both lists were correct when audited by hand (21 shortcuts, 30
# auto-loading rows, zero misses) — this keeps them that way without a human
# re-walking them (T-I23, closing report finding F).
AGENTS_MD="global/AGENTS.md"

if [ -f "$AGENTS_MD" ]; then
  # 4a. Forward — every script path named in AGENTS.md exists.
  while IFS= read -r p; do
    [ -f "${p#\~/.opencode-harness/}" ] || \
      fail "$AGENTS_MD names \`$p\`, which does not exist in the harness repo."
  done < <(grep -oE '~/\.opencode-harness/scripts/[a-zA-Z0-9._-]+\.sh' "$AGENTS_MD" | sort -u)

  # 4b. Forward — every skill path named in AGENTS.md exists, whether written
  #     as ~/.config/opencode/skills/<x> or as a bare <domain>/SKILL.md row in
  #     the Auto-Loading table.
  while IFS= read -r p; do
    [ -e "global/skills/${p#\~/.config/opencode/skills/}" ] || \
      fail "$AGENTS_MD names skill \`$p\`, which does not exist in global/skills/."
  done < <(grep -oE '~/\.config/opencode/skills/[a-zA-Z0-9._/-]+' "$AGENTS_MD" | sort -u)

  while IFS= read -r p; do
    [ -f "global/skills/$p" ] || \
      fail "$AGENTS_MD Auto-Loading table points at \`$p\`, which does not exist in global/skills/."
  done < <(sed -n '/^| Domain *| Triggers *| Path *|/,/^$/p' "$AGENTS_MD" \
             | grep -oE '[a-zA-Z0-9._/-]+/SKILL\.md' | sort -u)

  # 4c. Backward — a new shortcut script or agent protocol must appear in the
  #     `## Harness Shortcuts` list. Without this, the list rots the moment
  #     someone adds a script: the forward rules above would stay green.
  SHORTCUT_SECTION=$(sed -n '/^## Harness Shortcuts/,/^## /p' "$AGENTS_MD")

  for s in scripts/*-shortcut.sh; do
    [ -f "$s" ] || continue
    base=$(basename "$s")
    echo "$SHORTCUT_SECTION" | grep -q "$base" || \
      fail "scripts/$base exists but is not mentioned in \`## Harness Shortcuts\` — a shortcut nobody can discover."
  done

  for a in global/skills/harness-init/agent-*.md; do
    [ -f "$a" ] || continue
    # A protocol declaring `trigger: "none"` is a sub-protocol loaded by
    # another one (agent-e2e.md), not a user-facing shortcut — excluding it
    # by frontmatter, not by name, so the exception cannot silently widen.
    grep -qE '^trigger:[[:space:]]*"none' "$a" && continue
    trig=$(grep -m1 -E '^trigger:' "$a" | sed -E 's/^trigger:[[:space:]]*"?//; s/[",].*$//' | tr -d ' ')
    [ -z "$trig" ] && continue
    echo "$SHORTCUT_SECTION" | grep -qE "\`$trig[\` ]" || \
      fail "$a declares trigger \`$trig\` but no such shortcut is listed in \`## Harness Shortcuts\`."
  done
fi

# ── Rule 3: dod.sh must not silently `check_pass` in a client-profile
#    (IS_HARNESS_REPO=0) branch without a `# propagation-ok:` marker
#    justifying it. Heuristic pairing of the specific
#    `elif [ "$IS_HARNESS_REPO" = "1" ]` / else / fi construct Steps 6/7
#    use — not a general bash parser (T-H4 spec allows conservatism).
#    Deliberately matches `elif` only, not bare `if`: a standalone
#    `if [ "$IS_HARNESS_REPO" = "1" ] ... else ... fi` (like Step 5's,
#    T-H1) is a different, self-contained construct nested inside its own
#    already-branched context — pairing it with this same else/fi hunt
#    produced a false positive (matched some later, unrelated fi) the
#    first time this rule ran against it.
if [ -f "scripts/dod.sh" ]; then
  while IFS= read -r ln; do
    lo=$((ln > 3 ? ln - 3 : 1))
    window=$(sed -n "${lo},${ln}p" scripts/dod.sh)
    if ! echo "$window" | grep -q "propagation-ok:"; then
      fail "scripts/dod.sh:$ln — check_pass in a client-profile (IS_HARNESS_REPO=0) branch with no \`# propagation-ok: <reason>\` marker above it. Either add the marker (if this pass is a real check) or make it check_warn."
    fi
  done < <(awk '
    /elif \[ "\$IS_HARNESS_REPO" = "1" \]/ { armed = 1; next }
    armed && /^else$/ && !in_else { in_else = 1; next }
    armed && in_else && /^fi$/ { armed = 0; in_else = 0; next }
    armed && in_else && /check_pass/ { print NR }
  ' scripts/dod.sh)
fi

if [ "$FAIL" = "1" ]; then
  echo "" >&2
  echo "check-propagation: found unreachable references in delivered files." >&2
  echo "See notes/Harness/implementation-plan-2/10-waveH-propagation.md T-H4." >&2
  exit 1
fi

echo "✓ check-propagation: no unreachable commands/paths found"
