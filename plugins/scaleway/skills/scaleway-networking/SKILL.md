---
name: scaleway-networking
description: "Use when the user needs to manage Scaleway networking — VPCs, Private Networks, security groups and rules, flexible (public) IPs, and Load Balancers (frontends, backends, routes)."
---

# Scaleway Networking

Commands span `scw vpc`, `scw instance` (security groups and IPs), and `scw lb`. Operations are regional for VPC/LB and zonal for Instance resources. Confirm exact flags with `scw vpc --help`, `scw instance security-group --help`, or `scw lb --help`.

## VPC and Private Networks

Scaleway VPC is regional; Private Networks live inside a VPC and provide L2 isolation.

```bash
# List VPCs in a region
scw vpc vpc list region=fr-par

# Create a VPC
scw vpc vpc create name=my-vpc region=fr-par

# List Private Networks
scw vpc private-network list region=fr-par

# Create a Private Network inside a VPC
scw vpc private-network create \
  name=my-net \
  vpc-id=<vpc-id> \
  region=fr-par

# Get details (shows subnets, DHCP config)
scw vpc private-network get <private-network-id>

# Delete a Private Network (detach all resources first)
scw vpc private-network delete <private-network-id>
```

Attaching an Instance to a Private Network is done via the Instance API (a NIC is added to the server). Confirm current attachment commands with `scw instance private-nic --help`.

```bash
scw instance private-nic create server-id=<server-id> private-network-id=<private-network-id>
scw instance private-nic list   server-id=<server-id>
scw instance private-nic delete server-id=<server-id> private-nic-id=<nic-id>
```

## Security Groups

Security groups are **zonal** and act as stateful firewalls for Instances.

```bash
# List security groups
scw instance security-group list zone=fr-par-1

# Create a security group
scw instance security-group create \
  name=web-sg \
  description="Allow HTTP/HTTPS" \
  zone=fr-par-1

# Get details + rules
scw instance security-group get <security-group-id> zone=fr-par-1

# Add an inbound rule (action=accept|drop, protocol=TCP|UDP|ICMP, direction=inbound|outbound)
scw instance security-group create-rule \
  security-group-id=<sg-id> \
  direction=inbound \
  action=accept \
  protocol=TCP \
  dest-port-from=80 \
  dest-port-to=80 \
  zone=fr-par-1

# List rules for a security group
scw instance security-group list-rules <security-group-id> zone=fr-par-1

# Delete a rule
scw instance security-group delete-rule <rule-id> zone=fr-par-1

# Delete a security group (detach from all servers first)
scw instance security-group delete <security-group-id> zone=fr-par-1
```

Attach a security group to a server:

```bash
scw instance server update <server-id> security-group.id=<sg-id> zone=fr-par-1
```

## Flexible (Public) IPs

Flexible IPs are **zonal** and bill while unattached — release them when no longer needed.

```bash
scw instance ip list zone=fr-par-1
scw instance ip create zone=fr-par-1
scw instance ip get <ip-id> zone=fr-par-1

# Attach to a server
scw instance ip update <ip-id> server=<server-id> zone=fr-par-1

# Detach from a server (leave field empty)
scw instance ip update <ip-id> server="" zone=fr-par-1

# Release / delete (stops billing)
scw instance ip delete <ip-id> zone=fr-par-1
```

## Load Balancers

Load Balancers are **regional** and use a frontend → backend model.

```bash
# List / create / delete LBs
scw lb lb list region=fr-par
scw lb lb create name=my-lb type=LB-S region=fr-par
scw lb lb get <lb-id> region=fr-par
scw lb lb delete <lb-id> region=fr-par

# Backends (define the pool of servers)
scw lb backend list lb-id=<lb-id> region=fr-par
scw lb backend create \
  lb-id=<lb-id> \
  name=my-backend \
  forward-protocol=TCP \
  forward-port=80 \
  server-ip.0=<server-ip> \
  region=fr-par
scw lb backend delete <backend-id> region=fr-par

# Frontends (listener: protocol, port, which backend to use)
scw lb frontend list lb-id=<lb-id> region=fr-par
scw lb frontend create \
  lb-id=<lb-id> \
  backend-id=<backend-id> \
  name=my-frontend \
  inbound-port=80 \
  region=fr-par
scw lb frontend delete <frontend-id> region=fr-par
```

For HTTPS, add a TLS certificate to the frontend:

```bash
scw lb certificate create \
  lb-id=<lb-id> \
  name=my-cert \
  letsencrypt.common-name=example.com \
  region=fr-par

scw lb frontend update <frontend-id> \
  certificate-ids.0=<cert-id> \
  inbound-port=443 \
  region=fr-par
```

## Beyond the basics

Use `scw vpc --help`, `scw instance security-group --help`, and `scw lb --help` for the full argument lists. The VPC Gateway (`scw vpc-gw`) product adds public internet NAT access for private-only Instances — see `scw vpc-gw --help`.
