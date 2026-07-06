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
4. Copy `global/opencode-config.example.jsonc` to `~/.config/opencode/opencode.jsonc`
5. Replace `/YOUR/HOME/PATH` with your home directory
6. Replace `YOUR_DIRECTUS_TOKEN` with your actual token

## Initialize a Project

```bash
make init PROJECT=/path/to/project
```

## Full Documentation

See [GUIDE.md](./GUIDE.md)
