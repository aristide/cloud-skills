---
name: gcp-networking
description: "Use when the user needs to manage Google Cloud networking — VPCs, subnets, firewall rules, static IP addresses, and load balancers."
---

# Google Cloud Networking

All commands are `gcloud compute networks ...` and related subgroups. Operations may be global, regional, or zonal — pass `--region` or `--zone` as required (or set defaults — see the `gcp-setup` skill). Enable the Compute Engine API first: `gcloud services enable compute.googleapis.com`.

## VPCs

```bash
# Create a custom-mode VPC (auto-mode creates a subnet per region automatically)
gcloud compute networks create my-vpc --subnet-mode=custom
gcloud compute networks create my-vpc --subnet-mode=auto

gcloud compute networks list
gcloud compute networks describe my-vpc
gcloud compute networks delete my-vpc
```

## Subnets

```bash
# Create a subnet inside a custom-mode VPC
gcloud compute networks subnets create my-subnet \
  --network my-vpc \
  --region us-central1 \
  --range 10.0.1.0/24

gcloud compute networks subnets list --filter='network~my-vpc'
gcloud compute networks subnets describe my-subnet --region us-central1
gcloud compute networks subnets delete my-subnet --region us-central1
```

Enable Private Google Access (reach Google APIs without an external IP):

```bash
gcloud compute networks subnets update my-subnet \
  --region us-central1 \
  --enable-private-ip-google-access
```

## Firewall Rules

Firewall rules are global and applied to instances via **network tags**.

```bash
# Allow inbound HTTP/HTTPS to instances tagged "web"
gcloud compute firewall-rules create allow-http-https \
  --network my-vpc \
  --allow tcp:80,tcp:443 \
  --target-tags web \
  --direction INGRESS \
  --source-ranges 0.0.0.0/0

# Allow SSH from a specific CIDR
gcloud compute firewall-rules create allow-ssh \
  --network my-vpc \
  --allow tcp:22 \
  --source-ranges 203.0.113.0/24

gcloud compute firewall-rules list --format='table(name,network,direction,allowed[].map().firewall_rule().list(),targetTags.list())'
gcloud compute firewall-rules describe allow-http-https
gcloud compute firewall-rules delete allow-http-https
```

Tag an instance to apply a rule:

```bash
gcloud compute instances add-tags my-instance --zone us-central1-a --tags web
```

## Static IP Addresses

Reserved static IPs bill while not attached to an instance.

```bash
# Reserve a regional external static IP
gcloud compute addresses create my-static-ip --region us-central1

# Reserve a global static IP (for global load balancers)
gcloud compute addresses create my-global-ip --global

gcloud compute addresses list
gcloud compute addresses describe my-static-ip --region us-central1

# Assign to an existing instance access config
gcloud compute instances delete-access-config my-instance \
  --access-config-name "External NAT" --zone us-central1-a
gcloud compute instances add-access-config my-instance \
  --access-config-name "External NAT" \
  --address $(gcloud compute addresses describe my-static-ip --region us-central1 --format='get(address)') \
  --zone us-central1-a

gcloud compute addresses delete my-static-ip --region us-central1
```

## Load Balancers

GCP load balancing uses forwarding rules, target proxies, backend services, and health checks as separate resources. Below is the pattern for an HTTP(S) load balancer.

```bash
# 1. Create an instance group or NEG as the backend target
gcloud compute instance-groups managed create my-ig \
  --zone us-central1-a --template my-template --size 2

# 2. Create a health check
gcloud compute health-checks create http my-health-check --port 80

# 3. Create a backend service and attach the instance group
gcloud compute backend-services create my-backend \
  --protocol HTTP --health-checks my-health-check --global
gcloud compute backend-services add-backend my-backend \
  --instance-group my-ig --instance-group-zone us-central1-a --global

# 4. Create a URL map, target proxy, and forwarding rule
gcloud compute url-maps create my-url-map --default-service my-backend
gcloud compute target-http-proxies create my-proxy --url-map my-url-map
gcloud compute forwarding-rules create my-lb \
  --global --target-http-proxy my-proxy --ports 80

# List forwarding rules
gcloud compute forwarding-rules list --format='table(name,IPAddress,target.basename())'
gcloud compute forwarding-rules delete my-lb --global
```

## Beyond the basics

Run `gcloud compute networks --help`, `gcloud compute firewall-rules --help`, or `gcloud compute forwarding-rules --help` for the full flag set. VPC peering (`gcloud compute networks peerings create`), Cloud NAT (`gcloud compute routers nats create`), and VPN (`gcloud compute vpn-tunnels`) follow the same `gcloud compute` pattern.
