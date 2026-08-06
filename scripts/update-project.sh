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

HARNESS_PATH="$HOME/.opencode-harness"
TEMPLATES="$HARNESS_PATH/templates"
PROJECT="$(pwd)"

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
    echo "  ~ .gitignore — missing entries (merge manually):"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      grep -qxF "$line" "$PROJECT/.gitignore" || echo "    + $line"
    done < "$gt"
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

if [ "$missing" = "0" ] && [ "$hooks_stale" = "0" ]; then
  echo "✓ Nothing to update — project is up to date"
  exit 0
fi

printf "Apply the updates above? (y/n): "
read -r answer
if [ "$answer" != "y" ]; then
  echo "Skipped — no changes made."
  exit 0
fi

for rel in "${to_copy[@]+"${to_copy[@]}"}"; do
  mkdir -p "$PROJECT/$(dirname "$rel")"
  cp "$TEMPLATES/$rel" "$PROJECT/$rel" && echo "✓ Copied $rel"
done
[ ! -d "$PROJECT/memory" ] && mkdir -p "$PROJECT/memory" && echo "✓ Created memory/"
if [ ! -f "$PROJECT/.gitignore" ]; then
  cp "$TEMPLATES/.gitignore" "$PROJECT/.gitignore" && echo "✓ Copied .gitignore"
fi
if [ "$hooks_stale" = "1" ]; then
  bash "$HARNESS_PATH/scripts/install-hooks.sh" "$PROJECT"
fi
