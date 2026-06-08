---
name: ovh-networking
description: "Use when the user needs to manage OVHcloud Public Cloud networking — virtual networks, subnets, routers, security groups and rules, floating IPs, and load balancers via the OpenStack client."
---

# OVHcloud Public Cloud Networking (OpenStack)

OVH Public Cloud networking is OpenStack Neutron, driven by `openstack network ...`. Ensure your `OS_*` credentials/region are set (see the `ovh-setup` skill).

## Virtual Networks

```bash
# Create a private network
openstack network create my-private-net

# List all networks (includes the shared Ext-Net public network)
openstack network list

# Show a network
openstack network show my-private-net

# Delete a network (must have no ports/subnets attached)
openstack network delete my-private-net
```

OVH's routable public network is named `Ext-Net`; attach instances to it directly for a public IP, or attach to a private network and use a floating IP.

## Subnets

```bash
# Create a subnet on a private network
openstack subnet create my-subnet \
  --network my-private-net \
  --subnet-range 192.168.10.0/24 \
  --dns-nameserver 213.186.33.99

# List subnets
openstack subnet list

# Show a subnet
openstack subnet show my-subnet

# Delete a subnet
openstack subnet delete my-subnet
```

## Routers

```bash
# Create a router and connect it to the external (public) network
openstack router create my-router
openstack router set my-router --external-gateway Ext-Net

# Attach a private subnet to the router (for NAT/internet access)
openstack router add subnet my-router my-subnet

# List routers
openstack router list

# Remove a subnet before deleting a router
openstack router remove subnet my-router my-subnet
openstack router delete my-router
```

## Security Groups and Rules

```bash
# Create a security group
openstack security group create web-sg --description "HTTP and SSH"

# Add an SSH ingress rule
openstack security group rule create web-sg \
  --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 --ingress

# Add HTTP and HTTPS ingress rules
openstack security group rule create web-sg \
  --protocol tcp --dst-port 80 --remote-ip 0.0.0.0/0 --ingress
openstack security group rule create web-sg \
  --protocol tcp --dst-port 443 --remote-ip 0.0.0.0/0 --ingress

# List rules for a group
openstack security group rule list web-sg

# Delete a rule
openstack security group rule delete <rule-id>

# List all security groups
openstack security group list

# Delete a security group
openstack security group delete web-sg
```

Attach a security group when creating an instance with `--security-group web-sg`, or add it later:

```bash
openstack server add security group <server> web-sg
openstack server remove security group <server> web-sg
```

## Floating IPs

```bash
# Allocate a floating IP from the public network
openstack floating ip create Ext-Net

# List allocated floating IPs
openstack floating ip list

# Associate with a server
openstack server add floating ip <server-name-or-id> <floating-ip>

# Dissociate from a server
openstack server remove floating ip <server-name-or-id> <floating-ip>

# Release (delete) a floating IP — it stops billing once deleted
openstack floating ip delete <floating-ip>
```

Unassociated floating IPs still bill on OVH Public Cloud. Release them when not in use.

## Load Balancers (Octavia)

```bash
# Create a load balancer on a private subnet
openstack loadbalancer create --name my-lb \
  --vip-subnet-id <subnet-id>

# Wait for it to become ACTIVE
openstack loadbalancer show my-lb

# Create a listener (e.g. HTTP on port 80)
openstack loadbalancer listener create my-lb \
  --name my-listener --protocol HTTP --protocol-port 80

# Create a pool attached to the listener
openstack loadbalancer pool create \
  --name my-pool --lb-algorithm ROUND_ROBIN \
  --listener my-listener --protocol HTTP

# Add backend members (instances)
openstack loadbalancer member create my-pool \
  --address <instance-ip> --protocol-port 80 --subnet-id <subnet-id>

# List load balancers
openstack loadbalancer list

# Delete (remove members and listener first, or cascade)
openstack loadbalancer delete --cascade my-lb
```

## Beyond the basics

Run `openstack network --help`, `openstack loadbalancer --help`, or `openstack security group --help` for the full flag set. For VPN-as-a-Service or advanced routing policies, see the OVH Public Cloud documentation.
