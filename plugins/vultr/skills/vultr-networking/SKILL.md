---
name: vultr-networking
description: "Use when the user needs to manage Vultr networking — VPCs, firewall groups and rules, reserved IPs, and load balancers."
---

# Vultr Networking

All commands use `vultr-cli <group> ...`. Look up region ids with `vultr-cli regions list`. Confirm exact flags with `vultr-cli <group> --help`.

## VPCs

Vultr has two VPC generations. `vpc` is the original; `vpc2` is the current generation with node-attach/detach support. Use `vpc2` for new projects.

### VPC (original)

```bash
vultr-cli vpc list
vultr-cli vpc create --region <region-id> --description "my-vpc" --v4-subnet "10.0.0.0" --v4-subnet-mask 24
vultr-cli vpc get <vpc-id>
vultr-cli vpc update <vpc-id> --description "updated-name"
vultr-cli vpc delete <vpc-id>
```

### VPC 2.0

```bash
vultr-cli vpc2 list
vultr-cli vpc2 create --region <region-id> --description "my-vpc2" --ip-block "10.1.0.0" --prefix-length 24
vultr-cli vpc2 get <vpc2-id>
vultr-cli vpc2 update <vpc2-id> --description "updated"
vultr-cli vpc2 delete <vpc2-id>
```

Manage which instances are on a VPC 2.0 network:

```bash
vultr-cli vpc2 nodes list   <vpc2-id>
vultr-cli vpc2 nodes attach <vpc2-id> --nodes <instance-id>,...
vultr-cli vpc2 nodes detach <vpc2-id> --nodes <instance-id>,...
```

## Firewall Groups and Rules

Firewall groups are stateful rule sets you attach to instances at create time or via the portal. `vultr-cli firewall` has two sub-groups: `group` and `rule`.

```bash
# Manage groups
vultr-cli firewall group list
vultr-cli firewall group create --description "web-servers"
vultr-cli firewall group get    <group-id>
vultr-cli firewall group update <group-id> --description "web-servers-v2"
vultr-cli firewall group delete <group-id>

# Add/remove rules within a group
vultr-cli firewall rule list   <group-id>
vultr-cli firewall rule create <group-id> \
  --protocol tcp \
  --port     "80" \
  --subnet   "0.0.0.0" \
  --subnet-size 0 \
  --type     v4
vultr-cli firewall rule get    <group-id> <rule-id>
vultr-cli firewall rule delete <group-id> <rule-id>
```

Common `--protocol` values: `tcp`, `udp`, `icmp`, `gre`, `esp`, `ah`.  
Use `--subnet 0.0.0.0 --subnet-size 0` to allow all IPv4 sources.

Attach a firewall group to an instance at creation time:

```bash
vultr-cli instance create ... --firewall-group <group-id>
```

## Reserved IPs

Reserved IPs are static public IPs that persist independently of instances. Idle reserved IPs **still bill** until deleted.

```bash
vultr-cli reserved-ip list
vultr-cli reserved-ip create --region <region-id> --type v4 --label "my-ip"
vultr-cli reserved-ip get    <reserved-ip-id>
vultr-cli reserved-ip attach <reserved-ip-id> --instance-id <instance-id>
vultr-cli reserved-ip detach <reserved-ip-id>
vultr-cli reserved-ip update <reserved-ip-id> --label "new-label"
vultr-cli reserved-ip delete <reserved-ip-id>
```

Convert an existing instance IP to a reserved IP (so it survives instance deletion):

```bash
vultr-cli reserved-ip convert --ip <ip-address> --region <region-id> --type v4
```

## Load Balancers

```bash
vultr-cli load-balancer list
vultr-cli load-balancer create \
  --region            <region-id> \
  --label             "my-lb" \
  --forwarding-rules  "frontend_protocol:http,frontend_port:80,backend_protocol:http,backend_port:80" \
  --instances         <instance-id>,... \
  --balancing-algorithm roundrobin
vultr-cli load-balancer get    <lb-id>
vultr-cli load-balancer update <lb-id> --label "new-label"
vultr-cli load-balancer delete <lb-id>
```

Manage forwarding rules and firewall rules on an existing LB:

```bash
vultr-cli load-balancer forwarding list   <lb-id>
vultr-cli load-balancer forwarding create <lb-id> \
  --forwarding-rules "frontend_protocol:https,frontend_port:443,backend_protocol:http,backend_port:80"
vultr-cli load-balancer forwarding delete <lb-id> <rule-id>

vultr-cli load-balancer firewall list <lb-id>
```

## Beyond the basics

Run `vultr-cli vpc --help`, `vultr-cli vpc2 --help`, `vultr-cli firewall --help`, `vultr-cli reserved-ip --help`, or `vultr-cli load-balancer --help` for the full flag reference. To attach a VPC to a new instance, pass `--vpc-ids <vpc-id>` (original VPC) to `vultr-cli instance create`.
