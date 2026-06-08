---
name: linode-compute
description: "Use when the user needs to create, list, inspect, boot, shut down, reboot, resize, rebuild, or delete Linode instances, SSH into them, manage SSH keys, or look up Linode types, images, and regions."
---

# Linode Instances (Compute)

All commands are `linode-cli linodes ...`. Defaults for `--region`, `--type`, and `--image` can be set via `linode-cli configure` (see the `linode-setup` skill), then omitted.

## Instance Lifecycle

### Create a Linode

```bash
linode-cli linodes create \
  --label <label> \
  --type <type> \
  --region <region> \
  --image <image> \
  --root_pass '<root-password>' \
  --authorized_keys "$(cat ~/.ssh/id_ed25519.pub)"
```

Common flags:
- `--label <name>` - Instance label (must be unique on the account)
- `--type <type>` - Plan, e.g. `g6-nanode-1`, `g6-standard-2` (`linode-cli linodes types`)
- `--region <region>` - e.g. `us-east`, `eu-central`, `ap-south` (`linode-cli regions list`)
- `--image <image>` - e.g. `linode/ubuntu22.04`, `linode/debian12` (`linode-cli images list`)
- `--root_pass '<pw>'` - Required when an image is provided
- `--authorized_keys "<pubkey>"` - Inject an SSH key (repeatable)
- `--backups_enabled true` - Enable backups
- `--private_ip true` - Add a private IP
- `--tags <tag>` - Tag (repeatable)
- `--metadata.user_data <base64>` - Cloud-init user data (base64-encoded)
- `--stackscript_id <id>` - Deploy from a StackScript

### List / View Linodes

```bash
linode-cli linodes list
linode-cli linodes list --text --format "id,label,status,ipv4,region,type" --no-headers
linode-cli linodes view <linode-id>
```

### Update

```bash
linode-cli linodes update <linode-id> --label <new-label>
```

### Delete (destroy)

```bash
linode-cli linodes delete <linode-id>
```

Irreversible. Destroys the Linode and its disks.

## Power Management

```bash
linode-cli linodes boot     <linode-id>
linode-cli linodes shutdown <linode-id>
linode-cli linodes reboot   <linode-id>
```

Note: a powered-off (shut down) Linode **still bills** — only deleting it stops charges.

## Resize and Rebuild

```bash
# Resize to another plan (instance reboots; disks may auto-resize):
linode-cli linodes resize <linode-id> --type g6-standard-2 --allow_auto_disk_resize true

# Rebuild = wipe and reinstall from an image (all data lost):
linode-cli linodes rebuild <linode-id> --image linode/ubuntu22.04 --root_pass '<pw>'

# Boot into rescue mode:
linode-cli linodes rescue <linode-id>
```

## Access

### SSH (built-in plugin)

```bash
linode-cli ssh root@<label>
```

### Get IP addresses

```bash
linode-cli linodes view <linode-id> --text --format "ipv4" --no-headers
linode-cli linodes ips-list <linode-id>
```

Then connect directly:

```bash
ssh root@<ipv4>
```

## SSH Keys (account profile)

```bash
linode-cli sshkeys list
linode-cli sshkeys create --label "my-key" --ssh_key "$(cat ~/.ssh/id_ed25519.pub)"
linode-cli sshkeys delete <key-id>
```

## Types, Images, Regions

```bash
linode-cli linodes types --text --format "id,label,vcpus,memory,disk,price.monthly"
linode-cli images list
linode-cli regions list
```

## Beyond Compute

Linode exposes much more via the same `linode-cli <group> ...` pattern: volumes (`linode-cli volumes`), NodeBalancers (`linode-cli nodebalancers`), object storage (`linode-cli object-storage`), Kubernetes (`linode-cli lke`), domains (`linode-cli domains`), and firewalls (`linode-cli firewalls`). Run `linode-cli <group> --help`. This skill focuses on core Linode compute; broader coverage can be added as additional skills.
