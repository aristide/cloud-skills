---
name: digitalocean-compute
description: "Use when the user needs to create, list, inspect, power on/off, reboot, resize, or delete DigitalOcean Droplets, SSH into them, manage SSH keys, or look up sizes, images, and regions."
---

# DigitalOcean Droplets (Compute)

Droplet commands are `doctl compute droplet ...`; power/resize actions go through `doctl compute droplet-action ...`. Add `--context`/`--region` as needed (see the `digitalocean-setup` skill).

## Droplet Lifecycle

### Create a Droplet

```bash
doctl compute droplet create <name> \
  --size <size-slug> \
  --image <image-slug> \
  --region <region-slug> \
  --ssh-keys <id-or-fingerprint>
```

Common flags:
- `--size <slug>` - e.g. `s-1vcpu-1gb`, `s-2vcpu-4gb` (required; `doctl compute size list`)
- `--image <slug-or-id>` - e.g. `ubuntu-22-04-x64`, `debian-12-x64` (required)
- `--region <slug>` - e.g. `nyc3`, `fra1`, `ams3` (required)
- `--ssh-keys <id/fingerprint>,...` - Keys to inject (without these, DO emails a root password)
- `--user-data <string>` / `--user-data-file <path>` - Cloud-init
- `--vpc-uuid <uuid>` - Place in a specific VPC
- `--enable-backups` / `--enable-monitoring` / `--enable-ipv6`
- `--tag-names <tag>,...` - Tags
- `--wait` - Block until the Droplet is active

### List / Get Droplets

```bash
doctl compute droplet list
doctl compute droplet list --format ID,Name,PublicIPv4,Region,Status,Memory --no-header
doctl compute droplet get <id>
```

Filter by tag:

```bash
doctl compute droplet list --tag-name web
```

### Delete (destroy)

```bash
doctl compute droplet delete <id-or-name>
doctl compute droplet delete <id> --force      # skip the confirmation prompt
doctl compute droplet delete --tag-name web     # delete all Droplets with a tag
```

Irreversible. Destroys the Droplet and its local disk.

## Power Management (droplet-action)

```bash
doctl compute droplet-action power-on    <id>
doctl compute droplet-action power-off   <id>     # hard off
doctl compute droplet-action shutdown    <id>     # graceful ACPI
doctl compute droplet-action reboot      <id>
doctl compute droplet-action power-cycle <id>     # hard off+on
```

### Resize

```bash
doctl compute droplet-action power-off <id> --wait
doctl compute droplet-action resize <id> --size s-2vcpu-4gb --resize-disk --wait
doctl compute droplet-action power-on <id> --wait
```

`--resize-disk` permanently grows the disk and prevents downsizing later; omit it to resize CPU/RAM only.

## Access

### SSH (doctl manages the connection)

```bash
doctl compute ssh <droplet-name-or-id>
doctl compute ssh <droplet-name> --ssh-command "uname -a"
```

### Get the public IP

```bash
doctl compute droplet get <id> --format PublicIPv4 --no-header
```

## SSH Keys

```bash
doctl compute ssh-key list
doctl compute ssh-key create <name> --public-key "$(cat ~/.ssh/id_ed25519.pub)"
doctl compute ssh-key import <name> --public-key-file ~/.ssh/id_ed25519.pub
doctl compute ssh-key delete <id>
```

## Sizes, Images, Regions

```bash
doctl compute size list
doctl compute image list-distribution --public      # OS images
doctl compute image list --public                    # all public images (apps + distros)
doctl compute region list
```

## Beyond Compute

DigitalOcean exposes much more through the same `doctl <group> ...` pattern: block storage (`doctl compute volume`), reserved IPs (`doctl compute reserved-ip`), load balancers (`doctl compute load-balancer`), managed databases (`doctl databases`), Kubernetes (`doctl kubernetes`), and Spaces. Run `doctl <group> --help`. This skill focuses on core Droplet compute; broader coverage can be added as additional skills.
