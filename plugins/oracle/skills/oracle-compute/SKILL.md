---
name: oracle-compute
description: "Use when the user needs to launch, list, inspect, start, stop, reset, or terminate Oracle Cloud Infrastructure (OCI) Compute instances, get instance IPs, or look up shapes, images, and availability domains."
---

# Oracle Cloud Infrastructure Compute

Commands are `oci compute ...`. Nearly everything needs `--compartment-id <ocid>`, and launching needs an availability domain, shape, image OCID, and subnet OCID. See the `oracle-setup` skill for auth, profiles, and finding OCIDs.

## Instance Lifecycle

### Launch an Instance

```bash
oci compute instance launch \
  --availability-domain <AD-name> \
  --compartment-id <compartment-ocid> \
  --shape <shape> \
  --image-id <image-ocid> \
  --subnet-id <subnet-ocid> \
  --display-name <name> \
  --assign-public-ip true \
  --metadata '{"ssh_authorized_keys":"'"$(cat ~/.ssh/id_ed25519.pub)"'"}'
```

Key parameters:
- `--availability-domain <name>` - e.g. from `oci iam availability-domain list --compartment-id <ocid>`
- `--compartment-id <ocid>` - Target compartment (required)
- `--shape <shape>` - e.g. `VM.Standard.E4.Flex`, `VM.Standard.A1.Flex` (required)
- `--shape-config '{"ocpus":1,"memoryInGBs":6}'` - Required for `.Flex` shapes
- `--image-id <ocid>` - OS image (`oci compute image list ...`)
- `--subnet-id <ocid>` - Subnet to attach the VNIC to
- `--assign-public-ip true` - Give it a public IP
- `--metadata '{"ssh_authorized_keys":"<pubkey>"}'` - Inject SSH key(s)
- `--user-data-file <path>` - Cloud-init (the CLI base64-encodes it)

### List / Get Instances

```bash
oci compute instance list --compartment-id <ocid> --output table
oci compute instance get --instance-id <ocid>
```

### Terminate (destroy)

```bash
oci compute instance terminate --instance-id <ocid>
oci compute instance terminate --instance-id <ocid> --preserve-boot-volume false
```

Irreversible. `--preserve-boot-volume false` also deletes the boot volume (otherwise it is kept and keeps billing).

## Power Management

Power changes go through a single `action` command:

```bash
oci compute instance action --instance-id <ocid> --action START
oci compute instance action --instance-id <ocid> --action STOP       # graceful within a timeout, else hard
oci compute instance action --instance-id <ocid> --action SOFTSTOP   # graceful shutdown
oci compute instance action --instance-id <ocid> --action SOFTRESET  # graceful reboot
oci compute instance action --instance-id <ocid> --action RESET      # hard reboot
```

Note: a stopped instance stops compute billing, but its **boot/block volumes keep billing**.

## Access

### Get the public IP

```bash
oci compute instance list-vnics --instance-id <ocid> \
  --query 'data[0]."public-ip"' --raw-output
```

Then connect (default user is image-specific — `opc` for Oracle Linux, `ubuntu` for Ubuntu):

```bash
ssh opc@<public-ip>
```

## Shapes, Images, Availability Domains

```bash
oci iam availability-domain list --compartment-id <ocid>
oci compute shape list --compartment-id <ocid> --output table
oci compute image list --compartment-id <ocid> \
  --operating-system "Canonical Ubuntu" --operating-system-version "22.04" \
  --query 'data[0].id' --raw-output
```

## Beyond Compute

OCI's CLI spans the whole platform with `oci <service> <resource> <action>`: networking (`oci network vcn|subnet|...`), block storage (`oci bv volume`), object storage (`oci os`), databases (`oci db`), and Kubernetes (`oci ce cluster`). Run `oci <service> --help`. Many commands support `--wait-for-state` to block until a resource reaches a lifecycle state. This skill focuses on core Compute; broader coverage can be added as additional skills.
