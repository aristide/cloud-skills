---
name: contabo-networking
description: "Use when the user needs to manage Contabo private networks or virtual IPs (VIPs) — create, list, update, or delete private networks and list reserved VIPs."
---

# Contabo Networking

All commands are `cntb <verb> <resource> ...`. Confirm exact flags with `cntb create privateNetwork --help` etc. — resource identifiers may change over time, so look them up live.

> **Scope note:** Contabo's `cntb` CLI exposes **Private Networks** and **VIPs**. There is no managed firewall, security-group, or load-balancer product accessible through `cntb`. For firewall rules, use the OS-level firewall (e.g. `ufw` / `firewalld`) on your instance. For load balancing, consider running HAProxy or nginx on a Contabo instance, or use an external service.

## Private Networks

Private Networks let multiple Contabo instances communicate over an isolated Layer-2 segment without going through the public internet.

### List

```bash
cntb get privateNetworks
cntb get privateNetworks -o json
```

### Get details

```bash
cntb get privateNetwork <privateNetwork-id>
```

### Create

```bash
cntb create privateNetwork \
  --name "<name>" \
  --region <region> \
  --cidr <cidr>
```

Common flags (verify with `cntb create privateNetwork --help`):
- `--name <name>` - Friendly display name
- `--region <region>` - Region code (e.g. `EU`, `US-central`)
- `--cidr <cidr>` - IPv4 CIDR block for the network (e.g. `10.0.0.0/24`)

After creating the network, assign instances to it from the Contabo Customer Control Panel (CCP) or via the API — check `cntb update instance --help` for any `--privateNetworks` flag in your installed version.

### Update

```bash
cntb update privateNetwork <privateNetwork-id> --name "<new-name>"
```

### Delete

```bash
cntb delete privateNetwork <privateNetwork-id>
```

Detach all instances from the network before deleting it.

## Virtual IPs (VIPs)

VIPs are reserved public IP addresses that can be moved between instances, useful for failover setups.

### List

```bash
cntb get vips
cntb get vips -o json
```

VIP provisioning and assignment is managed through the Contabo Customer Control Panel. `cntb get vips` shows the current inventory; use the CCP to order new VIPs or move them between instances.

## Beyond the basics

```bash
cntb get privateNetworks --help
cntb create privateNetwork --help
cntb get vips --help
```

For instance-level networking (IPs, SSH access), see the `contabo-compute` skill. For object storage endpoints, see `contabo-storage`.
