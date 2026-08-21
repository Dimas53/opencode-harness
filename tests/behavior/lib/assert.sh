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

assert_skill_loaded() {
  # Usage: assert_skill_loaded <transcript> <skill-domain-e.g.-security>
  # Works against both a plain-text transcript (grep for the Read path)
  # and an `opencode run --format json` event stream (tool_use events
  # with tool:"read" carry the path in their JSON, which still matches
  # a plain string grep — no JSON parsing needed for this check).
  # Two loading paths count, because OpenCode has both (measured 2026-08-21):
  #   1. `Read ~/.config/opencode/skills/<domain>/SKILL.md` — the file path;
  #   2. the native `skill` tool, which leaves no path in the transcript —
  #      a JSON event carries tool:"skill" with name:"<domain>", a plain-text
  #      transcript shows `Skill "<domain>"`.
  # Checking only (1) fails a run that did the right thing the better way.
  local transcript="$1" domain="$2"
  if grep -qF "skills/$domain/SKILL.md" "$transcript"; then
    echo "PASS: $domain was loaded (file read)"
    return 0
  fi
  # Plain-text transcript: `Skill "security"`.
  if grep -qiE "skill[[:space:]]+\"?${domain}\"?([[:space:]]|$)" "$transcript"; then
    echo "PASS: $domain was loaded (skill tool)"
    return 0
  fi
  # JSON event stream: tool:"skill" and name:"<domain>" on the same line,
  # whatever keys sit between them.
  if grep -F '"skill"' "$transcript" | grep -qF "\"$domain\""; then
    echo "PASS: $domain was loaded (skill tool)"
    return 0
  fi
  echo "FAIL: no evidence $domain was loaded (neither file read nor skill tool)"
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
