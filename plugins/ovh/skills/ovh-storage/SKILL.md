---
name: ovh-storage
description: "Use when the user needs to manage OVHcloud Public Cloud storage — block volumes (create, attach, detach, resize, snapshot, delete) and Swift object storage (containers and objects) via the OpenStack client."
---

# OVHcloud Public Cloud Storage (OpenStack)

OVH Public Cloud offers two storage types managed by the `openstack` client: Cinder block volumes and Swift object storage. Ensure your `OS_*` credentials/region are set (see the `ovh-setup` skill).

## Block Volumes (Cinder)

### Create and List

```bash
# Create a volume (size in GB)
openstack volume create --size 50 my-volume

# Create from a specific volume type (classic-hdd, classic-ssd, high-speed, etc.)
openstack volume create --size 100 --type classic-ssd my-volume

# List volumes and their statuses
openstack volume list

# Show details of a volume
openstack volume show my-volume
```

A volume in `available` status is not attached to any server and is still billed.

### Attach and Detach

```bash
# Attach to a running or stopped server
openstack server add volume <server-name-or-id> my-volume

# List which volumes are attached and where
openstack volume list --long

# Detach from a server
openstack server remove volume <server-name-or-id> my-volume
```

After attaching, format and mount from within the instance (e.g. `mkfs.ext4 /dev/sdb && mount /dev/sdb /mnt/data`).

### Resize

```bash
# Volumes can only be extended, not shrunk; detach first on OVH Public Cloud
openstack volume set --size 200 my-volume
```

### Delete

```bash
openstack volume delete my-volume
```

Volumes must be in `available` (detached) status before deletion.

## Volume Snapshots

```bash
# Create a snapshot (volume must be available, or use --force for attached)
openstack volume snapshot create --volume my-volume my-snapshot

# List snapshots
openstack volume snapshot list

# Show a snapshot
openstack volume snapshot show my-snapshot

# Create a new volume from a snapshot
openstack volume create --snapshot my-snapshot --size 50 restored-volume

# Delete a snapshot
openstack volume snapshot delete my-snapshot
```

Old snapshots accumulate cost. Audit them regularly with `openstack volume snapshot list`.

## Object Storage (Swift)

OVH Public Cloud Object Storage is OpenStack Swift, exposed as an S3-compatible endpoint and via the `openstack` CLI. Containers here are Swift containers (buckets), not Docker containers.

```bash
# Create a container (bucket)
openstack container create my-bucket

# List containers
openstack container list

# Show container details (object count, size)
openstack container show my-bucket

# Upload an object
openstack object create my-bucket ./local-file.txt

# Upload with a custom object name
openstack object create my-bucket ./local-file.txt --name path/to/remote-file.txt

# List objects in a container
openstack object list my-bucket

# Download an object
openstack object save my-bucket path/to/remote-file.txt

# Show object metadata
openstack object show my-bucket path/to/remote-file.txt

# Delete an object
openstack object delete my-bucket path/to/remote-file.txt

# Delete a container (must be empty first)
openstack container delete my-bucket
```

OVH also exposes Swift via an S3-compatible endpoint — use the standard `aws s3` CLI with the OVH endpoint URL if you prefer S3-style tooling.

## Beyond the basics

Run `openstack volume --help`, `openstack volume snapshot --help`, or `openstack object --help` for the full flag set. For high-performance NAS/NFS-type storage on OVH, see the NAS-HA product in the OVH control panel (not managed via the OpenStack client).
