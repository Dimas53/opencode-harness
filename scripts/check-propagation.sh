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

    fail "$file:$lineno — path unreachable from a client project (no \`~/.opencode-harness/\` prefix, no harness-repo caveat nearby): $(echo "$line" | sed 's/^ *//' | cut -c1-100)"
  done < "$file"
}

for f in $PATH_TARGETS; do
  if [ -f "$f" ]; then
    check_make_commands "$f"
    check_unreachable_paths "$f"
  elif [ -d "$f" ]; then
    while IFS= read -r -d '' sub; do
      check_make_commands "$sub"
      check_unreachable_paths "$sub"
    done < <(find "$f" -type f \( -name "*.md" -o -name "*.sh" \) -print0)
  fi
done

# ── Rule 3: dod.sh must not silently `check_pass` in a client-profile
#    (IS_HARNESS_REPO=0) branch without a `# propagation-ok:` marker
#    justifying it. Heuristic pairing of the specific
#    `if [ "$IS_HARNESS_REPO" = "1" ]` / else / fi construct this file
#    uses — not a general bash parser (T-H4 spec allows conservatism).
if [ -f "scripts/dod.sh" ]; then
  while IFS= read -r ln; do
    lo=$((ln > 3 ? ln - 3 : 1))
    window=$(sed -n "${lo},${ln}p" scripts/dod.sh)
    if ! echo "$window" | grep -q "propagation-ok:"; then
      fail "scripts/dod.sh:$ln — check_pass in a client-profile (IS_HARNESS_REPO=0) branch with no \`# propagation-ok: <reason>\` marker above it. Either add the marker (if this pass is a real check) or make it check_warn."
    fi
  done < <(awk '
    /if \[ "\$IS_HARNESS_REPO" = "1" \]/ { armed = 1; next }
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
