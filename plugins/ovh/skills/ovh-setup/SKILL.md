---
name: ovh-setup
description: "Use when the user needs to install or authenticate the CLI for OVHcloud Public Cloud — the OpenStack client (openstack) — set up OpenStack RC / OS_* credentials and application credentials, select a project/region, or control output format."
---

# OVHcloud Public Cloud Setup (OpenStack CLI)

OVHcloud **Public Cloud** instances run on **OpenStack**, so the working command-line tool is the official OpenStack client, binary `openstack`. (OVH does not ship a single general-purpose `ovh` CLI; account-level/API resources are managed through the OVH API or Terraform — see the note at the end.)

Verify with `openstack --version`.

## Installation

### pip (recommended)

```bash
pip install python-openstackclient
```

### Homebrew (macOS)

```bash
brew install openstackclient
```

### Debian/Ubuntu

```bash
sudo apt-get install python3-openstackclient
```

## Authentication

In the OVHcloud Control Panel: **Public Cloud → project → Users & Roles**, create (or pick) an OpenStack user, then **Download an OpenStack RC file** (`openrc.sh`) for that user. It contains the auth URL, project, region, and domain for your project.

### Source the RC file

```bash
source openrc.sh          # prompts for the user's OpenStack password, sets OS_* env vars
openstack server list
```

### Or set OS_* variables directly

```bash
export OS_AUTH_URL=https://auth.cloud.ovh.net/v3/
export OS_IDENTITY_API_VERSION=3
export OS_PROJECT_ID=<project-id>
export OS_PROJECT_NAME="<project-name>"
export OS_USERNAME="<user>"
export OS_PASSWORD="<password>"
export OS_REGION_NAME="GRA11"     # e.g. GRA11, SBG5, BHS5, WAW1, DE1, UK1
export OS_USER_DOMAIN_NAME="Default"
```

### Application credentials (better than a raw password for automation)

```bash
openstack application credential create cli-cred
# then use the printed id/secret:
export OS_AUTH_TYPE=v3applicationcredential
export OS_APPLICATION_CREDENTIAL_ID=<id>
export OS_APPLICATION_CREDENTIAL_SECRET=<secret>
```

You can also keep named profiles in `~/.config/openstack/clouds.yaml` and select one with `--os-cloud <name>`.

### Verify

```bash
openstack token issue
openstack server list
```

## Region / Project

OVH Public Cloud regions are codes like `GRA11`, `SBG5`, `BHS5`, `WAW1`, `DE1`, `UK1`, `SGP1`. Switch region with `OS_REGION_NAME` or `--os-region-name`. List what's available:

```bash
openstack region list
openstack flavor list      # instance sizes
openstack image list       # available OS images
```

## Output Format

```bash
openstack server list -f json
openstack server list -f json | jq '.[].Name'
openstack server list -f value -c ID -c Name
openstack server show <name> -f yaml
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--os-cloud <name>` | Use a named profile from `clouds.yaml` |
| `--os-region-name <region>` | Override the region |
| `-f, --format <fmt>` | `table` \| `json` \| `yaml` \| `value` \| `csv` |
| `-c <column>` | Restrict to specific columns |

## Note: account-level OVH resources

For non–Public-Cloud resources (domains, dedicated servers, billing, IP failover, etc.) OVH exposes the **OVH API** (`https://api.ovh.com`, with application key/secret + consumer key) rather than OpenStack. Those are typically managed via the OVH API directly, the community `ovh` API clients, or Terraform's `ovh` provider. This plugin focuses on Public Cloud compute via OpenStack.
