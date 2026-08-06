#!/bin/bash
# tests/behavior/fixtures/skill-router-auth/setup.sh
# T-F3 (implementation-plan-2 Wave F): client-profile fixture for the
# skill-router eval — a plain adopted project, no mutation needed. The
# scenario itself checks whether the agent loads security/SKILL.md when
# the prompt says "add auth" without the word "security" appearing.
# Prints ONLY the fixture directory path to stdout; everything else to stderr.
set -euo pipefail

HARNESS_ROOT="$(git rev-parse --show-toplevel)"
bash "$HARNESS_ROOT/tests/behavior/fixtures/_lib/make-client-project.sh"
