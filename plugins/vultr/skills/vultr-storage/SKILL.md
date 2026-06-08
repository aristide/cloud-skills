---
name: vultr-storage
description: "Use when the user needs to manage Vultr storage — block storage volumes (create, attach, detach, resize, delete), instance snapshots, and S3-compatible object storage."
---

# Vultr Storage

All commands use `vultr-cli <group> ...`. Confirm exact flags with `vultr-cli <group> --help`.

## Block Storage

Block storage volumes are network-attached disks you can mount to a single instance. A detached or unattached volume **still bills** until deleted.

### Create and attach

```bash
# List available regions first
vultr-cli regions list

vultr-cli block-storage create \
  --region <region-id> \
  --size   100 \
  --label  "my-data-vol" \
  --block-type high_perf     # high_perf (default) or storage_opt

vultr-cli block-storage attach <block-storage-id> --instance-id <instance-id>
```

After attaching, format and mount inside the instance (the device typically appears as `/dev/vdb`):

```bash
# On the instance
sudo mkfs.ext4 /dev/vdb
sudo mount /dev/vdb /mnt/data
```

### List, inspect, resize, and delete

```bash
vultr-cli block-storage list
vultr-cli block-storage get    <block-storage-id>
vultr-cli block-storage label  <block-storage-id> --label "new-label"
vultr-cli block-storage resize <block-storage-id> --size 200   # grow only; no shrink
vultr-cli block-storage detach <block-storage-id>
vultr-cli block-storage delete <block-storage-id>
```

Detach before resizing if the OS requires it, then reattach and resize the filesystem.

## Snapshots

Snapshots capture the full disk state of a running or stopped instance. Use them to back up before risky changes, clone instances, or create custom OS images.

```bash
vultr-cli snapshot list
vultr-cli snapshot create     --id <instance-id> --description "pre-upgrade backup"
vultr-cli snapshot create-url --url <image-url>  --description "imported image"
vultr-cli snapshot get    <snapshot-id>
vultr-cli snapshot delete <snapshot-id>
```

Restore by creating a new instance from a snapshot:

```bash
vultr-cli instance create \
  --region   <region-id> \
  --plan     <plan-id> \
  --snapshot <snapshot-id>
```

Old snapshots accumulate cost — review with `vultr-cli snapshot list` and delete unused ones.

## Object Storage (S3-compatible)

Vultr Object Storage is an S3-compatible service. You manage buckets and objects with any S3-compatible tool (AWS CLI, `s3cmd`, `rclone`) using the endpoint and keys from the CLI.

### Manage object storage instances

```bash
# Find available clusters and tiers first
vultr-cli object-storage cluster list
vultr-cli object-storage tier list

vultr-cli object-storage create \
  --cluster-id <cluster-id> \
  --tier-id    <tier-id> \
  --label      "my-objects"

vultr-cli object-storage list
vultr-cli object-storage get   <object-storage-id>
vultr-cli object-storage label <object-storage-id> --label "new-label"

# Rotate S3 credentials
vultr-cli object-storage regenerate-keys <object-storage-id>

vultr-cli object-storage delete <object-storage-id>
```

### Use with the AWS CLI (S3-compatible)

```bash
# Get the S3 endpoint and keys from the get output
vultr-cli object-storage get <object-storage-id>

# Configure the AWS CLI to point at Vultr's endpoint
aws configure --profile vultr
# AWS Access Key ID:     <s3_access_key>
# AWS Secret Access Key: <s3_secret_key>
# Default region:        us-east-1  (any value; Vultr ignores it)
# Default output:        json

# Create a bucket and upload
aws s3 mb s3://my-bucket --endpoint-url https://<vultr-s3-endpoint> --profile vultr
aws s3 cp ./file.tar.gz s3://my-bucket/ --endpoint-url https://<vultr-s3-endpoint> --profile vultr
aws s3 ls s3://my-bucket --endpoint-url https://<vultr-s3-endpoint> --profile vultr
```

## Beyond the basics

Run `vultr-cli block-storage --help`, `vultr-cli snapshot --help`, or `vultr-cli object-storage --help` for the full flag reference. For backup automation consider using snapshots on a schedule via the Vultr API or a cron job calling `vultr-cli snapshot create`.
