---
name: digitalocean-storage
description: "Use when the user needs to manage DigitalOcean storage — block volumes (create, attach, detach, snapshot, delete) or Spaces object storage."
---

# DigitalOcean Storage

Block storage commands live under `doctl compute volume` and `doctl compute volume-action`. Spaces object storage is S3-compatible and is managed with S3-compatible tools, not `doctl`. See the `digitalocean-setup` skill for auth/region selection.

## Block Volumes

### Create and list

```bash
doctl compute volume create my-volume \
  --region nyc3 \
  --size 50GiB \
  --desc "data volume for app-01"

doctl compute volume list
doctl compute volume list --format ID,Name,Size,Region,DropletIDs --no-header
doctl compute volume get <volume-id>
```

`--size` takes values like `50GiB`, `100GiB`. Volumes are region-specific and must be in the same region as the Droplet you attach them to.

### Attach and detach

```bash
# Attach (Droplet must be in the same region)
doctl compute volume-action attach <volume-id> <droplet-id>

# Detach
doctl compute volume-action detach <volume-id> <droplet-id>
```

After attaching, the volume appears as a block device (e.g. `/dev/sda`) on the Droplet and must be formatted and mounted the first time.

### Resize

```bash
# Volume must be detached or the filesystem resized afterwards on the Droplet
doctl compute volume-action resize <volume-id> --size 100 --region nyc3
```

Size can only grow, never shrink.

### Delete

```bash
doctl compute volume delete <volume-id>
doctl compute volume delete <volume-id> --force    # skip confirmation
```

A detached, unattached volume **still bills at the full hourly rate**. Delete volumes you no longer need.

## Volume Snapshots

Snapshots capture the volume at a point in time and are billed per GB-month.

```bash
# Create a snapshot of a volume
doctl compute volume snapshot <volume-id> --snapshot-name my-vol-snap-$(date +%Y%m%d)

# List volume snapshots
doctl compute snapshot list --resource-type volume

# Create a new volume from a snapshot
doctl compute volume create restored-volume \
  --region nyc3 \
  --size 50GiB \
  --snapshot-id <snapshot-id>

# Delete a snapshot
doctl compute snapshot delete <snapshot-id>
```

## Spaces Object Storage

Spaces is DigitalOcean's S3-compatible object storage. `doctl spaces` exists but is limited to managing Spaces **access keys** (`doctl spaces keys`). Bucket creation, listing, deletion, and object transfers are not supported by doctl — use the AWS CLI pointed at the Spaces endpoint, or `s3cmd`.

### Using the AWS CLI

```bash
# Configure a profile for Spaces (use Spaces access key + secret from the control panel)
aws configure --profile do-spaces

# List buckets (endpoint is <region>.digitaloceanspaces.com)
aws s3 ls --endpoint-url https://nyc3.digitaloceanspaces.com --profile do-spaces

# Create a bucket
aws s3api create-bucket --bucket my-bucket \
  --endpoint-url https://nyc3.digitaloceanspaces.com \
  --profile do-spaces

# Upload / sync
aws s3 cp ./local-dir s3://my-bucket/ \
  --endpoint-url https://nyc3.digitaloceanspaces.com \
  --profile do-spaces --recursive

# Delete a bucket (must be empty)
aws s3 rb s3://my-bucket \
  --endpoint-url https://nyc3.digitaloceanspaces.com \
  --profile do-spaces
```

Generate Spaces access keys in the DigitalOcean control panel under **API → Spaces access keys**. The endpoint format is `https://<region>.digitaloceanspaces.com`.

## Beyond the basics

Run `doctl compute volume --help` and `doctl compute volume-action --help` for the full flag surface, including volume tags and waiting for action completion with `--wait`. For advanced Spaces use (ACLs, CDN, lifecycle policies) consult the Spaces documentation or the `s3cmd` man page.
