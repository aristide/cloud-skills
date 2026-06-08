---
name: digitalocean-networking
description: "Use when the user needs to manage DigitalOcean networking — VPCs, Cloud Firewalls (rules, Droplet assignment), Reserved IPs, and Load Balancers."
---

# DigitalOcean Networking

VPC and firewall commands live under `doctl vpcs` and `doctl compute firewall`; reserved IPs and load balancers are under `doctl compute reserved-ip` and `doctl compute load-balancer`. See the `digitalocean-setup` skill for auth/region selection.

## VPCs

### Create and list

```bash
doctl vpcs create \
  --name my-vpc \
  --region nyc3 \
  --ip-range 10.10.0.0/16

doctl vpcs list
doctl vpcs get <vpc-id>
```

### Delete

```bash
doctl vpcs delete <vpc-id>    # will fail if Droplets still live in the VPC
```

Droplets created without `--vpc-uuid` land in the default VPC for the region. Use `--vpc-uuid` on `doctl compute droplet create` to place a Droplet in a specific VPC.

## Cloud Firewalls

Firewalls are stateful and can be applied to individual Droplets or to entire tags.

### Create a firewall

```bash
doctl compute firewall create \
  --name web-fw \
  --inbound-rules  "protocol:tcp,ports:22,sources:addresses:0.0.0.0/0 protocol:tcp,ports:80,sources:addresses:0.0.0.0/0 protocol:tcp,ports:443,sources:addresses:0.0.0.0/0" \
  --outbound-rules "protocol:tcp,ports:all,destinations:addresses:0.0.0.0/0,::0/0 protocol:udp,ports:all,destinations:addresses:0.0.0.0/0,::0/0"
```

### List and inspect

```bash
doctl compute firewall list
doctl compute firewall get <firewall-id>
```

### Add / remove rules

```bash
# Add an inbound TCP rule on port 5432 from a specific CIDR
doctl compute firewall add-rules <firewall-id> \
  --inbound-rules "protocol:tcp,ports:5432,sources:addresses:10.10.0.0/16"

# Remove a rule
doctl compute firewall remove-rules <firewall-id> \
  --inbound-rules "protocol:tcp,ports:5432,sources:addresses:10.10.0.0/16"
```

### Assign / remove Droplets

```bash
doctl compute firewall add-droplets    <firewall-id> --droplet-ids <id1>,<id2>
doctl compute firewall remove-droplets <firewall-id> --droplet-ids <id1>

# Tag-based assignment (applies to all Droplets with the tag)
doctl compute firewall add-tags    <firewall-id> --tag-names web
doctl compute firewall remove-tags <firewall-id> --tag-names web
```

### Delete

```bash
doctl compute firewall delete <firewall-id>
```

## Reserved IPs

Reserved IPs are static public IPv4 addresses. An unassigned reserved IP **still incurs a small hourly charge**.

```bash
# Allocate
doctl compute reserved-ip create --region nyc3

# List (shows Droplet assignment status)
doctl compute reserved-ip list

# Assign / unassign
doctl compute reserved-ip-action assign   <reserved-ip> --droplet-id <id>
doctl compute reserved-ip-action unassign <reserved-ip>

# Delete (must be unassigned first)
doctl compute reserved-ip delete <reserved-ip>
```

## Load Balancers

```bash
# Create (HTTP round-robin, health-check on /)
doctl compute load-balancer create \
  --name my-lb \
  --region nyc3 \
  --forwarding-rules "entry_protocol:http,entry_port:80,target_protocol:http,target_port:80" \
  --health-check "protocol:http,port:80,path:/,check_interval_seconds:10,response_timeout_seconds:5,healthy_threshold:3,unhealthy_threshold:3" \
  --droplet-ids <id1>,<id2>

# List / inspect
doctl compute load-balancer list
doctl compute load-balancer get <lb-id>

# Update Droplet membership
doctl compute load-balancer add-droplets    <lb-id> --droplet-ids <id>
doctl compute load-balancer remove-droplets <lb-id> --droplet-ids <id>

# Delete
doctl compute load-balancer delete <lb-id>
```

An idle load balancer with no healthy Droplets still bills. See the `digitalocean-cleanup` command to find empty load balancers.

## Beyond the basics

Run `doctl vpcs --help`, `doctl compute firewall --help`, `doctl compute reserved-ip --help`, and `doctl compute load-balancer --help` to see the full flag surface, including VPC peering, HTTPS/HTTP2 forwarding rules, sticky sessions, and proxy protocol.
