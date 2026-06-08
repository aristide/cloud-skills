---
name: azure-dns
description: "Use when the user needs to manage Azure DNS — public and private zones, and DNS records (A, AAAA, CNAME, MX, TXT, and more)."
---

# Azure DNS

All commands are `az network dns ...`. DNS zones live in a resource group; pass `--resource-group/-g`.

## Zones

### Create a DNS zone

```bash
az network dns zone create \
  --resource-group <rg> \
  --name <zone-name>       # e.g. example.com
```

For a **private** zone (resolves only within linked VNets), use the dedicated `az network private-dns` command group — `--zone-type Private` was removed from `az network dns zone create`:

```bash
az network private-dns zone create \
  --resource-group <rg> \
  --name <zone-name>

# Link the private zone to a VNet so it resolves inside that network
az network private-dns link vnet create \
  --resource-group <rg> \
  --name <link-name> \
  --zone-name <zone-name> \
  --virtual-network <vnet-name> \
  --registration-enabled false
```

### List and inspect zones

```bash
az network dns zone list -g <rg> -o table
az network dns zone show -g <rg> -n <zone-name>
```

After creating a public zone, point your domain registrar's nameservers to the four NS values shown in the output (or `az network dns zone show ... --query nameServers`).

### Delete a zone

```bash
az network dns zone delete -g <rg> -n <zone-name> --yes
```

## Records

Azure DNS groups records into **record sets** (a name + type pair). Most `add-record` commands create or append to the matching record set automatically.

### A records

```bash
# Add an A record (creates the record set if it doesn't exist)
az network dns record-set a add-record \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --record-set-name www \
  --ipv4-address 203.0.113.10

# List A record sets in a zone
az network dns record-set a list -g <rg> -z <zone-name> -o table

# Remove a single A record from a set
az network dns record-set a remove-record \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --record-set-name www \
  --ipv4-address 203.0.113.10

# Delete an entire A record set
az network dns record-set a delete -g <rg> -z <zone-name> -n www --yes
```

### AAAA records

```bash
az network dns record-set aaaa add-record \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --record-set-name www \
  --ipv6-address 2001:db8::1
```

### CNAME records

```bash
az network dns record-set cname set-record \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --record-set-name blog \
  --cname target.example.com
```

### MX records

```bash
az network dns record-set mx add-record \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --record-set-name "@" \
  --exchange mail.example.com \
  --preference 10
```

### TXT records

```bash
az network dns record-set txt add-record \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --record-set-name "@" \
  --value "v=spf1 include:_spf.example.com ~all"
```

### Set TTL on a record set

```bash
az network dns record-set a update \
  --resource-group <rg> \
  --zone-name <zone-name> \
  --name www \
  --set ttl=300
```

### List all record sets in a zone

```bash
az network dns record-set list -g <rg> -z <zone-name> -o table
```

## Beyond the basics

Run `az network dns --help` for the full subcommand list. Other record types (`srv`, `ptr`, `ns`, `caa`, `soa`) follow the same `add-record` / `remove-record` pattern. For private DNS zone VNet links, use `az network private-dns` commands.
