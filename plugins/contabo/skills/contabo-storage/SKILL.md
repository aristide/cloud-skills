---
name: contabo-storage
description: "Use when the user needs to manage Contabo object storage — create, list, update, or cancel object storage buckets, and understand S3-compatible access credentials."
---

# Contabo Storage

All commands are `cntb <verb> objectStorage[s] ...`. Confirm exact flags with `cntb create objectStorage --help` — product/region identifiers can change.

> **Scope note:** Contabo's primary CLI-managed storage product is **Object Storage** (S3-compatible). There is no separate managed block-volume product exposed through `cntb` — additional disk space for instances (add-on storage) is provisioned at instance create time or via the Contabo Customer Control Panel, not through a standalone volume CLI. Instance snapshots are covered in the `contabo-compute` skill.

> **Billing:** Object storage is subscription-based, just like instances. Use `cntb cancel objectStorage` to end the contract; a plain "delete" may not stop billing. Verify cancellation semantics with `cntb cancel --help`.

## Object Storage

Contabo Object Storage is an S3-compatible endpoint. Each bucket is a separate subscription with a defined storage size and region.

### List

```bash
cntb get objectStorages
cntb get objectStorages -o json
```

### Get details

```bash
cntb get objectStorage <objectStorage-id>
```

The output includes the S3 endpoint URL, region, and your access credentials (access key / secret key) needed for S3-compatible clients.

### Create

```bash
cntb create objectStorage \
  --region <region> \
  --totalPurchasedSpaceInTB <size>
```

Common flags (verify with `cntb create objectStorage --help`):
- `--region <region>` - Region code (e.g. `EU`, `US-central`, `SIN`)
- `--totalPurchasedSpaceInTB <n>` - Storage size in terabytes (e.g. `1`, `2`, `5`)

This opens a billing contract. Note the returned `s3Url`, `accessKey`, and `secretKey` — store them securely (see `contabo-security` for secret management).

### Update

```bash
cntb update objectStorage <objectStorage-id> \
  --totalPurchasedSpaceInTB <new-size>
```

Use to resize (upgrade) storage capacity.

### Cancel (terminate the subscription)

```bash
cntb cancel objectStorage <objectStorage-id>
```

Ends the billing contract. All stored data will be lost — confirm before running.

## Using S3-compatible access

Once you have the endpoint URL and credentials from `cntb get objectStorage <id> -o json`, interact with the bucket using any S3-compatible client:

```bash
# Using the AWS CLI with a custom endpoint
aws s3 ls s3://<bucket-name>/ \
  --endpoint-url <s3Url> \
  --no-sign-request     # omit this line; instead configure credentials below

# Configure credentials for the AWS CLI
aws configure set aws_access_key_id <accessKey>
aws configure set aws_secret_access_key <secretKey>

# Then use normally
aws s3 cp myfile.txt s3://<bucket-name>/ --endpoint-url <s3Url>
```

Other S3-compatible tools (rclone, s3cmd, MinIO client `mc`) work the same way — point them at the Contabo S3 endpoint URL and supply the access/secret key pair.

## Beyond the basics

```bash
cntb get objectStorages --help
cntb create objectStorage --help
cntb update objectStorage --help
```

For instance snapshots, see the `contabo-compute` skill. For storing object storage credentials as named secrets, see `contabo-security`.
