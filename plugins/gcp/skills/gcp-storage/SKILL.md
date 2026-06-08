---
name: gcp-storage
description: "Use when the user needs to manage Google Cloud storage — persistent disks (create, attach, detach, resize, delete), disk snapshots, and Cloud Storage buckets (create, upload, download, list, delete)."
---

# Google Cloud Storage

GCP offers two main storage surfaces: **Persistent Disks** (block storage attached to Compute Engine instances) and **Cloud Storage** (object storage, equivalent to S3). Enable the APIs: `gcloud services enable compute.googleapis.com storage.googleapis.com`.

## Persistent Disks

Disks are zonal. An unattached disk **still bills** at the disk's rate.

### Create and list

```bash
gcloud compute disks create my-disk \
  --zone us-central1-a \
  --size 100GB \
  --type pd-ssd

# Types: pd-standard (HDD), pd-balanced, pd-ssd (SSD), pd-extreme
gcloud compute disks list --format='table(name,zone.basename(),sizeGb,type.basename(),status,users.basename())'
gcloud compute disks describe my-disk --zone us-central1-a
```

### Attach and detach

```bash
# Attach (instance must be running or stopped)
gcloud compute instances attach-disk my-instance \
  --disk my-disk \
  --zone us-central1-a

# Detach
gcloud compute instances detach-disk my-instance \
  --disk my-disk \
  --zone us-central1-a
```

After attaching, format and mount the disk inside the instance:

```bash
# Inside the instance (via gcloud compute ssh):
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p /mnt/data && sudo mount -o discard,defaults /dev/sdb /mnt/data
```

### Resize

Disks can be grown but **not shrunk**. No downtime required.

```bash
gcloud compute disks resize my-disk --zone us-central1-a --size 200GB
# Then resize the filesystem inside the instance (e.g. sudo resize2fs /dev/sdb)
```

### Delete

```bash
gcloud compute disks delete my-disk --zone us-central1-a
```

## Snapshots

Snapshots are global resources and are incremental after the first.

```bash
# Create a snapshot from a disk
gcloud compute disks snapshot my-disk \
  --zone us-central1-a \
  --snapshot-names my-disk-snap-$(date +%Y%m%d)

# List snapshots
gcloud compute snapshots list --format='table(name,diskSizeGb,creationTimestamp,status)'

# Describe a snapshot
gcloud compute snapshots describe my-disk-snap-20250607

# Create a new disk from a snapshot
gcloud compute disks create my-disk-restored \
  --source-snapshot my-disk-snap-20250607 \
  --zone us-central1-a

# Delete a snapshot
gcloud compute snapshots delete my-disk-snap-20250607
```

## Cloud Storage Buckets

Cloud Storage is object storage billed by data volume and operations. The `gcloud storage` command (GA since 2022) replaces the older `gsutil`.

### Buckets

```bash
# Create a bucket (bucket names are globally unique)
gcloud storage buckets create gs://my-unique-bucket \
  --location us-central1 \
  --uniform-bucket-level-access

gcloud storage buckets list
gcloud storage buckets describe gs://my-unique-bucket
gcloud storage buckets delete gs://my-unique-bucket
```

### Objects (upload / download / list / delete)

```bash
# Upload a file
gcloud storage cp ./local-file.txt gs://my-unique-bucket/

# Upload a directory recursively
gcloud storage cp -r ./my-dir gs://my-unique-bucket/my-dir/

# List objects
gcloud storage ls gs://my-unique-bucket/
gcloud storage ls -l gs://my-unique-bucket/          # with sizes and timestamps

# Download
gcloud storage cp gs://my-unique-bucket/file.txt ./

# Delete an object
gcloud storage rm gs://my-unique-bucket/file.txt

# Delete all objects in a prefix
gcloud storage rm -r gs://my-unique-bucket/my-dir/
```

### Signed URLs (temporary public access)

```bash
gcloud storage sign-url gs://my-unique-bucket/file.txt \
  --duration=1h \
  --private-key-file=key.json \
  --service-account=sa@project.iam.gserviceaccount.com
```

## Beyond the basics

Run `gcloud compute disks --help`, `gcloud compute snapshots --help`, or `gcloud storage --help` for the full flag set. Regional persistent disks (`--replica-zones`), multi-region buckets, lifecycle rules (`gcloud storage buckets update --lifecycle-file`), and object versioning are available for production workloads.
