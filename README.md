# opencode-harness

One command to set up AI-assisted development on any machine.

See [INSTALL.md](./INSTALL.md) for full installation guide.

## Quick Start

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup          # fresh machine
# OR
make setup-lite     # OpenCode already installed
# OR
make docs-only PROJECT=/path/to/project  # templates only
```

## After Setup — Start Any Project

### Automatic (with templates)

```bash
make init PROJECT=/path/to/new-project      # empty project
make init-existing PROJECT=/path/to/project  # existing project
```

Copies templates, opens OpenCode. Type the command shown in terminal.

### Manual

```bash
cd /path/to/your/project
opencode
```

Type `Start`, wait for session brief, then:

```
Load ~/.config/opencode/skills/harness-init/SKILL.md and run it.
```

## Documentation

- [INSTALL.md](./INSTALL.md) — full installation guide (3 scenarios)
- [docs/GUIDE.md](./docs/GUIDE.md) — how the harness works
- [docs/reference/](./docs/reference/) — OpenCode commands, models, RTK workflow
- [docs/diagrams/](./docs/diagrams/) — architecture and installation diagrams
