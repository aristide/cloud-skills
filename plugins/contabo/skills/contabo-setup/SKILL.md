---
name: contabo-setup
description: "Use when the user needs to install, configure, or authenticate the Contabo CLI (cntb), set up OAuth2 API credentials, manage the config file, or control output format (json/yaml) for Contabo commands."
---

# Contabo CLI (cntb) Setup and Configuration

The CLI binary is `cntb`. Verify with `cntb --version`. It talks to the Contabo API, which authenticates with **OAuth2** (a client id/secret plus an API user and password).

## Installation

### Homebrew (macOS / Linux)

```bash
brew install contabo/tap/cntb
```

### Manual (GitHub Releases)

Download the binary for your platform from [github.com/contabo/cntb/releases](https://github.com/contabo/cntb/releases), then move it onto your `PATH`:

```bash
# Release assets are versioned — pick the current one from the releases page:
VER=v1.6
curl -sSLO "https://github.com/contabo/cntb/releases/download/${VER}/cntb_${VER}_linux_amd64.tar.gz"
tar -xzf "cntb_${VER}_linux_amd64.tar.gz" cntb
sudo mv cntb /usr/local/bin/
```

### Windows (PowerShell)

Release assets are versioned (e.g. `cntb_v1.6_windows_amd64.zip`), so download a specific version, extract `cntb.exe`, and put it on your `PATH`:

```powershell
$dest = "$env:USERPROFILE\cntb"
# Pin a version — see https://github.com/contabo/cntb/releases for the current one:
Invoke-WebRequest -Uri https://github.com/contabo/cntb/releases/download/v1.6/cntb_v1.6_windows_amd64.zip -OutFile cntb.zip
Expand-Archive -Path cntb.zip -DestinationPath $dest -Force
# Add to PATH for this session (or add $dest permanently via System → Environment Variables):
$env:Path += ";$dest"
cntb --version
```

To always grab the latest release without hard-coding a version, resolve the asset via the GitHub API:

```powershell
$dest = "$env:USERPROFILE\cntb"
$url = (Invoke-RestMethod https://api.github.com/repos/contabo/cntb/releases/latest).assets `
  | Where-Object name -like '*windows_amd64.zip' | Select-Object -Expand browser_download_url
Invoke-WebRequest -Uri $url -OutFile cntb.zip
Expand-Archive -Path cntb.zip -DestinationPath $dest -Force
$env:Path += ";$dest"
cntb --version
```

> Use the `*windows_arm64.zip` asset on ARM devices. Alternatively, build from source with `go install github.com/contabo/cntb@latest`.

### Docker

```bash
docker run --rm contabo/cntb:latest get instances
```

## Authentication

Contabo's API uses OAuth2. You need four values, all created in the [Contabo Customer Control Panel](https://my.contabo.com) under **Account → API**:

- **Client ID** (`oauth2-clientid`)
- **Client Secret** (`oauth2-client-secret`)
- **API User** — your Contabo account email (`oauth2-user`)
- **API Password** — a separate API password you set in the control panel (`oauth2-password`), *not* your login password.

### Store credentials

```bash
cntb config set-credentials \
  --oauth2-clientid "<client-id>" \
  --oauth2-client-secret "<client-secret>" \
  --oauth2-user "<api-user-email>" \
  --oauth2-password "<api-password>"
```

This writes `~/.cntb.yaml`. You can also point at a custom file with `--config <path>` or set values via environment variables (`CNTB_OAUTH2_CLIENTID`, `CNTB_OAUTH2_CLIENT_SECRET`, `CNTB_OAUTH2_USER`, `CNTB_OAUTH2_PASSWORD`).

### Verify

```bash
cntb get instances
```

If credentials are valid this returns your instances (possibly an empty list); an auth error means the API user/password or client id/secret is wrong.

## Config File

Default location: `~/.cntb.yaml`. Inspect or override the path:

```bash
cntb --config ~/.cntb.yaml get instances
```

## Output Format

Most `get` commands accept `-o` / `--output` with `json` or `yaml` (default is a human table).

```bash
cntb get instances -o json
cntb get instances -o json | jq '.[].instanceId'
cntb get instance <instance-id> -o yaml
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--config <path>` | Use a specific config file |
| `-o, --output <fmt>` | `json` or `yaml` (default: table) |
| `--debug` | Print the underlying API request/response |

## Concepts

- Contabo products are **subscriptions**. Creating an instance starts a billing contract; you stop billing by **cancelling** the instance (`cntb cancel instance <id>`), not by deleting a record.
- **Regions** are coarse codes such as `EU`, `US-central`, `US-east`, `US-west`, `SIN`, `JPN`, `AUS`, `IND`.
- **SSH keys and root passwords are stored as "secrets"** and referenced by id when creating instances — see the `contabo-compute` skill.
