# Scenario: skill-router-auth

**Fixture:** `fixtures/skill-router-auth/setup.sh`

**Source:** T-F3 (implementation-plan-2 Wave F), rewritten 2026-08-21.

**What this case is really guarding, and why it used to fail.** The
original framing said a code-level router "isn't buildable with the
current API" and that the mandatory Auto-Loading scan in `AGENTS.md` was
the only fallback. Both halves were wrong by the time it mattered:
OpenCode registers every skill with YAML frontmatter as a native `skill`
tool and lists it, with its description, in the system prompt under
`<available_skills>`. No plugin router is needed — the mechanism ships
with the engine.

What actually broke the case was the harness itself: `AGENTS.md` told the
agent to load skills by reading `~/.config/opencode/skills/<domain>/SKILL.md`
and asserted, in prose, that no mechanism existed. Measured live on
2026-08-20/21 in a real project: 2 correct loads out of 9 runs. After the
instruction was changed to call the `skill` tool by name, the same prompts
gave 7 out of 7 — five identical `refactor` runs plus `deploy` and `ADR`,
both of which had failed the day before.

So this case now guards a specific regression: **the harness telling the
model to reach for a file instead of the tool the engine already gives
it.** Either loading path passes the assertion; skipping the skill fails.

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

**Pass criteria:** the transcript shows the `security` skill was loaded
before (or as part of) responding — either as a `skill` tool call or as a
read of `security/SKILL.md`. Naming the skill without loading it does not
count; that is exactly the failure mode measured in the live runs, where
the agent said which skill applied and then went straight to the code.
