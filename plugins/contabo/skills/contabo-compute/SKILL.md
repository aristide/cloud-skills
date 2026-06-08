---
name: contabo-compute
description: "Use when the user needs to create, list, inspect, start, stop, restart, shutdown, reinstall, or cancel Contabo VPS/VDS instances, manage SSH-key/password secrets and snapshots, or look up images."
---

# Contabo Compute (VPS / VDS Instances)

All commands are `cntb <verb> instance[s] ...`. Confirm exact flags with `cntb create instance --help` etc. — Contabo's product/region/image identifiers change over time, so look them up live rather than hard-coding.

Contabo instances are **subscriptions**: `create` opens a billing contract and `cancel` ends it. There is no plain "delete an instance" — use `cancel`.

## Instance Lifecycle

### Create an Instance

```bash
cntb create instance \
  --imageId <image-uuid> \
  --productId <product-id> \
  --region <region> \
  --period <months> \
  --displayName <name>
```

Common flags (verify with `cntb create instance --help`):
- `--imageId <uuid>` - Image to install (see "Images" below)
- `--productId <id>` - VPS/VDS product code (e.g. a `V`-prefixed code); list/choose in the control panel or docs
- `--region <code>` - `EU`, `US-central`, `US-east`, `US-west`, `SIN`, `JPN`, `AUS`, `IND`
- `--period <months>` - Contract/billing period: `1`, `3`, `6`, `12`
- `--displayName <name>` - Friendly name
- `--defaultUser <root|admin|administrator>` - Default login user
- `--sshKeys <secret-id>,...` - SSH public-key secret id(s) (see "Secrets")
- `--rootPassword <secret-id>` - Root password secret id
- `--userData <file>` - Cloud-init user data
- `--license <license>` - Optional add-on license

### List / Get Instances

```bash
cntb get instances
cntb get instances -o json
cntb get instance <instance-id>
cntb get instance <instance-id> -o yaml
```

## Power Management

```bash
cntb start    instance <instance-id>
cntb stop     instance <instance-id>     # power off
cntb restart  instance <instance-id>     # reboot
cntb shutdown instance <instance-id>     # graceful ACPI shutdown
```

(Confirm the exact set with `cntb --help`; `start`/`stop`/`restart` are the core actions.)

### Reinstall (wipe + redeploy OS)

```bash
cntb reinstall instance <instance-id> --imageId <image-uuid>
```

Destroys all data on the instance and reinstalls from the chosen image.

### Cancel (terminate the subscription)

```bash
cntb cancel instance <instance-id>
```

Ends the billing contract for the instance. This is the Contabo equivalent of "delete" and is effectively irreversible.

## Update

```bash
cntb update instance <instance-id> --displayName <new-name>
```

## Secrets (SSH keys & passwords)

SSH public keys and root passwords are stored as **secrets** and referenced by id at create time.

```bash
cntb create secret --type ssh      --name "my-key"  --value "ssh-ed25519 AAAA..."
cntb create secret --type password --name "root-pw" --value "<password>"
cntb get secrets
cntb delete secret <secret-id>
```

## Snapshots

```bash
cntb get snapshots <instance-id>
cntb create snapshot <instance-id> --name "<name>" --description "<text>"
cntb delete snapshot <instance-id> <snapshot-id>
```

## Images

```bash
cntb get images                       # standard + your custom images
cntb get image <image-id>
cntb create image --name <name> --url <url> --osType <type> --version <version>   # upload a custom image
```

Use the resulting image UUID as `--imageId` when creating or reinstalling.

## Access

Contabo has no built-in SSH subcommand. Read the instance's IP and connect directly:

```bash
ip=$(cntb get instance <instance-id> -o json | jq -r '.[0].ipConfig.v4.ip')
ssh root@"$ip"
```

(Field names vary by API version — inspect `cntb get instance <id> -o json` to confirm the IP path.)

## Beyond Compute

Contabo also exposes object storage (`cntb get objectStorages`), private networks (`cntb get privateNetworks`), VIPs (`cntb get vips`), and tags (`cntb get tags`). Use the same `cntb <verb> <resource>` pattern and `cntb get --help` / `cntb create --help` for the full resource list. This skill focuses on core instance compute; broader coverage can be added as additional skills.
