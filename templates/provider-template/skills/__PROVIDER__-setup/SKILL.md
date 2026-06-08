---
name: __PROVIDER__-setup
description: "Use when the user needs to install, configure, or authenticate the __PROVIDER_DISPLAY__ CLI (__CLI__), manage profiles/projects/regions, or control output format for __PROVIDER_DISPLAY__ commands."
---

# __PROVIDER_DISPLAY__ CLI Setup and Configuration

The CLI binary is `__CLI__`. Verify with `__CLI__ version` (or `__CLI__ --version`).

## Installation

### macOS

```bash
# brew install __CLI__   # replace with the real package
```

### Linux

```bash
# replace with the official install command
```

### Windows

```powershell
# winget install <PublisherId>   # replace with the real package
```

## Authentication

```bash
# __CLI__ login / init / configure — replace with the real auth flow
```

Describe where credentials are stored, how to use profiles/service accounts/API keys, and how to verify the active identity.

### Verify

```bash
# __CLI__ whoami / account show — confirm the active account
```

## Project / Region / Zone Selection

Explain the provider's scoping model (account/subscription/project, region, zone) and how to set defaults vs. per-command flags.

## Output Format

State the provider's output flag (e.g. `-o json`) and give a `jq` example:

```bash
# __CLI__ <list-command> -o json | jq '.[].name'
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--profile / --project` | Target a specific account/project |
| `--region / --zone` | Override location |
| `-o, --output` | Output format |
