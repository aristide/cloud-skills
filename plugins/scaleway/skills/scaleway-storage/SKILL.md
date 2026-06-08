---
name: scaleway-storage
description: "Use when the user needs to manage Scaleway storage — Block Storage volumes (create, attach, detach, resize, snapshot, delete), Instance-local volumes, and S3-compatible Object Storage buckets and objects."
---

# Scaleway Storage

Scaleway offers two main storage products: **Block Storage** (persistent network-attached volumes, `scw block`) and **Object Storage** (S3-compatible, managed via `scw object` or external S3 tools). Instance local SSD volumes are managed via `scw instance volume`. Confirm exact flags with `scw block --help` or `scw object --help`.

## Block Storage Volumes

Block volumes are **zonal** and continue billing when detached — delete them when no longer needed.

```bash
# List volumes
scw block volume list zone=fr-par-1

# Create a volume (sbs_5k or sbs_15k performance class)
scw block volume create \
  name=my-volume \
  size=20GB \
  perf-iops=5000 \
  zone=fr-par-1

# Get details
scw block volume get <volume-id> zone=fr-par-1

# Delete a volume (must be detached first)
scw block volume delete <volume-id> zone=fr-par-1
```

### Attaching and Detaching Block Volumes

Block volumes are attached/detached at the Instance level:

```bash
# Attach a Block volume to a server
scw instance server attach-volume \
  server-id=<server-id> \
  volume-id=<volume-id> \
  zone=fr-par-1

# Detach a volume from a server
scw instance server detach-volume \
  server-id=<server-id> \
  volume-id=<volume-id> \
  zone=fr-par-1
```

After attaching, format and mount the volume inside the server as usual (`mkfs`, `mount`).

## Block Storage Snapshots

Snapshots capture a point-in-time copy of a volume. They continue billing until deleted.

```bash
# Create a snapshot from a volume
scw block snapshot create \
  volume-id=<volume-id> \
  name=my-snapshot \
  zone=fr-par-1

# List snapshots
scw block snapshot list zone=fr-par-1

# Get snapshot details
scw block snapshot get <snapshot-id> zone=fr-par-1

# Create a new volume from a snapshot
scw block volume create \
  from-snapshot.snapshot-id=<snapshot-id> \
  name=restored-volume \
  zone=fr-par-1

# Delete a snapshot (irreversible)
scw block snapshot delete <snapshot-id> zone=fr-par-1
```

## Instance Volumes (local SSD)

The legacy Instance volume API manages local SSD (l_ssd) and old block (b_ssd) volumes attached at server creation time:

```bash
scw instance volume list zone=fr-par-1
scw instance volume get <volume-id> zone=fr-par-1
scw instance volume create \
  name=local-vol \
  size=20GB \
  volume-type=l_ssd \
  zone=fr-par-1
scw instance volume delete <volume-id> zone=fr-par-1
```

## Object Storage

Scaleway Object Storage is S3-compatible. The `scw object` command manages bucket-level configuration and generates credentials for third-party S3 tools.

```bash
# List buckets
scw object bucket list region=fr-par

# Create a bucket (name must be globally unique)
scw object bucket create name=my-unique-bucket region=fr-par

# Get bucket properties (ACL, versioning, tags, size)
scw object bucket get my-unique-bucket region=fr-par

# Delete a bucket (must be empty)
scw object bucket delete my-unique-bucket region=fr-par

# Generate a configuration file for an S3 tool
scw object config get type=s3cmd   region=fr-par   # outputs s3cmd config
scw object config get type=rclone  region=fr-par   # outputs rclone config
scw object config get type=mc      region=fr-par   # outputs MinIO Client config
```

For day-to-day object operations (upload, download, sync), use the generated config with an S3-compatible tool:

```bash
# AWS CLI pointed at Scaleway endpoint (nl-ams example)
aws s3 ls s3://my-unique-bucket \
  --endpoint-url https://s3.nl-ams.scw.cloud

aws s3 cp localfile.txt s3://my-unique-bucket/ \
  --endpoint-url https://s3.nl-ams.scw.cloud

# rclone (after config generated above)
rclone ls scaleway:my-unique-bucket
rclone copy ./data scaleway:my-unique-bucket/data
```

The S3 endpoint URL pattern is `https://s3.<region>.scw.cloud` (e.g. `s3.fr-par.scw.cloud`, `s3.nl-ams.scw.cloud`, `s3.pl-waw.scw.cloud`).

## Beyond the basics

Use `scw block --help` and `scw object --help` for the full argument lists, including volume resizing (`scw block volume update`) and bucket versioning/lifecycle rules. Detached Block volumes and old snapshots are common sources of idle spend — see the `scaleway-cleanup` command.
