---
name: linode-setup
description: "Use when the user needs to install, configure, or authenticate the Linode / Akamai CLI (linode-cli), set up API tokens, manage configuration profiles and defaults, or control output format (table/json/text) for Linode commands."
---

# Linode CLI (linode-cli) Setup and Configuration

The CLI binary is `linode-cli`. Verify with `linode-cli --version`. It is the official CLI for Linode (Akamai Connected Cloud).

## Installation

### pip (any platform with Python 3)

```bash
pip install linode-cli --upgrade
```

### Homebrew (macOS / Linux)

```bash
brew install linode-cli
```

### Windows

```powershell
pip install linode-cli
```

## Authentication

Create a Personal Access Token at <https://cloud.linode.com/profile/tokens> (Read/Write).

### Interactive configuration

```bash
linode-cli configure
```

Prompts for the token and lets you pick default **region**, **type**, and **image** (these become defaults so you can omit them on `create`). Stored in `~/.config/linode-cli`.

### Token via environment (CI / non-interactive)

```bash
export LINODE_CLI_TOKEN=<token>
linode-cli linodes list
```

### Verify

```bash
linode-cli account view
```

## Configuration Profiles & Defaults

`linode-cli configure` can store multiple named profiles; switch with `--as-user <username>` or by editing `~/.config/linode-cli`. Inspect defaults:

```bash
linode-cli show-active-user
```

List the building blocks for defaults:

```bash
linode-cli regions list
linode-cli linodes types
linode-cli images list
```

## Output Format

Default output is a table. Use `--json` (full structured data), `--text` with `--format` to select columns, `--no-headers`, and `--pretty`.

```bash
linode-cli linodes list --json
linode-cli linodes list --json | jq '.[].label'
linode-cli linodes list --text --format "id,label,status,ipv4,region" --no-headers
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--token <token>` | Override the API token for one command |
| `--as-user <username>` | Use a specific configured profile |
| `--json` | JSON output |
| `--text --format <cols>` | Tab/space output with chosen columns |
| `--no-headers` | Omit the header row |
| `--all` | Return all columns |

## Official documentation

See [`../../docs/README.md`](../../docs/README.md) in this plugin for curated links to the official Linode CLI reference, API docs, pricing, regions, and status pages.
