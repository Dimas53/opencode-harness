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
make init PROJECT=/path/to/new-project         # new empty project: interview (9 questions) → generates full doc structure
make init-existing PROJECT=/path/to/project    # existing project with code: auto-analysis first → then fills missing docs
make analyze PROJECT=/path/to/project          # read-only audit: architecture map + security review + risk report, no file changes
```

Copies templates, opens OpenCode automatically and starts the agent.

## Documentation

- [INSTALL.md](./INSTALL.md) — full installation guide
- [instructions/GUIDE.md](./instructions/GUIDE.md) — how the harness works
- [instructions/reference/](./instructions/reference/) — OpenCode commands, models, RTK workflow
- [instructions/diagrams/](./instructions/diagrams/) — architecture and installation diagrams
