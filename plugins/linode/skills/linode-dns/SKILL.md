---
name: linode-dns
description: "Use when the user needs to manage Linode DNS — domains (zones) and records (A, AAAA, CNAME, MX, TXT, SRV, CAA, and more), including create, list, update, and delete."
---

# Linode DNS

All commands are `linode-cli domains ...`. Linode provides authoritative DNS hosting at no extra charge. See the `linode-setup` skill for auth.

## Domains (Zones)

```bash
# List all domains on the account
linode-cli domains list
linode-cli domains list --text --format "id,domain,type,status" --no-headers

# Create a master (primary) zone
linode-cli domains create \
  --type master \
  --domain example.com \
  --soa_email admin@example.com

# Create a slave (secondary) zone
linode-cli domains create \
  --type slave \
  --domain example.com \
  --master_ips '["<primary-ns-ip>"]'

# View a domain
linode-cli domains view <domain-id>

# Update a domain (e.g. change TTL or SOA email)
linode-cli domains update <domain-id> \
  --ttl_sec 300 \
  --soa_email hostmaster@example.com

# Delete a domain (and all its records — irreversible)
linode-cli domains delete <domain-id>
```

Point your registrar's nameserver settings to Linode's nameservers:
`ns1.linode.com`, `ns2.linode.com`, `ns3.linode.com`, `ns4.linode.com`, `ns5.linode.com`.

## Records

```bash
# List all records in a domain
linode-cli domains records-list <domain-id>
linode-cli domains records-list <domain-id> --text --format "id,type,name,target,ttl_sec" --no-headers

# Create an A record (IPv4)
linode-cli domains records-create <domain-id> \
  --type A \
  --name www \
  --target 203.0.113.10 \
  --ttl_sec 300

# Create an AAAA record (IPv6)
linode-cli domains records-create <domain-id> \
  --type AAAA \
  --name www \
  --target 2001:db8::1 \
  --ttl_sec 300

# Create a CNAME record (leave --name blank for zone apex redirects)
linode-cli domains records-create <domain-id> \
  --type CNAME \
  --name blog \
  --target otherdomain.com \
  --ttl_sec 3600

# Create an MX record
linode-cli domains records-create <domain-id> \
  --type MX \
  --name "" \
  --target mail.example.com \
  --priority 10 \
  --ttl_sec 3600

# Create a TXT record (e.g. SPF or domain verification)
linode-cli domains records-create <domain-id> \
  --type TXT \
  --name "_dmarc" \
  --target "v=DMARC1; p=none; rua=mailto:dmarc@example.com" \
  --ttl_sec 300

# Create an SRV record
linode-cli domains records-create <domain-id> \
  --type SRV \
  --name "_sip._tcp" \
  --target sip.example.com \
  --priority 10 \
  --weight 20 \
  --port 5060 \
  --ttl_sec 300

# Create a CAA record
linode-cli domains records-create <domain-id> \
  --type CAA \
  --name "" \
  --target "letsencrypt.org" \
  --tag issue \
  --ttl_sec 3600

# View a single record
linode-cli domains records-view <domain-id> <record-id>

# Update a record (e.g. point an A record at a new IP)
linode-cli domains records-update <domain-id> <record-id> \
  --target 203.0.113.20

# Delete a record
linode-cli domains records-delete <domain-id> <record-id>
```

Use `--ttl_sec 0` to inherit the domain's default TTL. Common TTL values: `300` (5 min, good during migrations), `3600` (1 hr), `86400` (1 day).

## Common Workflow: New Domain

```bash
# 1. Create the zone
linode-cli domains create --type master --domain example.com --soa_email admin@example.com
DOMAIN_ID=$(linode-cli domains list --text --no-headers --format "id,domain" | grep example.com | awk '{print $1}')

# 2. Add records
linode-cli domains records-create "$DOMAIN_ID" --type A     --name ""    --target <server-ip>
linode-cli domains records-create "$DOMAIN_ID" --type A     --name www   --target <server-ip>
linode-cli domains records-create "$DOMAIN_ID" --type MX    --name ""    --target mail.example.com --priority 10
linode-cli domains records-create "$DOMAIN_ID" --type TXT   --name ""    --target "v=spf1 mx ~all"

# 3. Update registrar nameservers to ns1–ns5.linode.com
```

## Beyond the basics

Run `linode-cli domains --help` or `linode-cli domains records-create --help` for the full flag reference. Changes propagate to Linode's nameservers within seconds, but resolvers worldwide respect the record's TTL. For pointing a domain at a NodeBalancer, use its `ipv4` address from `linode-cli nodebalancers view <id>`.
