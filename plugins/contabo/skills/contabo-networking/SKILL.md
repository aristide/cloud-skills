---
name: contabo-networking
description: "Use when the user needs to manage Contabo private networks, virtual IPs (VIPs), or cloud firewalls — create, list, update, or delete private networks, list reserved VIPs, and manage firewall rules."
---

# Contabo Networking

All commands are `cntb <verb> <resource> ...`. Confirm exact flags with `cntb create privateNetwork --help` etc. — resource identifiers may change over time, so look them up live.

> **Scope note:** Contabo's `cntb` CLI exposes **Private Networks**, **VIPs**, and **Firewalls**. Contabo launched a managed cloud-level firewall in April 2026 — it is free with every VPS/VDS and is fully manageable via `cntb` (see "Firewalls" below). There is no managed load-balancer product; for load balancing, consider running HAProxy or nginx on a Contabo instance.

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
  --region <region>
```

Common flags (verify with `cntb create privateNetwork --help`):
- `--name <name>` - Friendly display name (required)
- `--region <region>` - Region code (e.g. `EU`, `US-central`) (required)
- `--description <text>` - Optional description

> **Note:** There is no `--cidr` flag for `cntb create privateNetwork`. CIDR configuration is handled by the platform automatically.

After creating the network, assign instances to it using:

```bash
cntb assign privateNetwork <privateNetworkId> <instanceId>
```

To remove an instance:

```bash
cntb unassign privateNetwork <privateNetworkId> <instanceId>
```

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

## Firewalls

Contabo launched a managed cloud-level firewall in April 2026 — free with every VPS/VDS. It operates at the **network edge** (before traffic reaches the instance) and is fully manageable via `cntb`.

Default behaviour when activated: **all inbound traffic is blocked** until you create allow rules. Outbound is unrestricted. Supports TCP, UDP, and ICMP rules with single ports, port ranges, and source IP/CIDR filtering. One firewall policy can be assigned to multiple instances.

### List firewalls

```bash
cntb get firewalls
cntb get firewalls -o json
```

### Get firewall details

```bash
cntb get firewall <firewall-id>
```

### Get firewall rules

```bash
cntb get firewall-rules <firewall-id>
```

### Create a firewall

```bash
cntb create firewall \
  --name "<name>" \
  --status active \
  --rules '[{"action":"allow","protocol":"tcp","dstPort":"22","srcCidrIpv4":"0.0.0.0/0"}]'
```

Flags (verify with `cntb create firewall --help`):
- `--name <name>` - Firewall name (required)
- `--status <active|inactive>` - Whether the firewall is active (required)
- `--description <text>` - Optional description
- `--rules <json>` - Firewall rules in JSON format (optional)

### Update firewall metadata

```bash
cntb update firewall <firewall-id> --name "<new-name>"
```

### Update firewall rules

```bash
cntb update firewall-rules <firewall-id> \
  --rules '{"inbound":[{"action":"allow","protocol":"tcp","dstPort":"22","srcCidrIpv4":"0.0.0.0/0"}]}'
```

### Assign a firewall to an instance

```bash
cntb assign firewall <firewall-id> <instance-id>
```

### Remove a firewall from an instance

```bash
cntb unassign firewall <firewall-id> <instance-id>
```

### Delete a firewall

```bash
cntb delete firewall <firewall-id>
```

## Beyond the basics

```bash
cntb get privateNetworks --help
cntb create privateNetwork --help
cntb get vips --help
cntb get firewalls --help
cntb create firewall --help
```

For instance-level networking (IPs, SSH access), see the `contabo-compute` skill. For object storage endpoints, see `contabo-storage`.
