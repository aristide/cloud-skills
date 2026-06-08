---
name: linode-networking
description: "Use when the user needs to manage Linode networking — VPCs, Cloud Firewalls, IP addresses, and NodeBalancers (load balancers)."
---

# Linode Networking

All commands are `linode-cli <group> ...`. See the `linode-setup` skill for auth and region selection.

## VPCs

VPCs provide private, isolated Layer 3 networks within a region. Linodes can be attached to a VPC subnet and communicate privately.

```bash
# List VPCs
linode-cli vpcs list

# Create a VPC
linode-cli vpcs create \
  --label my-vpc \
  --region us-east \
  --subnets '[{"label":"web","ipv4":"10.0.1.0/24"}]'

# View a VPC
linode-cli vpcs view <vpc-id>

# List subnets in a VPC
linode-cli vpcs subnets-list <vpc-id>

# Create a subnet in an existing VPC
linode-cli vpcs subnet-create <vpc-id> \
  --label db \
  --ipv4 10.0.2.0/24

# Delete a subnet (must be empty)
linode-cli vpcs subnet-delete <vpc-id> <subnet-id>

# Delete a VPC (all subnets must be deleted first)
linode-cli vpcs delete <vpc-id>
```

## Cloud Firewalls

Cloud Firewalls attach to Linodes and LKE node pools to filter inbound and outbound traffic.

```bash
# List firewalls
linode-cli firewalls list

# Create a firewall with an initial inbound SSH rule
linode-cli firewalls create \
  --label my-firewall \
  --rules.inbound_policy DROP \
  --rules.outbound_policy ACCEPT \
  --rules.inbound '[{"action":"ACCEPT","protocol":"TCP","ports":"22","addresses":{"ipv4":["0.0.0.0/0"]}}]'

# View firewall details (rules, devices)
linode-cli firewalls view <firewall-id>

# List rules on a firewall
linode-cli firewalls rules-list <firewall-id>

# Update all rules on a firewall (replaces the rule set)
linode-cli firewalls rules-update <firewall-id> \
  --inbound_policy DROP \
  --outbound_policy ACCEPT \
  --inbound '[{"action":"ACCEPT","protocol":"TCP","ports":"22,80,443","addresses":{"ipv4":["0.0.0.0/0"],"ipv6":["::0/0"]}}]'

# List Linodes attached to a firewall
linode-cli firewalls devices-list <firewall-id>

# Attach a Linode to a firewall
linode-cli firewalls device-create <firewall-id> \
  --id <linode-id> \
  --type linode

# Remove a Linode from a firewall
linode-cli firewalls device-delete <firewall-id> <device-id>

# Delete a firewall
linode-cli firewalls delete <firewall-id>
```

Supported protocols: `TCP`, `UDP`, `ICMP`, `IPENCAP`. Ports support ranges (`80-90`) and comma-separated lists.

## IP Addresses

```bash
# List all IPs on the account
linode-cli networking ips-list

# View IPs assigned to a specific Linode
linode-cli linodes ips-list <linode-id>

# Add a private IP to a Linode (then reboot to activate)
linode-cli linodes ip-add <linode-id> --type ipv4 --public false

# Allocate a new public IPv4 (requires a paid plan with available IP slots)
linode-cli linodes ip-add <linode-id> --type ipv4 --public true

# Assign/move IPs between Linodes in the same region
linode-cli networking ip-assign \
  --region us-east \
  --assignments '[{"address":"<ip>","linode_id":<linode-id>}]'

# View RDNS (rDNS) for an IP
linode-cli networking ip-view <ip-address>

# Update rDNS for an IP
linode-cli networking ip-update <ip-address> --rdns <hostname>
```

Note: IPv4 addresses that are not attached to a Linode may still incur charges. Delete the Linode or release the IP to stop billing.

## NodeBalancers (Load Balancers)

NodeBalancers distribute traffic across Linodes at Layer 4 (TCP) and Layer 7 (HTTP/HTTPS).

```bash
# List NodeBalancers
linode-cli nodebalancers list

# Create a NodeBalancer
linode-cli nodebalancers create \
  --label my-nb \
  --region us-east

# View a NodeBalancer
linode-cli nodebalancers view <nb-id>

# List configs (ports) on a NodeBalancer
linode-cli nodebalancers configs-list <nb-id>

# Create a config (listener) on port 80, HTTP round-robin
linode-cli nodebalancers config-create <nb-id> \
  --port 80 \
  --protocol http \
  --algorithm roundrobin \
  --check http \
  --check_path /health

# Create an HTTPS config (paste cert and key inline)
linode-cli nodebalancers config-create <nb-id> \
  --port 443 \
  --protocol https \
  --ssl_cert "$(cat fullchain.pem)" \
  --ssl_key "$(cat privkey.pem)"

# List nodes (backends) in a config
linode-cli nodebalancers nodes-list <nb-id> <config-id>

# Add a backend node
linode-cli nodebalancers node-create <nb-id> <config-id> \
  --label web-1 \
  --address <private-ip>:80 \
  --weight 100 \
  --mode accept

# Remove a backend node
linode-cli nodebalancers node-delete <nb-id> <config-id> <node-id>

# Delete a NodeBalancer config
linode-cli nodebalancers config-delete <nb-id> <config-id>

# Delete a NodeBalancer
linode-cli nodebalancers delete <nb-id>
```

NodeBalancers bill hourly while they exist, regardless of traffic.

## Beyond the basics

Run `linode-cli firewalls --help`, `linode-cli vpcs --help`, or `linode-cli nodebalancers --help` for the full flag reference. For DNS-level routing see the `linode-dns` skill; for Kubernetes networking see `linode-kubernetes`.
