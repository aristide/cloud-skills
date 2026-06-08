---
name: oracle-setup
description: "Use when the user needs to install, configure, or authenticate the Oracle Cloud Infrastructure CLI (oci), set up the config file and API keys, use session/token auth, select a profile/region/compartment, or control output format."
---

# Oracle Cloud Infrastructure CLI (oci) Setup and Configuration

The CLI binary is `oci`. Verify with `oci --version`. OCI identifies everything by **OCID** (e.g. `ocid1.compartment.oc1..aaaa...`), and most commands require a **compartment OCID**.

## Installation

### Script (macOS / Linux)

```bash
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
```

### Homebrew (macOS)

```bash
brew install oci-cli
```

### pip

```bash
pip install oci-cli
```

### Windows (PowerShell)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.ps1'))"
```

## Authentication

OCI auth uses an API signing key pair plus identifiers stored in `~/.oci/config`.

### Interactive config (API key auth)

```bash
oci setup config
```

Prompts for your **user OCID**, **tenancy OCID**, **region**, and generates an API key pair. Then upload the generated public key to the Console: **Profile → User settings → API keys → Add API key** (or paste `~/.oci/oci_api_key_public.pem`). Find OCIDs in the Console under your user and tenancy details.

### Verify

```bash
oci iam region list
oci os ns get        # returns your Object Storage namespace if auth works
```

### Browser/session token auth (no pre-shared key; good for MFA)

```bash
oci session authenticate --region <region> --profile-name myprofile
# refresh before it expires:
oci session refresh --profile myprofile
```

### Instance principals (running on an OCI VM, no keys)

Add `--auth instance_principal` to commands.

## Profiles, Region, Compartment

`~/.oci/config` holds named profiles (default `DEFAULT`).

```bash
oci --profile myprofile compute instance list --compartment-id <ocid>
oci --region eu-frankfurt-1 iam region list
```

Tip: export a compartment OCID to avoid repeating it:

```bash
export TF_COMPARTMENT=ocid1.compartment.oc1..aaaa...
oci compute instance list --compartment-id "$TF_COMPARTMENT"
```

List regions and compartments:

```bash
oci iam region list
oci iam compartment list --compartment-id-in-subtree true --all
```

## Output Format

Default output is JSON. Use `--output table` for humans, and `--query` (JMESPath) to shape results.

```bash
oci compute instance list --compartment-id <ocid> --output table
oci compute instance list --compartment-id <ocid> \
  --query 'data[].{name:"display-name",state:"lifecycle-state",shape:shape}' --output table
oci compute instance list --compartment-id <ocid> | jq '.data[]."display-name"'
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--profile <name>` | Use a named profile from `~/.oci/config` |
| `--region <region>` | Override the region, e.g. `eu-frankfurt-1` |
| `--compartment-id <ocid>` | Target compartment (required by most resource commands) |
| `--output table\|json` | Output format (default: json) |
| `--query <jmespath>` | Filter/shape the response |
| `--auth <type>` | `api_key` (default) \| `session_token` \| `instance_principal` |

## Official documentation

See [`../../docs/README.md`](../../docs/README.md) in this plugin for curated links to the official OCI CLI reference, API docs, pricing, regions, and status pages.
