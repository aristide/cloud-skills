---
name: vultr-dns
description: "Use when the user needs to manage Vultr DNS — create and delete domains (zones), and add, list, update, or delete DNS records (A, AAAA, CNAME, MX, TXT, etc.)."
---

# Vultr DNS

Vultr provides free managed DNS hosting for domains you own. You point your registrar's nameservers at Vultr's (`ns1.vultr.com`, `ns2.vultr.com`) and manage records with `vultr-cli dns ...`.

All commands use `vultr-cli dns <sub-group> ...`. Confirm exact flags with `vultr-cli dns --help`.

## Domains (Zones)

```bash
# List all managed domains
vultr-cli dns domain list

# Add a domain (creates the zone; update your registrar's NS records to Vultr after this)
vultr-cli dns domain create <domain.com>

# Inspect or remove
vultr-cli dns domain get    <domain.com>
vultr-cli dns domain delete <domain.com>
```

DNSSEC and SOA management:

```bash
vultr-cli dns domain dnssec      <domain.com>            # enable/disable DNSSEC
vultr-cli dns domain dnssec-info <domain.com>            # show DS records to add at registrar
vultr-cli dns domain soa-info    <domain.com>
vultr-cli dns domain soa-update  <domain.com> --nsprimary ns1.vultr.com --email admin@domain.com
```

## Records

The `vultr-cli dns record create <domain.com>` command takes flags for type, name, data, TTL, and priority.

### A record (IPv4)

```bash
vultr-cli dns record create example.com \
  --type A \
  --name www \
  --data <ipv4-address> \
  --ttl  300
```

### AAAA record (IPv6)

```bash
vultr-cli dns record create example.com \
  --type AAAA \
  --name www \
  --data <ipv6-address> \
  --ttl  300
```

### CNAME record

```bash
vultr-cli dns record create example.com \
  --type  CNAME \
  --name  blog \
  --data  mysite.github.io. \
  --ttl   300
```

### MX record

```bash
vultr-cli dns record create example.com \
  --type     MX \
  --name     "" \
  --data     mail.example.com. \
  --priority 10 \
  --ttl      300
```

`--priority` is required for MX and SRV records; ignored for all others.

### TXT record (e.g. SPF / DKIM / domain verification)

```bash
vultr-cli dns record create example.com \
  --type TXT \
  --name "_dmarc" \
  --data "v=DMARC1; p=none; rua=mailto:dmarc@example.com" \
  --ttl  300
```

### List, get, update, delete records

```bash
vultr-cli dns record list   <domain.com>
vultr-cli dns record get    <domain.com> <record-id>
vultr-cli dns record update <domain.com> <record-id> --data <new-value> --ttl 600
vultr-cli dns record delete <domain.com> <record-id>
```

## Typical workflow: point a domain at a new instance

```bash
# 1. Create the instance, note the IP
vultr-cli instance create --region ewr --plan vc2-1c-1gb --os 2284 --host myapp
vultr-cli instance get <instance-id> -o json | jq -r '.instance.main_ip'

# 2. Add/update the domain
vultr-cli dns domain create myapp.example.com

# 3. Add the A record
vultr-cli dns record create myapp.example.com \
  --type A --name "" --data <instance-ip> --ttl 300
```

## Beyond the basics

Run `vultr-cli dns domain --help` and `vultr-cli dns record --help` for the full flag reference. For bulk record management or zone imports consider using the Vultr API directly or a Terraform/OpenTofu provider.
