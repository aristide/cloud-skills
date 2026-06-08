---
name: gcp-compute
description: "Use when the user needs to create, list, inspect, start, stop, reset, resize, or delete Google Compute Engine instances, SSH into them, look up machine types or images, or manage instance tags/metadata."
---

# Google Compute Engine Instances

All commands are `gcloud compute instances ...`. Operations are zonal — pass `--zone` (or set a default zone — see the `gcp-setup` skill).

## Instance Lifecycle

### Create an Instance

```bash
gcloud compute instances create <name> \
  --zone <zone> \
  --machine-type <type> \
  --image-family <family> \
  --image-project <project>
```

Common flags:
- `--machine-type <type>` - e.g. `e2-micro`, `n2-standard-2` (default `e2-medium`)
- `--image-family <family>` + `--image-project <project>` - e.g. `--image-family debian-12 --image-project debian-cloud`
- `--image <name>` - A specific image instead of a family
- `--boot-disk-size <size>` - e.g. `20GB`
- `--boot-disk-type <type>` - `pd-standard`, `pd-balanced`, `pd-ssd`
- `--network <net>` / `--subnet <subnet>` - Placement
- `--tags <tag>,...` - Network tags (used by firewall rules)
- `--metadata key=value` / `--metadata-from-file startup-script=<file>` - Metadata & startup script
- `--service-account <email>` / `--scopes <scopes>` - Identity
- `--preemptible` or `--provisioning-model=SPOT` - Cheaper, interruptible
- `--no-address` - Create without an external IP

### List / Describe Instances

```bash
gcloud compute instances list
gcloud compute instances list --filter='status=RUNNING'
gcloud compute instances describe <name> --zone <zone>
```

Concise table:

```bash
gcloud compute instances list \
  --format='table(name,zone.basename(),machineType.basename(),status,EXTERNAL_IP:label=EXTERNAL_IP)'
```

## Power Management

```bash
gcloud compute instances start <name> --zone <zone>
gcloud compute instances stop  <name> --zone <zone>     # graceful; stops compute billing, disk still bills
gcloud compute instances reset <name> --zone <zone>     # hard reset (like a reboot button)
```

Suspend/resume (preserves RAM to disk):

```bash
gcloud compute instances suspend <name> --zone <zone>
gcloud compute instances resume  <name> --zone <zone>
```

### Delete (destroy)

```bash
gcloud compute instances delete <name> --zone <zone>
```

Irreversible. By default also deletes the boot disk (keep it with `--keep-disks=boot`). Protect critical instances:

```bash
gcloud compute instances update <name> --zone <zone> --deletion-protection
```

## Resize (change machine type)

Instance must be stopped first:

```bash
gcloud compute instances stop <name> --zone <zone>
gcloud compute instances set-machine-type <name> --zone <zone> --machine-type n2-standard-4
gcloud compute instances start <name> --zone <zone>
```

## Access

### SSH (gcloud manages keys automatically)

```bash
gcloud compute ssh <name> --zone <zone>
gcloud compute ssh <name> --zone <zone> --command 'uname -a'
gcloud compute ssh <name> --zone <zone> --tunnel-through-iap   # no external IP needed
```

### Get the external IP

```bash
gcloud compute instances describe <name> --zone <zone> \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

### SCP

```bash
gcloud compute scp <local> <name>:<remote> --zone <zone>
```

### Serial console output (boot troubleshooting)

```bash
gcloud compute instances get-serial-port-output <name> --zone <zone>
```

## Images and Machine Types

```bash
gcloud compute images list                       # public images
gcloud compute images list --filter='family~debian'
gcloud compute machine-types list --zones <zone> --format='table(name,guestCpus,memoryMb)'
```

## Tags and Metadata

```bash
gcloud compute instances add-tags <name> --zone <zone> --tags http-server
gcloud compute instances remove-tags <name> --zone <zone> --tags http-server
gcloud compute instances add-metadata <name> --zone <zone> --metadata env=prod
```

## Firewall (network tags)

```bash
gcloud compute firewall-rules create allow-http --allow tcp:80 --target-tags http-server
```

## Beyond Compute

For networking (`gcloud compute networks`), disks (`gcloud compute disks`), GKE (`gcloud container`), storage (`gsutil` / `gcloud storage`), and IAM (`gcloud iam` / `gcloud projects add-iam-policy-binding`), use the same `gcloud <group> <command>` pattern; run `gcloud <group> --help`. This skill focuses on core Compute Engine; broader coverage can be added as additional skills.
