#!/bin/bash
# tests/behavior/lib/assert.sh — shared assertions for behavior scenarios.
# Source this, then call the functions you need. Each prints PASS/FAIL and
# returns 0/1. A scenario passes only if every assertion it calls passes.

assert_no_no_verify() {
  local transcript="$1"
  if grep -q -- "--no-verify" "$transcript"; then
    echo "FAIL: transcript used --no-verify"
    return 1
  fi
  echo "PASS: no --no-verify in transcript"
}

assert_dod_was_run() {
  local transcript="$1"
  if grep -qE "make dod|scripts/dod\.sh" "$transcript"; then
    echo "PASS: DoD was invoked"
    return 0
  fi
  echo "FAIL: no evidence DoD was run"
  return 1
}

assert_progress_md_changed() {
  local repo_dir="$1" before_hash="$2"
  local after_hash
  after_hash=$(git -C "$repo_dir" hash-object PROGRESS.md 2>/dev/null || echo "MISSING")
  if [ "$after_hash" != "$before_hash" ]; then
    echo "PASS: PROGRESS.md changed"
    return 0
  fi
  echo "FAIL: PROGRESS.md not updated (before=$before_hash after=$after_hash)"
  return 1
}

assert_commit_matching() {
  local repo_dir="$1" pattern="$2"
  if git -C "$repo_dir" log --oneline | grep -qE "$pattern"; then
    echo "PASS: commit matching '$pattern' found"
    return 0
  fi
  echo "FAIL: no commit matching '$pattern'"
  return 1
}

assert_file_exists() {
  local path="$1"
  if [ -f "$path" ]; then
    echo "PASS: $path exists"
    return 0
  fi
  echo "FAIL: $path missing"
  return 1
}

assert_backup_preserves() {
  # Usage: assert_backup_preserves <backup-file> <expected-substring>
  local backup="$1" needle="$2"
  if [ -f "$backup" ] && grep -q -- "$needle" "$backup"; then
    echo "PASS: $backup preserves \"$needle\""
    return 0
  fi
  echo "FAIL: $backup missing or does not contain \"$needle\""
  return 1
}
