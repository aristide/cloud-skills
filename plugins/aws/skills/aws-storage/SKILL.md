---
name: aws-storage
description: "Use when the user needs to manage AWS storage — EBS block volumes (create, attach, detach, resize, snapshot, delete) and S3 object storage (buckets and objects)."
---

# AWS Storage

Block storage uses `aws ec2 ...`; object storage uses `aws s3 ...` and `aws s3api ...`. Add `--region`/`--profile` as needed. See the `aws-setup` skill for auth.

## EBS Block Volumes

A detached (available) EBS volume **still bills** by the GB provisioned.

### Create and attach

```bash
# Create a volume in the same AZ as the target instance
aws ec2 create-volume \
  --size 20 \
  --volume-type gp3 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=data-vol}]'

# Attach to a running or stopped instance
aws ec2 attach-volume \
  --volume-id <vol-id> \
  --instance-id <instance-id> \
  --device /dev/sdf
```

After attaching, the volume appears as a block device (e.g. `/dev/nvme1n1` on Nitro instances). Format and mount it inside the OS.

### List and inspect

```bash
aws ec2 describe-volumes \
  --query 'Volumes[].{id:VolumeId,size:Size,type:VolumeType,state:State,az:AvailabilityZone,attached:Attachments[0].InstanceId}' \
  --output table

# Just unattached volumes (idle spend risk)
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[].{id:VolumeId,size:Size,az:AvailabilityZone}' \
  --output table
```

### Detach

```bash
# Unmount inside the OS first, then detach
aws ec2 detach-volume --volume-id <vol-id>
```

### Resize (modify)

EBS supports online resizing for gp2/gp3/io1/io2. After the API call completes, extend the filesystem inside the OS.

```bash
aws ec2 modify-volume --volume-id <vol-id> --size 40
# Check progress
aws ec2 describe-volumes-modifications --volume-ids <vol-id> \
  --query 'VolumesModifications[].{state:ModificationState,progress:Progress}' --output table
```

### Delete

```bash
# Volume must be in 'available' state (detached)
aws ec2 delete-volume --volume-id <vol-id>
```

## Snapshots

Snapshots are incremental and stored in S3 (you pay per GB stored). Older snapshots that share no changed blocks with newer ones can still be expensive; audit regularly.

```bash
# Create a snapshot
aws ec2 create-snapshot \
  --volume-id <vol-id> \
  --description "pre-upgrade backup" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=my-snapshot}]'

# List your snapshots
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[].{id:SnapshotId,vol:VolumeId,size:VolumeSize,date:StartTime,desc:Description}' \
  --output table

# Restore: create a new volume from a snapshot
aws ec2 create-volume \
  --snapshot-id <snap-id> \
  --availability-zone us-east-1a

# Delete a snapshot
aws ec2 delete-snapshot --snapshot-id <snap-id>
```

## S3 Object Storage

### Buckets

```bash
# Create a bucket (bucket names are globally unique)
aws s3 mb s3://my-bucket-name --region us-east-1

# List buckets
aws s3 ls

# Remove an empty bucket
aws s3 rb s3://my-bucket-name

# Remove a bucket and ALL its objects (irreversible)
aws s3 rb s3://my-bucket-name --force
```

### Objects

```bash
# Upload a file
aws s3 cp ./file.txt s3://my-bucket-name/path/file.txt

# Upload a directory recursively
aws s3 cp ./dist/ s3://my-bucket-name/dist/ --recursive

# List objects
aws s3 ls s3://my-bucket-name --recursive --human-readable

# Download
aws s3 cp s3://my-bucket-name/path/file.txt ./file.txt

# Sync a local dir to S3 (uploads new/changed, optionally deletes removed)
aws s3 sync ./dist/ s3://my-bucket-name/dist/ --delete

# Delete an object
aws s3 rm s3://my-bucket-name/path/file.txt

# Delete all objects under a prefix
aws s3 rm s3://my-bucket-name/path/ --recursive
```

### Bucket configuration (via s3api)

```bash
# Block all public access (recommended default)
aws s3api put-public-access-block \
  --bucket my-bucket-name \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket-name \
  --versioning-configuration Status=Enabled

# Set a lifecycle policy (e.g. expire objects after 90 days)
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket-name \
  --lifecycle-configuration file://lifecycle.json
```

## Beyond the basics

Use `aws ec2 help` for EBS operations and `aws s3 help` / `aws s3api help` for object storage. Related: `aws-compute` for attaching volumes to instances, `aws-security` for bucket policies and encryption settings.
