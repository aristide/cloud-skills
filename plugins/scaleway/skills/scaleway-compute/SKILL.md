---
name: scaleway-compute
description: "Use when the user needs to create, list, inspect, start, stop, reboot, or delete Scaleway Instances (cloud servers), SSH into them, look up instance types or images, or manage flexible IPs."
---

# Scaleway Instances (Compute)

All commands are `scw instance ...`. Operations are zonal — pass `zone=<zone>` positionally (e.g. `zone=fr-par-1`) or rely on the default zone (see the `scaleway-setup` skill). Confirm exact flags with `scw instance server --help`.

## Instance Lifecycle

### Create a Server

```bash
scw instance server create \
  type=<commercial-type> \
  image=<image> \
  name=<name> \
  zone=<zone>
```

Common arguments (Scaleway CLI uses `key=value` positional args, not `--flags`):
- `type=<type>` - Commercial type, e.g. `DEV1-S`, `PLAY2-MICRO`, `PRO2-XS` (default `DEV1-S`)
- `image=<image>` - Image label or ID, e.g. `ubuntu_jammy`, `debian_bookworm`
- `name=<name>` - Server name
- `zone=<zone>` - e.g. `fr-par-1`, `nl-ams-1`, `pl-waw-1`
- `ip=<new|none|dynamic|<ip-id>>` - Public IP behaviour (default allocates one)
- `root-volume=<spec>` - e.g. `local:20GB` or `block:40GB`
- `tags.0=<tag> tags.1=<tag>` - Tags
- `cloud-init=@<file>` - Cloud-init user data
- `start=true` - Start immediately after creation

By default `create` provisions and starts the server. Use `scw instance server create --help` for the full argument list.

### List / Get Servers

```bash
scw instance server list
scw instance server list zone=fr-par-1
scw instance server list -o table=ID,Name,State,PublicIP,Type
scw instance server get <server-id>
```

## Power Management

```bash
scw instance server start  <server-id>
scw instance server stop   <server-id>     # powers off; storage still bills
scw instance server reboot <server-id>
```

These wait for the action to complete by default. Add `--wait=false` to return immediately (where supported).

### Delete / Terminate (destroy)

```bash
# Delete the server only (volumes and IP are kept unless flagged):
scw instance server delete <server-id>

# Delete the server AND its volumes / flexible IP:
scw instance server delete <server-id> with-volumes=all with-ip=true

# Terminate = stop, then delete the server, its volumes and IP in one step:
scw instance server terminate <server-id>
```

Irreversible. Note that a plain `delete` can leave **orphaned volumes and IPs that keep billing** — prefer `terminate`, or pass `with-volumes=all with-ip=true`, when you truly want everything gone.

## Access

### SSH

```bash
scw instance server ssh <server-id>
scw instance server ssh <server-id> --command "uname -a"
```

If the convenience subcommand is unavailable, fetch the IP and connect manually:

```bash
ip=$(scw instance server get <server-id> -o json | jq -r '.public_ip.address')
ssh root@"$ip"
```

### Get the public IP

```bash
scw instance server get <server-id> -o json | jq -r '.public_ip.address'
```

## Instance Types and Images

```bash
scw instance server-type list zone=fr-par-1     # available commercial types + specs
scw instance image list                          # your images
scw marketplace image list                       # official/public images
```

## Flexible (Public) IPs

```bash
scw instance ip list
scw instance ip create
scw instance ip delete <ip-id>                   # release a flexible IP (stops its billing)
```

Attach/detach an IP to a server:

```bash
scw instance ip update <ip-id> server=<server-id>
```

## Volumes

```bash
scw instance volume list
scw instance volume create name=<name> size=<size> volume-type=<l_ssd|b_ssd> zone=<zone>
scw instance volume delete <volume-id>
```

## Beyond Compute

For Kubernetes (`scw k8s`), object storage (`scw object`), managed databases (`scw rdb`), load balancers (`scw lb`), DNS (`scw dns`), and networking (`scw vpc`), use the same `scw <product> <resource> <verb>` pattern; run `scw <product> --help`. This skill focuses on core Instance compute; broader coverage can be added as additional skills.
