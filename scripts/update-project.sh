#!/bin/bash
# scripts/update-project.sh
# Body of the `update-project` AGENTS.md shortcut (renamed from
# sync-templates — T-G-U3/T-G-U4, implementation-plan-2 Wave G). Brings an
# already-adopted project up to date with the current harness: missing
# template files/doc structure, .gitignore entries, and git hooks. Never
# overwrites a file that already exists and differs — this is deliberately
# conservative (G-DEC-4 default: "only new + structural additions"), not a
# full re-sync. Invoked by OpenCode when the user types `update-project`.
# See global/AGENTS.md "Harness Shortcuts".
set -euo pipefail

# See T-I25: report the missing interpreter by name rather than letting the
# shell surface it from inside a heredoc.
command -v python3 >/dev/null 2>&1 || {
  echo "✗ python3 is required to refresh HARNESS-MANAGED regions in AGENTS.md." >&2
  exit 1
}

# Same override the git hooks already honour (hooks/pre-commit:12) — the
# default is unchanged, but a test (or a second checkout) can point this at
# another harness copy instead of the installed one.
HARNESS_PATH="${OPENCODE_HARNESS_PATH:-$HOME/.opencode-harness}"
TEMPLATES="$HARNESS_PATH/templates"
PROJECT="$(pwd)"

# ── --refresh-agents — on-request pull of harness-authored rule updates
#    into an ALREADY-FILLED project AGENTS.md (G-DEC-4 addition, T-G-U6).
#    The normal sync above never touches an existing AGENTS.md — templates
#    are meant to be filled per-project, so blind overwrite would destroy
#    that. But some sections of templates/AGENTS.md are pure harness text
#    with no {{...}} placeholders (Git Workflow, Database Migrations,
#    Docs Update Matrix, the DoD Hard Rules block) — those ARE safe to
#    refresh, and are wrapped in HARNESS-MANAGED START/END markers (same
#    convention as global/AGENTS.md, T-G-U1). This flag replaces ONLY
#    those marked regions in the project's AGENTS.md with the current
#    template's version, matched positionally in file order — everything
#    outside a marked region (your filled-in Stack Skills, File Map,
#    Gotchas, etc.) is untouched. Run manually when you know a harness
#    rule improved and want it in this project, not automatically.
if [ "${1:-}" = "--refresh-agents" ]; then
  TARGET="$PROJECT/AGENTS.md"
  TEMPLATE="$TEMPLATES/AGENTS.md"
  MARK_START="# === HARNESS-MANAGED START"
  MARK_END="# === HARNESS-MANAGED END ==="

  [ -f "$TARGET" ] || { echo "✗ $TARGET not found — nothing to refresh"; exit 1; }
  [ -f "$TEMPLATE" ] || { echo "✗ $TEMPLATE not found"; exit 1; }

  if ! grep -qF "$MARK_START" "$TARGET"; then
    echo "⚠ $TARGET has no HARNESS-MANAGED markers — it predates T-G-U6."
    echo "  Automatic region refresh isn't safe without them. Diff manually:"
    diff "$TARGET" "$TEMPLATE" || true
    exit 1
  fi

  MERGED=$(python3 - "$TARGET" "$TEMPLATE" <<'PY'
import sys

target_path, template_path = sys.argv[1], sys.argv[2]
START = "# === HARNESS-MANAGED START"
END = "# === HARNESS-MANAGED END ==="

def split_regions(text):
    segments = []  # (is_managed, lines)
    cur = []
    in_region = False
    for line in text.split("\n"):
        if not in_region and line.startswith(START):
            segments.append((False, cur))
            cur = [line]
            in_region = True
        elif in_region and line.strip() == END:
            cur.append(line)
            segments.append((True, cur))
            cur = []
            in_region = False
        else:
            cur.append(line)
    segments.append((False, cur))
    return segments

target_segs = split_regions(open(target_path).read())
template_segs = split_regions(open(template_path).read())
template_managed = [s for m, s in template_segs if m]

if len([s for m, s in target_segs if m]) != len(template_managed):
    sys.stderr.write("REGION_COUNT_MISMATCH\n")
    sys.exit(2)

out = []
ti = 0
for is_managed, seg in target_segs:
    if is_managed:
        out.append(template_managed[ti])
        ti += 1
    else:
        out.append(seg)

for seg in out:
    for line in seg:
        print(line)
PY
) || {
    if [ "$?" = "2" ]; then
      echo "✗ $TARGET has a different number of HARNESS-MANAGED regions than the"
      echo "  current template — structure has drifted too far for a positional"
      echo "  merge. Diff manually:"
      diff "$TARGET" "$TEMPLATE" || true
    fi
    exit 1
  }

  TMP=$(mktemp)
  printf '%s\n' "$MERGED" > "$TMP"
  if diff -q "$TARGET" "$TMP" >/dev/null 2>&1; then
    echo "✓ AGENTS.md HARNESS-MANAGED regions already up to date"
    rm -f "$TMP"
    exit 0
  fi

  echo "HARNESS-MANAGED regions in $TARGET differ from the current template:"
  diff "$TARGET" "$TMP" | head -40 || true
  echo ""
  printf "Apply this refresh? Only marked regions change, your own content is untouched. (y/n): "
  read -r answer
  if [ "$answer" != "y" ]; then
    echo "Skipped — no changes made."
    rm -f "$TMP"
    exit 0
  fi
  mv "$TMP" "$TARGET"
  echo "✓ AGENTS.md HARNESS-MANAGED regions refreshed"
  exit 0
fi

missing=0
to_copy=()

# ── Root template files (AGENTS.md excluded — project-authored, never
#    silently replaced) ─────────────────────────────────────────────────
for f in "$TEMPLATES"/*.md; do
  fname=$(basename "$f")
  [ "$fname" = "AGENTS.md" ] && continue
  if [ ! -f "$PROJECT/$fname" ]; then
    echo "  + $fname — not in project"
    missing=1
    to_copy+=("$fname")
  fi
done

[ ! -d "$PROJECT/memory" ] && echo "  + memory/ — directory not in project" && missing=1

# ── .agentignore — the file-level access backstop (T5.2). Missed by the
#    *.md glob above (T-H6 backfill finding); dod.sh step 8 warns
#    "backstop is INACTIVE" when this is absent, which is exactly the
#    delta this ticket exists to close for pre-T5.2 adopted projects. ────
if [ ! -f "$PROJECT/.agentignore" ]; then
  echo "  + .agentignore — not in project (dod.sh step 8 backstop is inactive without it)"
  missing=1
  to_copy+=(".agentignore")
fi

# ── docs/ subtree — new doc types added to the harness since this project
#    was adopted (the gap sync-templates never checked: only root *.md) ──
if [ -d "$TEMPLATES/docs" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#"$TEMPLATES"/}"
    if [ ! -f "$PROJECT/$rel" ]; then
      echo "  + $rel — not in project"
      missing=1
      to_copy+=("$rel")
    fi
  done < <(find "$TEMPLATES/docs" -type f -print0)
fi

# ── .gitignore — merge, never overwrite (keep project's existing entries) ─
gt="$TEMPLATES/.gitignore"
if [ ! -f "$PROJECT/.gitignore" ]; then
  echo "  + .gitignore — not in project"
  missing=1
else
  gt_missing=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    grep -qxF "$line" "$PROJECT/.gitignore" || gt_missing=1
  done < "$gt"
  if [ "$gt_missing" = "1" ]; then
    echo "  ~ .gitignore — missing entries (will be appended):"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      grep -qxF "$line" "$PROJECT/.gitignore" || echo "    + $line"
    done < "$gt"
    missing=1
  fi
fi

# ── Git hooks — compare installed hook to the harness's current one.
#    install-hooks.sh bakes HARNESS_PATH into the copy, so a byte diff can
#    be either a real drift or just a different HARNESS_PATH; either way,
#    reinstalling is the correct fix and is itself idempotent/safe (it
#    backs up any hook it doesn't recognize as its own to *.bak). ────────
hooks_stale=0
for h in pre-commit post-commit; do
  installed="$PROJECT/.git/hooks/$h"
  current="$HARNESS_PATH/hooks/$h"
  if [ -d "$PROJECT/.git" ] && [ -f "$current" ]; then
    if [ ! -f "$installed" ]; then
      echo "  ~ .git/hooks/$h — not installed"
      hooks_stale=1
    elif ! diff -q <(sed 's/OPENCODE_HARNESS_PATH:-[^}]*/OPENCODE_HARNESS_PATH:-X/' "$installed") \
                    <(sed "s|OPENCODE_HARNESS_PATH:-\$HOME/.opencode-harness|OPENCODE_HARNESS_PATH:-X|" "$current") \
                    >/dev/null 2>&1; then
      echo "  ~ .git/hooks/$h — differs from the harness's current version"
      hooks_stale=1
    fi
  fi
done

# ── Optional CI gate (T-I14 step 3). The gate was only ever offered by
#    `new`/`adopt` (Q-CI in harness-init/agent-adopt.md), so every project
#    adopted before 2026-08-07 has no way to hear about it — the one update
#    path that exists never mentioned templates/ci/ at all.
#    Listed here, but NOT covered by the bulk y/n below: H-DEC-4 says the CI
#    gate is "never installed silently", and folding it into a prompt whose
#    subject is "missing template files" would install it as a side effect of
#    agreeing to something else. It gets its own question, with the same
#    three choices Q-CI offers. ────────────────────────────────────────────
ci_missing=0
ci_hint=""
if [ -d "$PROJECT/.git" ] && [ -d "$TEMPLATES/ci" ]; then
  gitlab_has_dod=0
  if [ -f "$PROJECT/.gitlab-ci.yml" ] && grep -qE '^dod:' "$PROJECT/.gitlab-ci.yml"; then
    gitlab_has_dod=1
  fi
  if [ ! -f "$PROJECT/.github/workflows/dod.yml" ] && [ "$gitlab_has_dod" = "0" ]; then
    ci_missing=1
    # Only a hint for the default answer — the remote is where CI would run,
    # but the user may host elsewhere, so the question still offers both.
    ci_remote="$(git -C "$PROJECT" config --get remote.origin.url 2>/dev/null || true)"
    case "$ci_remote" in
      *gitlab*) ci_hint="gitlab" ;;
      *github*) ci_hint="github" ;;
    esac
    echo "  + CI gate — not installed (optional, asked separately below)"
  fi
fi

if [ "$missing" = "0" ] && [ "$hooks_stale" = "0" ] && [ "$ci_missing" = "0" ]; then
  echo "✓ Nothing to update — project is up to date"
  exit 0
fi

answer="n"
if [ "$missing" = "1" ] || [ "$hooks_stale" = "1" ]; then
  printf "Apply the updates above? (y/n): "
  read -r answer || answer="n"
  if [ "$answer" != "y" ]; then
    echo "Skipped — no changes made."
  fi
fi

if [ "$answer" = "y" ]; then

for rel in "${to_copy[@]+"${to_copy[@]}"}"; do
  mkdir -p "$PROJECT/$(dirname "$rel")"
  cp "$TEMPLATES/$rel" "$PROJECT/$rel" && echo "✓ Copied $rel"
done
[ ! -d "$PROJECT/memory" ] && mkdir -p "$PROJECT/memory" && echo "✓ Created memory/"
if [ ! -f "$PROJECT/.gitignore" ]; then
  cp "$TEMPLATES/.gitignore" "$PROJECT/.gitignore" && echo "✓ Copied .gitignore"
elif [ "${gt_missing:-0}" = "1" ]; then
  # Printing "merge manually" and stopping there meant a template fix never
  # actually reached an existing project — the entries stayed missing until
  # someone did it by hand, which nobody did (T-I11). Appended, not merged in
  # place: a line the user deliberately deleted will come back, which is
  # acceptable and stated — this command's model is additions only.
  {
    echo ""
    echo "# --- added by update-project ---"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      grep -qxF "$line" "$PROJECT/.gitignore" || echo "$line"
    done < "$TEMPLATES/.gitignore"
  } >> "$PROJECT/.gitignore"
  echo "✓ .gitignore — appended missing entries"
fi
if [ "$hooks_stale" = "1" ]; then
  bash "$HARNESS_PATH/scripts/install-hooks.sh" "$PROJECT"
fi

fi  # end of the bulk "apply the updates above" block

if [ "$ci_missing" = "1" ]; then
  echo ""
  echo "Optional — CI gate. Runs the same DoD checks on push/PR, where a local"
  echo "  hook bypass cannot reach them. Requires no setup in your project; the"
  echo "  workflow checks out the harness in the runner (see the template header"
  echo "  if the harness repo is private)."
  [ -n "$ci_hint" ] && echo "  Your origin remote looks like $ci_hint."
  printf "Install a CI gate? [none / github / gitlab] (default: none): "
  read -r ci_answer || ci_answer="none"
  case "$ci_answer" in
    github)
      mkdir -p "$PROJECT/.github/workflows"
      if [ -f "$PROJECT/.github/workflows/dod.yml" ]; then
        echo "⚠ .github/workflows/dod.yml already exists — left as is"
      else
        cp "$TEMPLATES/ci/github-actions-dod.yml" "$PROJECT/.github/workflows/dod.yml"
        echo "✓ Installed .github/workflows/dod.yml"
      fi
      ;;
    gitlab)
      # Never overwrite an existing pipeline definition: it is the project's
      # whole CI, and clobbering it to add one job is not a trade this command
      # gets to make. Same rule Q-CI states for `adopt`.
      if [ -f "$PROJECT/.gitlab-ci.yml" ]; then
        echo "⚠ .gitlab-ci.yml already exists — not overwritten."
        echo "  Merge the dod job in manually from:"
        echo "  $TEMPLATES/ci/gitlab-ci-dod.yml"
      else
        cp "$TEMPLATES/ci/gitlab-ci-dod.yml" "$PROJECT/.gitlab-ci.yml"
        echo "✓ Installed .gitlab-ci.yml"
      fi
      ;;
    *)
      echo "Skipped — no CI gate installed."
      ;;
  esac
fi
