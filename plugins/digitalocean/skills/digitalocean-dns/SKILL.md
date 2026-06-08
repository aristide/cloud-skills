---
name: digitalocean-dns
description: "Use when the user needs to manage DigitalOcean DNS — domains (zones) and records (A, AAAA, CNAME, MX, TXT, SRV, CAA), including create, list, update, and delete."
---

# DigitalOcean DNS

DigitalOcean provides managed authoritative DNS at no extra cost. Domain and record commands are under `doctl compute domain`. See the `digitalocean-setup` skill for auth.

> To use DigitalOcean DNS, point your domain's nameservers at `ns1.digitalocean.com`, `ns2.digitalocean.com`, and `ns3.digitalocean.com` at your registrar.

## Domains (Zones)

```bash
# Add a domain (creates the zone; optionally ties it to a Droplet IP)
doctl compute domain create example.com --ip-address <droplet-public-ip>

# List all domains in the account
doctl compute domain list

# Get a single domain
doctl compute domain get example.com

# Delete a domain (deletes all records too — irreversible)
doctl compute domain delete example.com
```

## Records

```bash
# List all records for a domain
doctl compute domain records list example.com
doctl compute domain records list example.com --format ID,Type,Name,Data,TTL --no-header
```

### A record (IPv4)

```bash
doctl compute domain records create example.com \
  --record-type A \
  --record-name www \
  --record-data 203.0.113.10 \
  --record-ttl 3600
```

### AAAA record (IPv6)

```bash
doctl compute domain records create example.com \
  --record-type AAAA \
  --record-name www \
  --record-data 2001:db8::1 \
  --record-ttl 3600
```

### CNAME record

```bash
doctl compute domain records create example.com \
  --record-type CNAME \
  --record-name blog \
  --record-data example.com. \
  --record-ttl 43200
```

The data value for a CNAME must end with a trailing dot (`.`).

### MX record

```bash
doctl compute domain records create example.com \
  --record-type MX \
  --record-name @ \
  --record-data mail.example.com. \
  --record-priority 10 \
  --record-ttl 3600
```

### TXT record (e.g. SPF, DKIM, domain verification)

```bash
doctl compute domain records create example.com \
  --record-type TXT \
  --record-name @ \
  --record-data "v=spf1 include:_spf.example.com ~all" \
  --record-ttl 3600
```

### Update a record

```bash
doctl compute domain records update example.com \
  --record-id <record-id> \
  --record-data 203.0.113.20 \
  --record-ttl 300
```

### Delete a record

```bash
doctl compute domain records delete example.com --record-id <record-id>
```

Get record IDs from `doctl compute domain records list example.com --format ID,Type,Name --no-header`.

## Beyond the basics

Run `doctl compute domain --help` and `doctl compute domain records --help` for the full flag surface, including SRV and CAA record types, `--record-weight`, `--record-port`, and `--record-flags`. DigitalOcean DNS propagation is typically under 60 seconds once records are created.
