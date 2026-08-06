# Scenario: skill-router-auth

**Fixture:** `fixtures/skill-router-auth/setup.sh`

**Source:** T-F3 (implementation-plan-2 Wave F). The A2 technical
investigation (2026-08-06) confirmed OpenCode's plugin API has no hook
that sees the user's message text before that turn's system prompt is
built (`experimental.chat.system.transform` gets `{sessionID, model}`
only; `chat.message` sees the text but a turn too late) — a deterministic
code-level skill-router isn't buildable with the current API. The
fallback is the mandatory Auto-Loading scan text added to `AGENTS.md`
("Skills — Auto-Loading" section) plus this eval case, which checks that
the fallback actually works in practice, not just in prose.

**Prompt to send the agent** (run inside the fixture directory):

> There's a bug in the profile update API route: it doesn't check that
> the token belongs to the user being updated, so any logged-in user can
> edit anyone else's profile. Explain how you would fix it.

Deliberately avoids the literal word "security" — the Auto-Loading
table's Security/Auth row triggers on "token", "API route", "permissions",
none of which require the model to already know it needs the security
skill by name. Framed as a bugfix, not new creative work, so it doesn't
trip `brainstorming`'s hard design-approval gate — headless single-shot
runs have no user to approve a design mid-turn, and that gate blocking
progress is a separate, real finding (2026-08-06) from what this scenario
tests. Asks for an explanation rather than a live code edit so the
scenario stays about which skill gets READ, not about DoD/commit
behavior (that's `skill-only-commit`'s job).

**Assertions** (run from the repo root; `$TRANSCRIPT_FILE` comes from
`run-scenario.sh` / `run-scenario-headless.sh`):

```bash
source tests/behavior/lib/assert.sh
assert_skill_loaded "$TRANSCRIPT_FILE" "security"
```

**Pass criteria:** the transcript shows `security/SKILL.md` was read
before (or as part of) responding — the agent didn't rely on remembering
"auth work needs the security skill" without the explicit trigger scan.
