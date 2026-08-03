#!/bin/bash
# scripts/sync-templates.sh
# Body of the `sync-templates` AGENTS.md shortcut — extracted so AGENTS.md
# stays a rules document, not a script. Invoked by OpenCode when the user
# types `sync-templates`. See global/AGENTS.md "Harness Shortcuts".
set -euo pipefail

missing=0
for f in ~/.opencode-harness/templates/*.md; do
  fname=$(basename "$f")
  [ "$fname" = "AGENTS.md" ] && continue
  if [ ! -f "$(pwd)/$fname" ]; then
    echo "  + $fname — not in project"
    missing=1
  fi
done
[ ! -d "$(pwd)/memory" ] && echo "  + memory/ — directory not in project" && missing=1
# .gitignore — merge, never overwrite (keep project's existing entries)
gt="~/.opencode-harness/templates/.gitignore"
if [ ! -f "$(pwd)/.gitignore" ]; then
  echo "  + .gitignore — not in project"
  missing=1
else
  gt_missing=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    grep -qxF "$line" "$(pwd)/.gitignore" || gt_missing=1
  done < "$gt"
  if [ "$gt_missing" = "1" ]; then
    echo "  ~ .gitignore — missing entries (merge manually):"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      grep -qxF "$line" "$(pwd)/.gitignore" || echo "    + $line"
    done < "$gt"
  fi
fi
if [ "$missing" = "1" ]; then
  printf "Copy missing files to project? (y/n): "
  read -r answer
  if [ "$answer" = "y" ]; then
    for f in ~/.opencode-harness/templates/*.md; do
      fname=$(basename "$f")
      [ "$fname" = "AGENTS.md" ] && continue
      [ ! -f "$(pwd)/$fname" ] && cp "$f" "$(pwd)/$fname" && echo "✓ Copied $fname"
    done
    [ ! -d "$(pwd)/memory" ] && mkdir -p "$(pwd)/memory" && echo "✓ Created memory/"
    if [ ! -f "$(pwd)/.gitignore" ]; then
      cp ~/.opencode-harness/templates/.gitignore "$(pwd)/.gitignore" && echo "✓ Copied .gitignore"
    fi
  fi
else
  echo "✓ Nothing to add — project is up to date"
fi
