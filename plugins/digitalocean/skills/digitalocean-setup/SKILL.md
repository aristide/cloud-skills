---
name: digitalocean-setup
description: "Use when the user needs to install, configure, or authenticate the DigitalOcean CLI (doctl), manage API tokens and auth contexts, select a default region, or control output format (text/json) for DigitalOcean commands."
---

# DigitalOcean CLI (doctl) Setup and Configuration

The CLI binary is `doctl`. Verify with `doctl version`.

## Installation

### macOS / Linux (Homebrew)

```bash
brew install doctl
```

### Linux (Snap)

```bash
sudo snap install doctl
```

### Manual (GitHub Releases)

Release assets are versioned (e.g. `doctl-1.160.1-linux-amd64.tar.gz`), so pin a version — check [the releases page](https://github.com/digitalocean/doctl/releases) for the current one:

```bash
VER=1.160.1
curl -sL "https://github.com/digitalocean/doctl/releases/download/v${VER}/doctl-${VER}-linux-amd64.tar.gz" | tar -xz
sudo mv doctl /usr/local/bin/
```

### Windows

```powershell
winget install DigitalOcean.doctl
```

## Authentication

Create a Personal Access Token at <https://cloud.digitalocean.com/account/api/tokens> (needs read+write scope).

### Initialize

```bash
doctl auth init
```

Prompts for the token and stores it in `~/.config/doctl/config.yaml`.

### Multiple accounts (auth contexts)

```bash
doctl auth init --context personal
doctl auth init --context work
doctl auth switch --context work
doctl auth list
```

Use `--context <name>` on any command to target a specific account, or `--access-token <token>` / the `DIGITALOCEAN_ACCESS_TOKEN` env var.

### Verify

```bash
doctl account get
```

## Region and Defaults

There is no global default region; pass `--region <slug>` per command. List available regions, sizes, and images:

```bash
doctl compute region list
doctl compute size list
doctl compute image list-distribution --public
```

## Output Format

Commands default to a table. Use `--output json` for full structured data, or `--format` + `--no-header` to pick columns.

```bash
doctl compute droplet list --output json
doctl compute droplet list --output json | jq '.[].name'
doctl compute droplet list --format ID,Name,PublicIPv4,Status --no-header
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--context <name>` | Use a specific auth context |
| `--access-token <token>` | Override the token for one command |
| `--output text\|json` | Output format (default: text table) |
| `--format <cols>` | Comma-separated columns to display |
| `--no-header` | Omit the table header |
