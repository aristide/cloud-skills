---
name: azure-storage
description: "Use when the user needs to manage Azure storage — managed disks (create, attach, detach, resize, delete), snapshots, and Azure Blob Storage (storage accounts, containers, and blobs)."
---

# Azure Storage

Azure offers two main storage surfaces: **managed disks** (block storage attached to VMs) and **Azure Blob Storage** (object storage via storage accounts). All commands are `az disk ...`, `az snapshot ...`, or `az storage ...`.

## Managed Disks

### Create a disk

```bash
az disk create \
  --resource-group <rg> \
  --name <disk-name> \
  --size-gb 64 \
  --sku Premium_LRS \
  --location <region>
```

Common `--sku` values: `Standard_LRS`, `Premium_LRS`, `StandardSSD_LRS`, `UltraSSD_LRS`.

### List and inspect disks

```bash
az disk list -g <rg> -o table
az disk list \
  --query '[].{name:name,rg:resourceGroup,sizeGb:diskSizeGb,state:diskState,sku:sku.name}' \
  -o table
az disk show -g <rg> -n <disk-name>
```

`diskState` values to watch: `Attached`, `Unattached` (still bills), `Reserved`.

### Attach and detach a disk from a VM

```bash
# Attach
az vm disk attach \
  --resource-group <rg> \
  --vm-name <vm-name> \
  --name <disk-name>

# Detach
az vm disk detach \
  --resource-group <rg> \
  --vm-name <vm-name> \
  --name <disk-name>
```

### Resize a disk (VM must be deallocated first)

```bash
az vm deallocate -g <rg> -n <vm-name>
az disk update -g <rg> -n <disk-name> --size-gb 128
az vm start -g <rg> -n <vm-name>
```

### Delete a disk

```bash
az disk delete -g <rg> -n <disk-name> --yes
```

Note: `az vm delete` does **not** automatically delete attached disks. Check for unattached disks after deleting VMs.

## Snapshots

Snapshots are point-in-time copies of a managed disk and bill for the data stored.

```bash
# Create a snapshot from a disk
az snapshot create \
  --resource-group <rg> \
  --name <snapshot-name> \
  --source <disk-name-or-id>

# List snapshots
az snapshot list -g <rg> \
  --query '[].{name:name,sizeGb:diskSizeGb,created:timeCreated}' -o table

# Create a new disk from a snapshot
az disk create \
  --resource-group <rg> \
  --name <new-disk-name> \
  --source <snapshot-name-or-id>

# Delete a snapshot
az snapshot delete -g <rg> -n <snapshot-name> --yes
```

## Azure Blob Storage (Object Storage)

Blob Storage is accessed through a **storage account** which contains **containers** (buckets) that hold **blobs** (objects).

### Create a storage account

```bash
az storage account create \
  --resource-group <rg> \
  --name <account-name> \
  --sku Standard_LRS \
  --kind StorageV2 \
  --location <region>
```

Storage account names must be globally unique, 3–24 lowercase alphanumeric characters.

### Create a container (bucket)

```bash
az storage container create \
  --name <container-name> \
  --account-name <account-name>
```

### Upload, list, and download blobs

```bash
# Upload a file
az storage blob upload \
  --account-name <account-name> \
  --container-name <container-name> \
  --name <blob-name> \
  --file ./local-file.txt

# List blobs
az storage blob list \
  --account-name <account-name> \
  --container-name <container-name> \
  -o table

# Download a blob
az storage blob download \
  --account-name <account-name> \
  --container-name <container-name> \
  --name <blob-name> \
  --file ./downloaded-file.txt

# Delete a blob
az storage blob delete \
  --account-name <account-name> \
  --container-name <container-name> \
  --name <blob-name>
```

### List and delete storage accounts

```bash
az storage account list -g <rg> -o table
az storage account delete -g <rg> -n <account-name> --yes
```

## Beyond the basics

Run `az disk --help`, `az snapshot --help`, and `az storage --help` for the full subcommand lists. Advanced topics include shared disks (`--max-shares`), disk encryption sets (`az disk-encryption-set`), storage account access keys and SAS tokens (`az storage account keys list`, `az storage account generate-sas`), and Azure File Shares (`az storage share`).
