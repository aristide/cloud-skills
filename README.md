# cloud-skills — multi-cloud CLI plugins for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code Marketplace](https://img.shields.io/badge/Claude_Code-Marketplace-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)

A **Claude Code plugin marketplace** that lets you manage your infrastructure across cloud providers through natural conversation — each provider wrapped as its own installable plugin around its official CLI. **Install just the providers you use, or all of them.**

---

## Providers

Each plugin carries a **setup** and **compute** skill, **status / deploy / cleanup** commands, and a safety hook, plus a skill for each additional domain the provider actually offers — drawn from **networking · storage · security · dns · kubernetes · containers · serverless**. A plugin ships skills only for services that exist (a bare-VPS host ships fewer than a hyperscaler); the Coverage column notes each provider's headline services and any gaps. Every plugin is generated from a shared [template](templates/provider-template/).

| Plugin | CLI | Coverage |
|--------|-----|----------|
| **aws** | `aws` | EC2, VPC, EBS/S3, IAM/ACM, Route 53, EKS, ECS/App Runner, Lambda |
| **azure** | `az` | VMs, VNet, disks/Blob, Key Vault/RBAC, Azure DNS, AKS, Container Apps/ACI, Functions |
| **contabo** | `cntb` | VPS/VDS, private networks + firewall, object storage, secrets — *DNS is control-panel-only (no CLI/API); no K8s/containers/serverless* |
| **digitalocean** | `doctl` | Droplets, VPC/firewall/LB, volumes/Spaces, certs, DNS, DOKS, App Platform, Functions |
| **gcp** | `gcloud` | Compute Engine, VPC, disks/Cloud Storage, IAM/SSL, Cloud DNS, GKE, Cloud Run, Cloud Functions |
| **hcloud** | `hcloud` | Servers, networking, storage, DNS, security |
| **linode** | `linode-cli` | Linodes, VPC/firewall/NodeBalancer, volumes/object storage, DNS, LKE — *no containers/serverless* |
| **oracle** | `oci` | Compute, VCN, block/object storage, IAM/certs, DNS, OKE, Container Instances, Functions |
| **ovh** | `openstack` | OVH Public Cloud: instances, networking, block/object storage, keypairs — *DNS & Managed K8s via OVH API/Terraform; no containers or serverless* |
| **scaleway** | `scw` | Instances, VPC/LB, block/object storage, IAM, DNS, Kapsule, Serverless Containers, Functions |
| **vultr** | `vultr-cli` | Instances, VPC/firewall/LB, block/object storage, DNS, VKE Kubernetes — *no containers or serverless* |

Each provider plugin contributes auto-activating **skills** (the model loads them when your request matches), a **`/<provider>-status`** slash command, and an advisory **safety hook** that warns before destructive operations on that provider's CLI.

---

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- The official CLI for each provider you install, authenticated:
  `aws` · `az` · `cntb` · `doctl` · `gcloud` · `hcloud` · `linode-cli` · `oci` · `openstack` (OVH) · `scw` · `vultr-cli` (the `*-setup` skill in each plugin walks you through it)

### Add the marketplace, then install providers

```text
/plugin marketplace add aristide/cloud-skills

/plugin install aws@cloud-skills          # one provider…
/plugin install azure@cloud-skills
/plugin install contabo@cloud-skills
/plugin install digitalocean@cloud-skills
/plugin install gcp@cloud-skills
/plugin install hcloud@cloud-skills
/plugin install linode@cloud-skills
/plugin install oracle@cloud-skills
/plugin install ovh@cloud-skills
/plugin install scaleway@cloud-skills
/plugin install vultr@cloud-skills        # …or all of them
```

There is no single "install all" command — install each provider you want. While developing locally you can point the marketplace at a path: `/plugin marketplace add ./cloud-skills`.

---

## Usage examples

**AWS:** "Launch a t3.micro from the latest Amazon Linux AMI in eu-central-1" · `/aws-status`
**Azure:** "Create a Standard_B1s Ubuntu VM in resource group web-rg" · `/azure-status`
**Contabo:** "List my VPS instances and show which are stopped" · `/contabo-status`
**DigitalOcean:** "Create an Ubuntu s-1vcpu-1gb Droplet in fra1 with my SSH key" · `/digitalocean-status`
**GCP:** "Create an e2-micro Debian instance in europe-west1-b" · `/gcp-status`
**Hetzner (hcloud):** "Spin up an Ubuntu server in Nuremberg" · `/hcloud-status`
**Linode:** "Create a g6-nanode-1 Debian 12 instance in eu-central" · `/linode-status`
**Oracle:** "Launch a VM.Standard.A1.Flex instance in my compartment" · `/oracle-status`
**OVH:** "Create a b3-8 Ubuntu instance on Ext-Net in GRA11" · `/ovh-status`
**Scaleway:** "Create a DEV1-S instance in fr-par-1" · `/scaleway-status`
**Vultr:** "Deploy a vc2-1c-1gb instance in fra" · `/vultr-status`

Because each safety hook only reacts to its own CLI, you can have several providers installed at once without warnings cross-firing.

---

## Repository layout

```
cloud-skills/
├── .claude-plugin/
│   └── marketplace.json          # marketplace manifest (lists every provider plugin)
├── plugins/                      # one installable plugin per provider
│   ├── aws/  azure/  contabo/  digitalocean/  gcp/  hcloud/
│   ├── linode/  oracle/  ovh/  scaleway/  vultr/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/<prov>-setup,  <prov>-compute,  …one per domain the provider offers
│   │   │            (networking, storage, security, dns, kubernetes, containers, serverless)
│   │   ├── commands/<prov>-{status,deploy,cleanup}.md
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

Some plugins bundle reference material or derive from a provider's official open-source CLI tooling, used under the respective licenses — see each plugin's `docs/` and the repository [LICENSE](LICENSE). (For example, the `hcloud` plugin's bundled reference docs come from the [hcloud CLI](https://github.com/hetznercloud/cli) by Hetzner Cloud GmbH under the MIT License, per `plugins/hcloud/docs/LICENSE`, building on the original [hcloud-skills](https://github.com/danjdewhurst/hcloud-skills) plugin by Daniel Dewhurst.)

## License

[MIT](LICENSE)
