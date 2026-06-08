---
name: oracle-networking
description: "Use when the user needs to manage Oracle Cloud Infrastructure (OCI) networking — VCNs, subnets, security lists, network security groups, internet/NAT gateways, reserved public IPs, and load balancers."
---

# Oracle Cloud Infrastructure Networking

Commands are `oci network ...` and `oci lb ...` / `oci nlb ...`. Nearly everything needs `--compartment-id <ocid>`. See the `oracle-setup` skill for auth, profiles, and finding OCIDs.

## Virtual Cloud Networks (VCNs)

### Create and List VCNs

```bash
oci network vcn create \
  --compartment-id <compartment-ocid> \
  --cidr-block 10.0.0.0/16 \
  --display-name my-vcn \
  --dns-label myvcn

oci network vcn list --compartment-id <compartment-ocid> --output table
oci network vcn get --vcn-id <vcn-ocid>
oci network vcn delete --vcn-id <vcn-ocid>
```

`--dns-label` is required if you want OCI's internal DNS to resolve hostnames inside the VCN; it must be alphanumeric, ≤15 chars.

## Subnets

```bash
oci network subnet create \
  --compartment-id <compartment-ocid> \
  --vcn-id <vcn-ocid> \
  --cidr-block 10.0.1.0/24 \
  --availability-domain <AD-name> \
  --display-name public-subnet \
  --dns-label pubsub \
  --route-table-id <route-table-ocid> \
  --security-list-ids '["<security-list-ocid>"]'

oci network subnet list --compartment-id <compartment-ocid> --vcn-id <vcn-ocid> --output table
oci network subnet get --subnet-id <subnet-ocid>
oci network subnet delete --subnet-id <subnet-ocid>
```

Omit `--availability-domain` to make a regional subnet (spans all ADs in the region).

## Security Lists

Security lists are stateful firewall rules attached to subnets.

```bash
# Create a security list
oci network security-list create \
  --compartment-id <compartment-ocid> \
  --vcn-id <vcn-ocid> \
  --display-name web-security-list \
  --ingress-security-rules '[
    {"protocol":"6","source":"0.0.0.0/0","tcpOptions":{"destinationPortRange":{"min":22,"max":22}}},
    {"protocol":"6","source":"0.0.0.0/0","tcpOptions":{"destinationPortRange":{"min":80,"max":80}}},
    {"protocol":"6","source":"0.0.0.0/0","tcpOptions":{"destinationPortRange":{"min":443,"max":443}}}
  ]' \
  --egress-security-rules '[{"protocol":"all","destination":"0.0.0.0/0"}]'

oci network security-list list --compartment-id <compartment-ocid> --vcn-id <vcn-ocid> --output table
oci network security-list get --security-list-id <ocid>
oci network security-list delete --security-list-id <ocid>
```

Protocol numbers: `"6"` = TCP, `"17"` = UDP, `"1"` = ICMP, `"all"` = all protocols.

## Network Security Groups (NSGs)

NSGs are attached to individual VNICs (more granular than security lists).

```bash
oci network nsg create \
  --compartment-id <compartment-ocid> \
  --vcn-id <vcn-ocid> \
  --display-name app-nsg

# Add rules to an NSG
oci network nsg rules add \
  --nsg-id <nsg-ocid> \
  --security-rules '[
    {"direction":"INGRESS","protocol":"6","source":"0.0.0.0/0","sourceType":"CIDR_BLOCK",
     "tcpOptions":{"destinationPortRange":{"min":8080,"max":8080}}}
  ]'

oci network nsg list --compartment-id <compartment-ocid> --vcn-id <vcn-ocid> --output table
oci network nsg rules list --nsg-id <nsg-ocid>
oci network nsg delete --nsg-id <nsg-ocid>
```

## Internet and NAT Gateways

```bash
# Internet gateway (public subnet traffic)
oci network internet-gateway create \
  --compartment-id <compartment-ocid> \
  --vcn-id <vcn-ocid> \
  --display-name igw \
  --is-enabled true

oci network internet-gateway list --compartment-id <compartment-ocid> --vcn-id <vcn-ocid>

# NAT gateway (private subnet outbound traffic)
oci network nat-gateway create \
  --compartment-id <compartment-ocid> \
  --vcn-id <vcn-ocid> \
  --display-name nat-gw

oci network nat-gateway list --compartment-id <compartment-ocid> --vcn-id <vcn-ocid>
```

After creating a gateway, add a route rule: `oci network route-table update --rt-id <ocid> --route-rules '[{"networkEntityId":"<igw-ocid>","destination":"0.0.0.0/0"}]'`.

## Reserved Public IPs

Reserved public IPs persist independently of instances and bill when unattached.

```bash
oci network public-ip create \
  --compartment-id <compartment-ocid> \
  --lifetime RESERVED \
  --display-name my-reserved-ip

oci network public-ip list \
  --compartment-id <compartment-ocid> \
  --scope REGION \
  --lifetime RESERVED \
  --output table

# Assign to a private IP (VNIC)
oci network public-ip update \
  --public-ip-id <ocid> \
  --private-ip-id <private-ip-ocid>

oci network public-ip delete --public-ip-id <ocid>
```

## Load Balancers

```bash
# Application Load Balancer (HTTP/HTTPS)
oci lb load-balancer create \
  --compartment-id <compartment-ocid> \
  --display-name my-lb \
  --shape-name flexible \
  --shape-details '{"minimumBandwidthInMbps":10,"maximumBandwidthInMbps":100}' \
  --subnet-ids '["<subnet-ocid>"]' \
  --is-private false \
  --wait-for-state ACTIVE

oci lb load-balancer list --compartment-id <compartment-ocid> --output table
oci lb load-balancer get --load-balancer-id <ocid>
oci lb load-balancer delete --load-balancer-id <ocid>

# Network Load Balancer (TCP/UDP layer 4)
oci nlb network-load-balancer create \
  --compartment-id <compartment-ocid> \
  --display-name my-nlb \
  --subnet-id <subnet-ocid> \
  --is-private false

oci nlb network-load-balancer list --compartment-id <compartment-ocid> --output table
oci nlb network-load-balancer delete --network-load-balancer-id <ocid>
```

## Beyond the basics

Run `oci network --help` to see all resource types: route tables, DHCP options, DRGs (Dynamic Routing Gateways), peerings, and more. Use `--wait-for-state AVAILABLE` on most create commands to block until the resource is ready. For advanced routing (VPN/FastConnect), see `oci network ip-sec-connection` and `oci network virtual-circuit`.
