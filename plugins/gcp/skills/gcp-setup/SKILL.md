---
name: gcp-setup
description: "Use when the user needs to install, configure, or authenticate the Google Cloud CLI (gcloud), log in, set the active project/region/zone, manage configurations, application-default credentials, or control output format for GCP commands."
---

# Google Cloud CLI (gcloud) Setup and Configuration

The CLI binary is `gcloud` (part of the Google Cloud SDK). Verify with `gcloud version`.

## Installation

### macOS / Linux (interactive installer)

```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

### macOS (Homebrew)

```bash
brew install --cask google-cloud-sdk
```

### Debian/Ubuntu (apt)

```bash
sudo apt-get install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli
```

### Windows

```powershell
winget install Google.CloudSDK
```

## Authentication

There are two distinct credential types — set up both for full functionality.

### User login (for gcloud commands)

```bash
gcloud auth login              # opens a browser
gcloud auth login --no-launch-browser   # headless / remote shells
```

### Application Default Credentials (for SDKs / Terraform / local apps)

```bash
gcloud auth application-default login
```

### Service account (automation / CI)

```bash
gcloud auth activate-service-account --key-file=<key>.json
```

### Inspect credentials

```bash
gcloud auth list                # accounts and the active one
gcloud config get-value account
```

## Project, Region, Zone

Most Compute Engine commands need a project and a zone.

```bash
gcloud projects list
gcloud config set project <project-id>
gcloud config set compute/region europe-west1
gcloud config set compute/zone europe-west1-b
```

Pass per-command instead with `--project`, `--region`, or `--zone`.

## Named Configurations (multiple environments)

A configuration bundles account + project + region/zone.

```bash
gcloud config configurations create prod
gcloud config configurations activate prod
gcloud config configurations list
gcloud config list                 # show the active configuration's values
```

## Enabling APIs

A service must be enabled in the project before use:

```bash
gcloud services enable compute.googleapis.com
gcloud services list --enabled
```

## Output Format

`--format` accepts `json`, `yaml`, `csv`, `table(...)`, `value(...)`, and more. `--filter` narrows results server-side.

```bash
gcloud compute instances list --format=json
gcloud compute instances list --format='table(name,zone,status)'
gcloud compute instances list --filter='status=RUNNING' --format='value(name)'
```

### With jq

```bash
gcloud compute instances list --format=json | jq '.[].name'
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--project <id>` | Target a specific project |
| `--zone <zone>` / `--region <region>` | Override location |
| `--format <fmt>` | json \| yaml \| csv \| table(...) \| value(...) |
| `--filter <expr>` | Server-side filter expression |
| `--quiet, -q` | Disable interactive prompts (assume defaults / yes) |
| `--configuration <name>` | Use a specific named configuration |
