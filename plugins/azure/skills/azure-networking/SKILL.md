---
name: azure-networking
description: "Use when the user needs to manage Azure networking — virtual networks, subnets, network security groups and rules, public IP addresses, and load balancers."
---

# Azure Networking

All commands are `az network ...`. Network resources live in a resource group; pass `--resource-group/-g` (or set a default — see the `azure-setup` skill).

## Virtual Networks and Subnets

### Create a VNet

```bash
az network vnet create \
  --resource-group <rg> \
  --name <vnet-name> \
  --address-prefix 10.0.0.0/16 \
  --location <region>
```

### Add a subnet

```bash
az network vnet subnet create \
  --resource-group <rg> \
  --vnet-name <vnet-name> \
  --name <subnet-name> \
  --address-prefix 10.0.1.0/24
```

### List and inspect

```bash
az network vnet list -g <rg> -o table
az network vnet show -g <rg> -n <vnet-name>
az network vnet subnet list -g <rg> --vnet-name <vnet-name> -o table
```

### Delete a VNet

```bash
az network vnet delete -g <rg> -n <vnet-name>
```

## Network Security Groups (Firewalls)

### Create an NSG

```bash
az network nsg create -g <rg> -n <nsg-name> --location <region>
```

### Add an inbound rule

```bash
az network nsg rule create \
  --resource-group <rg> \
  --nsg-name <nsg-name> \
  --name allow-ssh \
  --priority 100 \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --destination-port-ranges 22 \
  --access Allow
```

Common flags:
- `--priority` — lower numbers evaluated first (100–4096)
- `--protocol` — `Tcp`, `Udp`, `*`
- `--direction` — `Inbound` or `Outbound`
- `--access` — `Allow` or `Deny`
- `--source-address-prefixes` — CIDR, `*`, or a service tag like `Internet`
- `--destination-port-ranges` — single port, range (`8080-8090`), or `*`

### List rules and delete

```bash
az network nsg rule list -g <rg> --nsg-name <nsg-name> -o table
az network nsg rule delete -g <rg> --nsg-name <nsg-name> -n allow-ssh
az network nsg list -g <rg> -o table
az network nsg delete -g <rg> -n <nsg-name>
```

### Attach an NSG to a subnet

```bash
az network vnet subnet update \
  --resource-group <rg> \
  --vnet-name <vnet-name> \
  --name <subnet-name> \
  --network-security-group <nsg-name>
```

## Public IP Addresses

Public IPs that are not attached to a resource still bill. Standard SKU is required for load balancers and Availability Zones.

```bash
# Create
az network public-ip create \
  --resource-group <rg> \
  --name <ip-name> \
  --sku Standard \
  --allocation-method Static \
  --location <region>

# List (note the 'ipAddress' and 'ipConfiguration' columns)
az network public-ip list -g <rg> \
  --query '[].{name:name,ip:ipAddress,assoc:ipConfiguration.id}' -o table

# Delete an idle IP
az network public-ip delete -g <rg> -n <ip-name>
```

## Load Balancers

```bash
# Create a public-facing Standard load balancer
az network lb create \
  --resource-group <rg> \
  --name <lb-name> \
  --sku Standard \
  --public-ip-address <ip-name> \
  --frontend-ip-name frontend \
  --backend-pool-name backend

# Add a health probe
az network lb probe create \
  --resource-group <rg> \
  --lb-name <lb-name> \
  --name health-probe \
  --protocol Tcp \
  --port 80

# Add a load-balancing rule
az network lb rule create \
  --resource-group <rg> \
  --lb-name <lb-name> \
  --name http-rule \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name frontend \
  --backend-pool-name backend \
  --probe-name health-probe

# List and delete
az network lb list -g <rg> -o table
az network lb delete -g <rg> -n <lb-name>
```

## Beyond the basics

Run `az network --help` for the full subcommand list, which includes route tables (`az network route-table`), VPN gateways (`az network vnet-gateway`), Azure Firewall (`az network firewall`), and peering (`az network vnet peering`). The `azure-compute` skill covers opening ports directly on a VM with `az vm open-port`.
