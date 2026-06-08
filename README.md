# cloud-skills — multi-cloud CLI plugins for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code Marketplace](https://img.shields.io/badge/Claude_Code-Marketplace-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)

A **Claude Code plugin marketplace** that lets you manage your infrastructure across cloud providers through natural conversation — each provider wrapped as its own installable plugin around its official CLI. **Install just the providers you use, or all of them.**

---

## Providers

| Plugin | CLI | Coverage |
|--------|-----|----------|
| **hcloud** | `hcloud` | Full Hetzner Cloud: servers, networking, storage, DNS, security, setup + 260+ bundled reference pages |
| **aws** | `aws` | Auth/profiles/SSO, EC2 compute lifecycle, status command |
| **azure** | `az` | Auth/subscriptions, Virtual Machine lifecycle, status command |
| **gcp** | `gcloud` | Auth/projects, Compute Engine lifecycle, status command |
| **scaleway** | `scw` | Auth/profiles, Instance lifecycle, status command |

Each provider plugin contributes auto-activating **skills** (the model loads them when your request matches), a **`/<provider>-status`** slash command, and an advisory **safety hook** that warns before destructive operations on that provider's CLI.

> The `hcloud` plugin is feature-complete. `aws`, `azure`, `gcp`, and `scaleway` ship a **skeleton + core compute** (auth + instance lifecycle) and are designed to be extended — see [Adding a provider](docs/ADDING-A-PROVIDER.md).

---

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- The official CLI for each provider you install, authenticated:
  `hcloud` · `aws` · `az` · `gcloud` · `scw` (the `*-setup` skill in each plugin walks you through it)

### Add the marketplace, then install providers

```text
/plugin marketplace add <owner>/cloud-skills

/plugin install hcloud@cloud-skills      # one provider…
/plugin install aws@cloud-skills
/plugin install azure@cloud-skills
/plugin install gcp@cloud-skills
/plugin install scaleway@cloud-skills    # …or all of them
```

There is no single "install all" command — install each provider you want. While developing locally you can point the marketplace at a path: `/plugin marketplace add ./cloud-skills`.

---

## Usage examples

**Hetzner:** "Spin up an Ubuntu server in Nuremberg" · `/hcloud-status`
**AWS:** "Launch a t3.micro from the latest Amazon Linux AMI in eu-central-1" · `/aws-status`
**Azure:** "Create a Standard_B1s Ubuntu VM in resource group web-rg" · `/azure-status`
**GCP:** "Create an e2-micro Debian instance in europe-west1-b" · `/gcp-status`
**Scaleway:** "Create a DEV1-S instance in fr-par-1" · `/scaleway-status`

Because each safety hook only reacts to its own CLI, you can have several providers installed at once without warnings cross-firing.

---

## Repository layout

```
cloud-skills/
├── .claude-plugin/
│   └── marketplace.json          # marketplace manifest (lists every provider plugin)
├── plugins/
│   ├── hcloud/                   # one installable plugin per provider
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/  commands/  hooks/  docs/
│   ├── aws/  azure/  gcp/  scaleway/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/<prov>-setup/  skills/<prov>-compute/
│   │   ├── commands/<prov>-status.md
│   │   └── hooks/  (hooks.json + scripts/<prov>-safety.sh)
├── templates/
│   └── provider-template/        # copy-me scaffold for the next provider
└── docs/
    └── ADDING-A-PROVIDER.md       # step-by-step guide
```

---

## Adding a provider

Copy `templates/provider-template/` to `plugins/<provider>/`, replace the `__PROVIDER__` / `__CLI__` placeholders with the real CLI and commands, and add one entry to `marketplace.json`. Full instructions: **[docs/ADDING-A-PROVIDER.md](docs/ADDING-A-PROVIDER.md)**.

---

## Acknowledgements

The bundled `hcloud` plugin and its reference documentation under `plugins/hcloud/docs/` are derived from the [hcloud CLI](https://github.com/hetznercloud/cli) project by [Hetzner Cloud GmbH](https://www.hetzner.com/cloud), used under the MIT License (`plugins/hcloud/docs/LICENSE`), and from the original [hcloud-skills](https://github.com/danjdewhurst/hcloud-skills) plugin by Daniel Dewhurst.

## License

[MIT](LICENSE)
