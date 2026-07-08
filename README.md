# opencode-harness

One command to set up AI-assisted development on any machine.

See [INSTALL.md](./INSTALL.md) for full installation guide.

## Quick Start

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup
```

## After Setup — Start Any Project

### Automatic (with templates)

```bash
make init PROJECT=/path/to/new-project         # new project — interview + docs
make init-existing PROJECT=/path/to/project    # existing project — analyze + docs
make analyze PROJECT=/path/to/project          # analyze only — audit, no file mods
```

Copies templates, opens OpenCode automatically and starts the agent.

## Documentation

- [INSTALL.md](./INSTALL.md) — full installation guide
- [docs/GUIDE.md](./docs/GUIDE.md) — how the harness works
- [docs/reference/](./docs/reference/) — OpenCode commands, models, RTK workflow
- [docs/diagrams/](./docs/diagrams/) — architecture and installation diagrams
