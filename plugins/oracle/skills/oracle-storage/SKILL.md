---
name: oracle-storage
description: "Use when the user needs to manage Oracle Cloud Infrastructure (OCI) storage — block volumes (create, attach, detach, backup, delete), boot volumes, and Object Storage (buckets, objects)."
---

# Oracle Cloud Infrastructure Storage

Commands are `oci bv ...` for block/boot volumes and `oci os ...` for Object Storage. Attaching/detaching volumes uses `oci compute volume-attachment ...`. See the `oracle-setup` skill for auth and OCIDs.

## Block Volumes

### Create and List

```bash
oci bv volume create \
  --compartment-id <compartment-ocid> \
  --availability-domain <AD-name> \
  --display-name my-data-volume \
  --size-in-gbs 100 \
  --vpus-per-gb 10

oci bv volume list --compartment-id <compartment-ocid> --output table
oci bv volume get --volume-id <volume-ocid>
```

`--vpus-per-gb` controls performance: `0` = Lower Cost, `10` = Balanced, `20` = Higher Performance, `30-120` = Ultra High (VPUs bill separately).

### Attach to an Instance

```bash
oci compute volume-attachment attach \
  --instance-id <instance-ocid> \
  --type paravirtualized \
  --volume-id <volume-ocid> \
  --display-name data-vol-attach \
  --wait-for-state ATTACHED

oci compute volume-attachment list --compartment-id <compartment-ocid> \
  --instance-id <instance-ocid> --output table
```

After attaching, partition and mount inside the OS. `--type iscsi` is also supported (requires manual iSCSI connect commands on the instance).

### Detach

```bash
oci compute volume-attachment detach \
  --volume-attachment-id <attachment-ocid> \
  --wait-for-state DETACHED
```

Unmount the device inside the OS before detaching. A detached volume is still `AVAILABLE` and **keeps billing**.

### Resize

```bash
oci bv volume update \
  --volume-id <volume-ocid> \
  --size-in-gbs 200
```

You can only increase size, not decrease. Extend the filesystem inside the OS after resizing.

### Delete

```bash
oci bv volume delete --volume-id <volume-ocid>
```

The volume must be detached first. This is irreversible.

## Block Volume Backups

```bash
# Manual backup
oci bv backup create \
  --volume-id <volume-ocid> \
  --display-name my-snapshot \
  --type INCREMENTAL

oci bv backup list --compartment-id <compartment-ocid> --output table
oci bv backup get --volume-backup-id <backup-ocid>
oci bv backup delete --volume-backup-id <backup-ocid>

# Restore a volume from backup
oci bv volume create \
  --compartment-id <compartment-ocid> \
  --availability-domain <AD-name> \
  --display-name restored-volume \
  --source-volume-backup-id <backup-ocid>
```

Backup types: `INCREMENTAL` (faster, smaller) or `FULL`. Backup policies can automate this — see `oci bv volume-backup-policy`.

## Boot Volumes

Boot volumes are the OS disk of an instance. They persist after `terminate` unless `--preserve-boot-volume false`.

```bash
oci bv boot-volume list \
  --compartment-id <compartment-ocid> \
  --availability-domain <AD-name> \
  --output table

oci bv boot-volume get --boot-volume-id <ocid>

# Backup a boot volume
oci bv boot-volume-backup create \
  --boot-volume-id <ocid> \
  --display-name my-boot-backup \
  --type INCREMENTAL

oci bv boot-volume-backup list --compartment-id <compartment-ocid> --output table
oci bv boot-volume delete --boot-volume-id <ocid>
```

## Object Storage

OCI Object Storage is regional; commands use `--namespace` (your tenancy's object storage namespace — find it with `oci os ns get`).

```bash
# Get your namespace
NAMESPACE=$(oci os ns get --query 'data' --raw-output)

# Create a bucket
oci os bucket create \
  --compartment-id <compartment-ocid> \
  --name my-bucket \
  --namespace-name "$NAMESPACE" \
  --storage-tier Standard

oci os bucket list --compartment-id <compartment-ocid> --namespace-name "$NAMESPACE" --output table
oci os bucket get --name my-bucket --namespace-name "$NAMESPACE"
oci os bucket delete --name my-bucket --namespace-name "$NAMESPACE"

# Upload an object
oci os object put \
  --namespace-name "$NAMESPACE" \
  --bucket-name my-bucket \
  --file /local/path/file.tar.gz \
  --name backups/file.tar.gz

# Download an object
oci os object get \
  --namespace-name "$NAMESPACE" \
  --bucket-name my-bucket \
  --name backups/file.tar.gz \
  --file /local/path/file.tar.gz

# List objects
oci os object list \
  --namespace-name "$NAMESPACE" \
  --bucket-name my-bucket \
  --output table

# Bulk upload a directory
oci os object bulk-upload \
  --namespace-name "$NAMESPACE" \
  --bucket-name my-bucket \
  --src-dir /local/dir/

# Delete an object
oci os object delete \
  --namespace-name "$NAMESPACE" \
  --bucket-name my-bucket \
  --name backups/file.tar.gz
```

## Beyond the basics

Run `oci bv --help` and `oci os --help` for additional subcommands. Volume groups (`oci bv volume-group`) let you snapshot multiple volumes consistently. Object Storage supports pre-authenticated requests (`oci os preauth-request create`), lifecycle policies, and versioning via the Console or API. Use `--storage-tier Archive` for long-term cold storage.
