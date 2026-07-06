# opencode-harness

One command to set up AI-assisted development on any machine.

## Quick Start

```bash
git clone git@github.com:YOURNAME/opencode-harness.git
cd opencode-harness
make setup
```

## After Setup (manual steps)

1. `opencode auth login`
2. Add API key to `~/.config/opencode/.env`
3. Select model on first run

## Initialize a Project

```bash
make init PROJECT=/path/to/project
```

## Full Documentation

See [GUIDE.md](./GUIDE.md)
