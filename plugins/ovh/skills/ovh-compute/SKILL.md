---
name: ovh-compute
description: "Use when the user needs to create, list, inspect, start, stop, reboot, resize, rebuild, or delete OVHcloud Public Cloud instances via the OpenStack client, manage keypairs and floating IPs, or look up flavors and images."
---

# OVHcloud Public Cloud Instances (OpenStack)

OVH Public Cloud compute is OpenStack Nova, driven by `openstack server ...`. Ensure your `OS_*` credentials/region are set (see the `ovh-setup` skill).

## Instance Lifecycle

### Create a Server

```bash
openstack server create <name> \
  --flavor <flavor> \
  --image <image> \
  --key-name <keypair> \
  --network Ext-Net
```

Common flags:
- `--flavor <name/id>` - Instance size, e.g. `b3-8`, `d2-4` (required; `openstack flavor list`)
- `--image <name/id>` - OS image, e.g. `Ubuntu 22.04` (required; `openstack image list`)
- `--key-name <keypair>` - SSH keypair to inject (see "Keypairs")
- `--network <name>` - Network to attach; OVH's public network is typically `Ext-Net`
- `--security-group <name>` - Security group(s)
- `--user-data <file>` - Cloud-init file
- `--boot-from-volume <size-gb>` - Boot from a new block volume of the given size
- `--wait` - Block until the server is active

### List / Show Servers

```bash
openstack server list
openstack server list -f json
openstack server show <name-or-id>
```

### Delete (destroy)

```bash
openstack server delete <name-or-id>
```

Irreversible. Destroys the instance (and ephemeral disk).

## Power Management

```bash
openstack server start  <name-or-id>
openstack server stop   <name-or-id>     # SHUTOFF — OVH Public Cloud still bills a stopped instance
openstack server reboot <name-or-id>          # soft reboot
openstack server reboot --hard <name-or-id>   # hard reboot
```

A stopped (`SHUTOFF`) instance keeps billing on OVH Public Cloud — delete it to stop charges.

## Resize and Rebuild

```bash
# Resize to another flavor (then confirm):
openstack server resize --flavor b3-16 <name-or-id>
openstack server resize confirm <name-or-id>

# Rebuild = reinstall from an image (data lost):
openstack server rebuild --image "Ubuntu 22.04" <name-or-id>
```

## Access

### Keypairs

```bash
openstack keypair list
openstack keypair create --public-key ~/.ssh/id_ed25519.pub my-key
openstack keypair delete my-key
```

### Get the IP and SSH

```bash
openstack server show <name> -f value -c addresses
ssh ubuntu@<ip>        # default user depends on the image (ubuntu/debian/centos/...)
```

### Floating IPs (if using private networks)

```bash
openstack floating ip create Ext-Net
openstack server add floating ip <server> <floating-ip>
openstack floating ip delete <floating-ip>
```

## Flavors and Images

```bash
openstack flavor list
openstack image list
openstack image show "Ubuntu 22.04"
```

## Beyond Compute

The same `openstack` client manages block storage (`openstack volume ...`), networks (`openstack network ...`), security groups (`openstack security group ...`), and object storage (`openstack container/object ...`) on OVH Public Cloud. Run `openstack help` or `openstack <noun> --help`. This skill focuses on core instance compute; broader coverage can be added as additional skills.
