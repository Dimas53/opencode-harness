#!/bin/bash
# scripts/unadopt.sh
# Removes all harness files from the current project (run from the project
# root, NOT from the harness repo). Ported from the old `make unadopt`
# target (Makefile) so it is callable via ~/.opencode-harness from a client
# project, which has no Makefile of its own.
#
# Must remove BOTH git hooks. Since commit 3271144 the post-commit rollback
# guard is installed in every project, not just the harness repo. Removing
# only pre-commit (the original behavior) leaves post-commit behind: it
# calls dod.sh on every future commit, dod.sh step 4 fails on the
# now-deleted PROGRESS.md, and the guard rolls every subsequent commit back
# — silently bricking the project's git history until someone finds this
# script and removes the hook by hand. See notes/Harness/implementation-plan-2/09-propagation-audit.md.
set -euo pipefail

if [ ! -f MEMORY.md ]; then
  echo "✗ Harness files not found here. Run from project root." >&2
  exit 1
fi

mkdir -p .harness-unadopt-backup
for f in AGENTS.md MEMORY.md PLAN.md PROGRESS.md HARNESS.md; do
  if [ -f "$f" ]; then
    cp "$f" ".harness-unadopt-backup/$f"
    echo "  Backed up: $f"
  fi
done
if [ -d memory ]; then
  cp -r memory .harness-unadopt-backup/memory
  echo "  Backed up: memory/"
fi

rm -f AGENTS.md MEMORY.md PLAN.md PROGRESS.md HARNESS.md
rm -rf memory/
echo "  → Full backup at .harness-unadopt-backup/ (delete manually when confirmed safe)"

# A .bak that is itself a harness hook is not a pre-harness hook to restore —
# it is debris from the clobbering bug T-I3 fixed. Restoring it would put the
# rollback guard back into a de-adopted project, which is the exact brick this
# script exists to prevent. Discard those before the restore logic runs.
for h in pre-commit post-commit; do
  if [ -f ".git/hooks/$h.bak" ] && grep -q "harness-managed-hook" ".git/hooks/$h.bak"; then
    rm -f ".git/hooks/$h.bak"
    echo "  Hook: stale harness backup $h.bak discarded (was not a pre-harness hook)"
  fi
done

# pre-commit: restore backup if the project had its own hook, else remove.
if [ -f .git/hooks/pre-commit.bak ]; then
  mv .git/hooks/pre-commit.bak .git/hooks/pre-commit
  echo "  Hook: pre-commit restored from backup"
else
  rm -f .git/hooks/pre-commit
  echo "  Hook: pre-commit removed"
fi

# post-commit: installed into every project since 3271144 (rollback guard).
# It MUST go too — left behind, it calls dod.sh, fails on the now-deleted
# PROGRESS.md and rolls back every future commit in a project that no longer
# has the harness.
if [ -f .git/hooks/post-commit.bak ]; then
  mv .git/hooks/post-commit.bak .git/hooks/post-commit
  echo "  Hook: post-commit restored from backup"
else
  rm -f .git/hooks/post-commit
  echo "  Hook: post-commit removed"
fi

echo ""
printf "docs/ may contain files created during harness sessions.\nDelete docs/ too? [y/N] "
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
  rm -rf docs/
  echo "  docs/: deleted"
else
  echo "  docs/: kept"
fi

echo ""
echo "✓ Harness removed from project"
