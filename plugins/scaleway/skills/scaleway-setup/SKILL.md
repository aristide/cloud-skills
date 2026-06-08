---
name: scaleway-setup
description: "Use when the user needs to install, configure, or authenticate the Scaleway CLI (scw), initialize a profile, manage API keys, set the default project/organization/zone/region, or control output format for Scaleway commands."
---

# Scaleway CLI (scw) Setup and Configuration

The CLI binary is `scw`. Verify with `scw version`.

## Installation

### macOS

```bash
brew install scw
```

### Linux

```bash
curl -s https://raw.githubusercontent.com/scaleway/scaleway-cli/master/scripts/get.sh | sh
```

### Windows

```powershell
winget install Scaleway.cli
```

## Authentication

### Interactive init (recommended first run)

```bash
scw init
```

Prompts for your **Access Key** and **Secret Key** (create them in the Scaleway console under *IAM → API keys*), default project, zone, and region. Writes `~/.config/scw/config.yaml`.

### Non-interactive / environment variables

```bash
export SCW_ACCESS_KEY=<access-key>
export SCW_SECRET_KEY=<secret-key>
export SCW_DEFAULT_PROJECT_ID=<project-id>
export SCW_DEFAULT_ORGANIZATION_ID=<org-id>
export SCW_DEFAULT_ZONE=fr-par-1
export SCW_DEFAULT_REGION=fr-par
```

### Verify

```bash
scw account project list
scw config info
```

## Profiles (multiple accounts/projects)

```bash
scw config profile list
scw -p <profile> instance server list      # use a profile for one command
export SCW_PROFILE=prod                     # use it for the session
```

Edit profiles in `~/.config/scw/config.yaml` or with `scw config set`:

```bash
scw config set default-zone=nl-ams-1
scw config get default-project-id
```

## Zones and Regions

Scaleway is organized as **regions** (e.g. `fr-par`, `nl-ams`, `pl-waw`) containing **zones** (e.g. `fr-par-1`, `fr-par-2`). Instances are zonal.

```bash
scw instance server list zone=nl-ams-1
scw --help                                  # lists available zones/regions in the global flags
```

## Output Format

`-o` / `--output` accepts `human` (default), `json`, `yaml`. Many commands accept `--debug` for the underlying API call.

```bash
scw instance server list -o json
scw instance server list -o json | jq '.[].name'
scw instance server list -o table=ID,Name,State,PublicIP
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `-p, --profile <name>` | Use a named profile |
| `zone=<zone>` / `region=<region>` | Positional scope on most commands (e.g. `zone=fr-par-1`) |
| `-o, --output <fmt>` | human \| json \| yaml |
| `--debug` | Print the underlying API request/response |
| `project-id=<id>` | Target a specific project |

## Autocomplete

```bash
scw autocomplete install
```

## Official documentation

See [`../../docs/README.md`](../../docs/README.md) in this plugin for curated links to the official Scaleway CLI reference, API docs, pricing, regions, and status pages.
