---
name: linode-storage
description: "Use when the user needs to manage Linode storage — Block Storage volumes (create, attach, detach, resize, delete) and Object Storage (buckets, access keys, S3-compatible access)."
---

# Linode Storage

All commands are `linode-cli <group> ...`. See the `linode-setup` skill for auth and region selection.

## Block Storage Volumes

Block Storage volumes are network-attached SSD disks that can be mounted on a Linode. They persist independently of the Linode's lifecycle.

```bash
# List all volumes on the account
linode-cli volumes list
linode-cli volumes list --text --format "id,label,size,status,linode_id,region" --no-headers

# Create a volume (minimum 10 GB, billed hourly immediately)
linode-cli volumes create \
  --label my-volume \
  --size 50 \
  --region us-east

# Create and attach to a Linode in one step
linode-cli volumes create \
  --label my-volume \
  --size 50 \
  --linode_id <linode-id>

# View a specific volume
linode-cli volumes view <volume-id>

# Attach an existing volume to a Linode (both must be in the same region)
linode-cli volumes attach <volume-id> --linode_id <linode-id>

# Detach a volume (safely unmount inside the OS first)
linode-cli volumes detach <volume-id>

# Resize a volume (online resize supported; only grows, not shrinks)
linode-cli volumes resize <volume-id> --size 100

# Delete a volume (must be detached; this is irreversible)
linode-cli volumes delete <volume-id>
```

Note: a detached volume **still bills** until it is deleted. Run `linode-cli volumes list` to find unattached volumes (empty `linode_id`).

### Mount a volume (inside the Linode)

After attaching, format and mount the device (typically `/dev/disk/by-id/scsi-0Linode_Volume_<label>`):

```bash
# First attach only — find the device path shown in the API response
linode-cli volumes view <volume-id>    # see "filesystem_path"

# On the Linode itself:
mkfs.ext4 /dev/disk/by-id/scsi-0Linode_Volume_<label>
mkdir -p /mnt/data
mount /dev/disk/by-id/scsi-0Linode_Volume_<label> /mnt/data
# Add to /etc/fstab for persistence
```

## Object Storage

Linode Object Storage is S3-compatible. Access is via access keys (not the main linode-cli auth token) and any S3-compatible client.

### Access Keys

```bash
# List object storage access keys
linode-cli object-storage keys-list

# Create an access key (optionally scope it to specific buckets)
linode-cli object-storage keys-create \
  --label my-s3-key

# Create a key scoped to specific buckets
linode-cli object-storage keys-create \
  --label scoped-key \
  --bucket_access '[{"region":"us-east","bucket_name":"my-bucket","permissions":"read_write"}]'

# Delete an access key
linode-cli object-storage keys-delete <key-id>
```

### Buckets

```bash
# List all buckets
linode-cli object-storage buckets-list

# Create a bucket (use --region; --cluster is deprecated. Region IDs e.g. us-east, eu-central)
linode-cli object-storage buckets-create \
  --region us-east \
  --label my-bucket

# View bucket details (subcommand name varies by CLI version — confirm with:
#   linode-cli object-storage --help
# The obj plugin equivalent is always available:
linode-cli obj ls                          # lists all buckets with region info

# List objects in a bucket (obj plugin — well-documented)
linode-cli obj ls <bucket-label>
# API-derived equivalent (confirm availability with linode-cli object-storage --help):
# linode-cli object-storage object-list <region-id> <bucket-label>

# Delete a bucket (must be empty first)
linode-cli object-storage buckets-delete <region-id> <bucket-label>

# List available Object Storage clusters (endpoints)
linode-cli object-storage clusters-list
```

### S3-compatible access

Use any S3 client with the cluster endpoint. For example, with the AWS CLI:

```bash
aws s3 ls s3://my-bucket \
  --endpoint-url https://us-east-1.linodeobjects.com \
  --profile linode   # configure with the object storage access key + secret
```

Or with `s3cmd`:

```bash
s3cmd --access_key=<key> --secret_key=<secret> \
  --host=us-east-1.linodeobjects.com \
  --host-bucket="%(bucket)s.us-east-1.linodeobjects.com" \
  ls s3://my-bucket
```

## Beyond the basics

Run `linode-cli volumes --help` or `linode-cli object-storage --help` for the full flag reference. For attaching volumes to LKE clusters, see the `linode-kubernetes` skill. For backups of Linode instances (managed snapshot service), enable backups at instance creation time (`--backups_enabled true`) or via `linode-cli linodes backups-enable <id>`.
