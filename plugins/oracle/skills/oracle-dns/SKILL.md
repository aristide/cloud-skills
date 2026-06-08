---
name: oracle-dns
description: "Use when the user needs to manage Oracle Cloud Infrastructure (OCI) DNS — zones, and records (A, AAAA, CNAME, MX, TXT, etc.) including create, list, update, and delete."
---

# Oracle Cloud Infrastructure DNS

Commands are `oci dns ...`. OCI DNS supports public zones (internet-facing) and private zones (resolvable only inside a VCN). See the `oracle-setup` skill for auth and OCIDs.

## Zones

### Create and List Zones

```bash
# Create a primary public zone
oci dns zone create \
  --compartment-id <compartment-ocid> \
  --name example.com \
  --zone-type PRIMARY

# Create a private zone (scoped to a VCN)
oci dns zone create \
  --compartment-id <compartment-ocid> \
  --name internal.example.com \
  --zone-type PRIMARY \
  --scope PRIVATE \
  --view-id <dns-view-ocid>

oci dns zone list \
  --compartment-id <compartment-ocid> \
  --output table

oci dns zone get \
  --zone-name-or-id example.com

oci dns zone delete \
  --zone-name-or-id example.com
```

After creating a public zone, delegate the domain at your registrar to the NS records OCI assigns (visible in `oci dns zone get`).

## Records

OCI DNS models records as RRsets — all records of the same type and name form one set. Use `oci dns record rrset update` to set the full contents of an RRset (replace-semantics), or `oci dns record domain patch` to make targeted changes.

### Add / Replace an RRset

```bash
# A record (point hostname to IPv4)
oci dns record rrset update \
  --zone-name-or-id example.com \
  --domain www.example.com \
  --rtype A \
  --items '[{"domain":"www.example.com","rtype":"A","ttl":3600,"rdata":"203.0.113.10"}]'

# AAAA record (IPv6)
oci dns record rrset update \
  --zone-name-or-id example.com \
  --domain www.example.com \
  --rtype AAAA \
  --items '[{"domain":"www.example.com","rtype":"AAAA","ttl":3600,"rdata":"2001:db8::1"}]'

# CNAME record
oci dns record rrset update \
  --zone-name-or-id example.com \
  --domain blog.example.com \
  --rtype CNAME \
  --items '[{"domain":"blog.example.com","rtype":"CNAME","ttl":3600,"rdata":"myapp.example.com."}]'

# MX record (mail exchanger)
oci dns record rrset update \
  --zone-name-or-id example.com \
  --domain example.com \
  --rtype MX \
  --items '[{"domain":"example.com","rtype":"MX","ttl":3600,"rdata":"10 mail.example.com."}]'

# TXT record (SPF, domain verification, etc.)
oci dns record rrset update \
  --zone-name-or-id example.com \
  --domain example.com \
  --rtype TXT \
  --items '[{"domain":"example.com","rtype":"TXT","ttl":300,"rdata":"\"v=spf1 include:example.com ~all\""}]'
```

### Patch (add or remove individual records without replacing the full set)

```bash
# Add a second A record to an existing RRset
oci dns record domain patch \
  --zone-name-or-id example.com \
  --domain www.example.com \
  --items '[{"domain":"www.example.com","rtype":"A","ttl":3600,"rdata":"203.0.113.11","operation":"ADD"}]'

# Remove one A record from an RRset
oci dns record domain patch \
  --zone-name-or-id example.com \
  --domain www.example.com \
  --items '[{"domain":"www.example.com","rtype":"A","ttl":3600,"rdata":"203.0.113.10","operation":"REMOVE"}]'
```

### Read Records

```bash
# All records for a specific domain + type (RRset)
oci dns record rrset get \
  --zone-name-or-id example.com \
  --domain www.example.com \
  --rtype A

# All records under a domain name
oci dns record domain get \
  --zone-name-or-id example.com \
  --domain www.example.com

# All records in the zone
oci dns record zone get \
  --zone-name-or-id example.com
```

### Delete Records

```bash
# Delete an entire RRset (all records of a type at a domain)
oci dns record rrset delete \
  --zone-name-or-id example.com \
  --domain www.example.com \
  --rtype A

# Delete all records for a domain name
oci dns record domain delete \
  --zone-name-or-id example.com \
  --domain www.example.com
```

## Beyond the basics

Run `oci dns --help` for the full subcommand list. OCI DNS supports traffic steering (`oci dns steering-policy`) for geo-routing and failover, DNSSEC, and resolver rules for private zones (`oci dns resolver`). Use `--scope PRIVATE` on zone and record commands when working with private DNS views.
