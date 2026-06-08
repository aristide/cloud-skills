---
name: scaleway-dns
description: "Use when the user needs to manage Scaleway Domains and DNS — list and configure DNS zones, and create, update, list, or delete DNS records (A, AAAA, CNAME, MX, TXT, and others)."
---

# Scaleway Domains and DNS

All commands are `scw dns ...`. The DNS product is global (no zone/region flag required for most operations). A DNS zone maps to a domain or subdomain you have registered or delegated to Scaleway name servers. Confirm exact flags with `scw dns --help`.

## DNS Zones

A DNS zone corresponds to a domain (e.g. `example.com`) or a subdomain (e.g. `dev.example.com`). You must own or have delegated the domain to Scaleway before managing records.

```bash
# List all DNS zones
scw dns zone list

# Get details of a specific zone
scw dns zone get <dns-zone>          # e.g. scw dns zone get example.com

# Create a new DNS zone (subdomain delegation)
scw dns zone create domain=example.com subdomain=dev

# Refresh a DNS zone (reloads SOA serial)
scw dns zone refresh <dns-zone>

# Export zone data (BIND format)
scw dns zone export <dns-zone>

# Import records (BIND/axfr format) — replaces existing records
scw dns zone import <dns-zone> content=@records.txt

# Delete a DNS zone and all its records
scw dns zone delete <dns-zone>
```

## DNS Records

Records live within a zone. Use `scw dns record` to manage them. The key verbs are `list`, `add`, `set`, and `delete`.

### List Records

```bash
# List all records in a zone
scw dns record list <dns-zone>

# Filter by type
scw dns record list <dns-zone> type=A
scw dns record list <dns-zone> type=CNAME
```

### Add Records

`add` appends a new record (or adds an additional IP to an existing A/AAAA record of the same name).

```bash
# A record
scw dns record add <dns-zone> \
  records.0.name=www \
  records.0.type=A \
  records.0.data=203.0.113.10 \
  records.0.ttl=3600

# AAAA record
scw dns record add <dns-zone> \
  records.0.name=www \
  records.0.type=AAAA \
  records.0.data=2001:db8::1 \
  records.0.ttl=3600

# CNAME record
scw dns record add <dns-zone> \
  records.0.name=blog \
  records.0.type=CNAME \
  records.0.data=www.example.com. \
  records.0.ttl=3600

# MX record (data includes priority and host)
scw dns record add <dns-zone> \
  records.0.name="" \
  records.0.type=MX \
  records.0.data="10 mail.example.com." \
  records.0.ttl=3600

# TXT record
scw dns record add <dns-zone> \
  records.0.name="" \
  records.0.type=TXT \
  records.0.data="v=spf1 include:_spf.example.com ~all" \
  records.0.ttl=3600
```

Use `name=""` for the zone apex (root of the domain).

### Set (Overwrite) Records

`set` replaces an existing record (same name + type) entirely:

```bash
scw dns record set <dns-zone> \
  records.0.name=www \
  records.0.type=A \
  records.0.data=203.0.113.20 \
  records.0.ttl=300
```

### Delete Records

`delete` removes a specific record by name, type, and data:

```bash
scw dns record delete <dns-zone> \
  records.0.name=www \
  records.0.type=A \
  records.0.data=203.0.113.10
```

To clear all records of a given name and type, use `clear`:

```bash
scw dns record clear <dns-zone> \
  records.0.name=www \
  records.0.type=A
```

## Common Record Types Supported

A, AAAA, CNAME, MX, TXT, NS, SRV, CAA, ALIAS, PTR, TLSA, SSHFP, LOC, NAPTR, DS, DNAME, SVCB, HTTPS.

## Beyond the basics

Use `scw dns --help` and `scw dns record --help` for the full argument lists, including `ttl`, geographic/weighted routing, and DNSSEC. Point newly registered domains at Scaleway name servers (`ns0.dom.scw.cloud` … `ns3.dom.scw.cloud`) from your registrar's control panel before managing records here.
