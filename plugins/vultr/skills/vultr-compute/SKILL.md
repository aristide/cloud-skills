---
name: vultr-compute
description: "Use when the user needs to create, list, inspect, start, stop, restart, reinstall, or delete Vultr cloud instances, manage SSH keys, or look up plans, regions, and OS images."
---

# Vultr Instances (Compute)

All commands are `vultr-cli instance ...`. Look up region/plan/OS ids with the `vultr-setup` skill. Confirm exact flags with `vultr-cli instance create --help`.

## Instance Lifecycle

### Create an Instance

```bash
vultr-cli instance create \
  --region <region-id> \
  --plan <plan-id> \
  --os <os-id> \
  --host <hostname> \
  --label <label>
```

Common flags:
- `--region <id>` - Region, e.g. `ewr`, `fra`, `nrt` (required; `vultr-cli regions list`)
- `--plan <id>` - Plan, e.g. `vc2-1c-1gb` (required; `vultr-cli plans list`)
- `--os <id>` - OS image id (required unless using `--app`/`--image`/`--snapshot`)
- `--app <id>` - Deploy a one-click app instead of a bare OS
- `--label <name>` / `--host <hostname>` - Friendly label / hostname
- `--ssh-keys <id>,...` - SSH key ids to inject (`vultr-cli ssh-key list`)
- `--userdata <file-or-string>` - Cloud-init user data
- `--ipv6` - Enable IPv6
- `--tags <tag>,...` - Tags

### List / Get Instances

```bash
vultr-cli instance list
vultr-cli instance get <instance-id>
```

### Delete (destroy)

```bash
vultr-cli instance delete <instance-id>
```

Irreversible. Destroys the instance and its storage — the only way to stop billing.

## Power Management

```bash
vultr-cli instance start   <instance-id>
vultr-cli instance stop    <instance-id>     # powers off; STILL BILLS
vultr-cli instance restart <instance-id>
```

A stopped instance keeps billing — use `delete` to stop charges.

### Reinstall (wipe + reinstall OS)

```bash
vultr-cli instance reinstall <instance-id>
```

Destroys data on the instance and reinstalls.

## Access

### Get the public IP

```bash
vultr-cli instance get <instance-id>      # shows main IP, or:
vultr-cli instance get <instance-id> -o json | jq -r '.instance.main_ip'
```

Then connect directly:

```bash
ssh root@<main-ip>
```

## SSH Keys

```bash
vultr-cli ssh-key list
vultr-cli ssh-key create --name "my-key" --key "$(cat ~/.ssh/id_ed25519.pub)"
vultr-cli ssh-key delete <key-id>
```

## Plans, Regions, OS

```bash
vultr-cli plans list
vultr-cli regions list
vultr-cli os list
```

## Beyond Compute

Vultr also exposes block storage (`vultr-cli block-storage`), reserved IPs (`vultr-cli reserved-ip`), load balancers (`vultr-cli load-balancer`), Kubernetes (`vultr-cli kubernetes`), DNS (`vultr-cli dns`), and snapshots (`vultr-cli snapshot`). Use the same `vultr-cli <group> ...` pattern and `vultr-cli <group> --help`. This skill focuses on core instance compute; broader coverage can be added as additional skills.
