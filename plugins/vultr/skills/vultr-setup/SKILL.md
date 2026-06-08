---
name: vultr-setup
description: "Use when the user needs to install, configure, or authenticate the Vultr CLI (vultr-cli), set up the API key, manage the config file, or control output format for Vultr commands."
---

# Vultr CLI (vultr-cli) Setup and Configuration

The CLI binary is `vultr-cli`. Verify with `vultr-cli version`.

## Installation

### Homebrew (macOS / Linux)

```bash
brew install vultr/vultr-cli/vultr-cli
```

### Go

```bash
go install github.com/vultr/vultr-cli/v3@latest
```

### Manual (GitHub Releases)

Release assets are versioned (e.g. `vultr-cli_v3.10.0_linux_amd64.tar.gz`), so pin a version — check [the releases page](https://github.com/vultr/vultr-cli/releases) for the current one:

```bash
VER=v3.10.0
curl -sSLO "https://github.com/vultr/vultr-cli/releases/download/${VER}/vultr-cli_${VER}_linux_amd64.tar.gz"
tar -xzf "vultr-cli_${VER}_linux_amd64.tar.gz" vultr-cli
sudo mv vultr-cli /usr/local/bin/
```

(macOS assets use `macOs` in the name, e.g. `vultr-cli_v3.10.0_macOs_arm64.tar.gz`.)

## Authentication

Create a Personal Access Token in the [Vultr Customer Portal](https://my.vultr.com/settings/#settingsapi) under **Account → API**. Also allow your IP under the API access control list there, or calls will be rejected.

### Via environment variable (recommended)

```bash
export VULTR_API_KEY="<your-api-key>"
vultr-cli instance list
```

### Via config file

Create `~/.vultr-cli.yaml`:

```yaml
api-key: <your-api-key>
```

Point at a different file with `--config <path>`.

### Verify

```bash
vultr-cli account info
```

## Regions, Plans, OS Images

Look up the identifiers you'll pass to `instance create`:

```bash
vultr-cli regions list      # region ids, e.g. ewr, fra, nrt
vultr-cli plans list        # plan ids, e.g. vc2-1c-1gb
vultr-cli os list           # OS ids for --os
vultr-cli apps list         # one-click app ids for --app
```

(If a subcommand name differs in your version, run `vultr-cli --help` / `vultr-cli <group> --help`.)

## Output Format

Recent versions support `-o json` / `-o yaml`; otherwise commands print a table.

```bash
vultr-cli instance list -o json
vultr-cli instance list -o json | jq '.instances[].id'
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--config <path>` | Use a specific config file |
| `-o, --output <fmt>` | `json` \| `yaml` (where supported; default: table) |

## Concept

- A powered-off Vultr instance **still bills** — destroy it with `vultr-cli instance delete <id>` to stop charges.
- API calls require your current IP to be on the API access control list in the portal.

## Official documentation

See [`../../docs/README.md`](../../docs/README.md) in this plugin for curated links to the official vultr-cli reference, API docs, pricing, regions, and status pages.
