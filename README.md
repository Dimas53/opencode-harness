# opencode-harness

One command to set up AI-assisted development on any machine.

**OpenCode version:** v1.17.20 (tested)

See [INSTALL.md](./INSTALL.md) for full installation guide.

## Quick Start

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup
```

## After Setup — Start Any Project

### Primary path — shortcuts inside OpenCode

Open OpenCode in any directory and type:
- `new` — new project: interview → full doc structure generated
- `existing` — existing project: auto-analysis first → fills missing docs
- `analyze` — read-only audit: architecture map + security review + risk report
- `update-harness` — pull latest harness updates and apply globally
- `sync-templates` — check for new template files missing in current project

### Fallback — make commands (if OpenCode is not open yet)

```bash
make init PROJECT=/path/to/new-project
make init-existing PROJECT=/path/to/project  
make analyze PROJECT=/path/to/project
```

Copies templates and opens OpenCode automatically.

### Symlink (required for update-harness and sync-templates)

Run once after cloning to enable the update shortcuts:

```bash
make link
```

This creates `~/.opencode-harness` pointing to your local clone.

## Documentation

- [INSTALL.md](./INSTALL.md) — full installation guide
- [instructions/GUIDE.md](./instructions/GUIDE.md) — how the harness works
- [instructions/reference/](./instructions/reference/) — OpenCode commands, models, RTK workflow
- [instructions/diagrams/](./instructions/diagrams/) — architecture and installation diagrams
