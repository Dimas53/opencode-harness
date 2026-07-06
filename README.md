# opencode-harness

One command to set up AI-assisted development on any machine.

## Quick Start

```bash
git clone git@github.com:Dimas53/opencode-harness.git
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
7. Run `rtk gain` to verify RTK is working — RTK compresses terminal output before sending to LLM, saves 80-90% tokens on git/npm commands

## Windows Users

Windows requires WSL2 for bash scripts. See [GUIDE.md section 10](./GUIDE.md#10-windows--cross-platform) for full Windows setup instructions.
Alternative: run manual steps from GUIDE.md instead of make commands.

## Initialize a Project

```bash
make init PROJECT=/path/to/project
```

## Full Documentation

See [docs/GUIDE.md](./docs/GUIDE.md)
