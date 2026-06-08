---
name: gcp-dns
description: "Use when the user needs to manage Google Cloud DNS — managed zones and DNS records (A, AAAA, CNAME, MX, TXT, etc.), including create, list, update, and delete."
---

# Google Cloud DNS

Cloud DNS is GCP's managed, authoritative DNS service. Enable the API first: `gcloud services enable dns.googleapis.com`.

All commands are `gcloud dns ...`. Zones hold records; records are edited via direct `record-sets` commands or a transaction (atomic multi-record edit).

## Managed Zones

A managed zone corresponds to a DNS domain. After creating a zone, delegate it by pointing your registrar's NS records to the nameservers GCP assigns.

```bash
# Create a public zone
gcloud dns managed-zones create my-zone \
  --dns-name="example.com." \
  --description="My production zone"

# Create a private zone (visible only within specified VPCs)
gcloud dns managed-zones create my-private-zone \
  --dns-name="internal.example.com." \
  --description="Internal zone" \
  --visibility=private \
  --networks=my-vpc

gcloud dns managed-zones list
gcloud dns managed-zones describe my-zone

# Get the NS records to set at your registrar
gcloud dns managed-zones describe my-zone \
  --format='get(nameServers)'

gcloud dns managed-zones delete my-zone
```

## Records — Direct Commands

`gcloud dns record-sets create/update/delete` operate directly on individual records (GA since gcloud 400+).

```bash
# Create an A record
gcloud dns record-sets create www.example.com. \
  --zone my-zone \
  --type A \
  --ttl 300 \
  --rrdatas 34.120.0.1

# Create an AAAA record
gcloud dns record-sets create www.example.com. \
  --zone my-zone \
  --type AAAA \
  --ttl 300 \
  --rrdatas "2001:db8::1"

# Create a CNAME record
gcloud dns record-sets create blog.example.com. \
  --zone my-zone \
  --type CNAME \
  --ttl 3600 \
  --rrdatas www.example.com.

# Create an MX record (priority is part of the rrdatas string)
gcloud dns record-sets create example.com. \
  --zone my-zone \
  --type MX \
  --ttl 3600 \
  --rrdatas "10 mail.example.com.","20 mail2.example.com."

# Create a TXT record (SPF, DKIM, domain verification)
gcloud dns record-sets create example.com. \
  --zone my-zone \
  --type TXT \
  --ttl 300 \
  --rrdatas '"v=spf1 include:_spf.google.com ~all"'

# Update a record (replace rrdatas)
gcloud dns record-sets update www.example.com. \
  --zone my-zone \
  --type A \
  --ttl 300 \
  --rrdatas 34.120.0.2

# List all records in a zone
gcloud dns record-sets list --zone my-zone
gcloud dns record-sets list --zone my-zone \
  --format='table(name,type,ttl,rrdatas.list())'

# Delete a record
gcloud dns record-sets delete www.example.com. \
  --zone my-zone \
  --type A
```

## Records — Transaction (atomic multi-record edits)

Use a transaction when you need to add/remove several records atomically.

```bash
# Start a transaction
gcloud dns record-sets transaction start --zone my-zone

# Stage changes
gcloud dns record-sets transaction add 34.120.0.1 \
  --name www.example.com. --type A --ttl 300 --zone my-zone

gcloud dns record-sets transaction remove 34.120.0.0 \
  --name old.example.com. --type A --ttl 300 --zone my-zone

# Inspect the pending transaction
gcloud dns record-sets transaction describe --zone my-zone

# Commit (apply all staged changes atomically)
gcloud dns record-sets transaction execute --zone my-zone

# Abort without committing
gcloud dns record-sets transaction abort --zone my-zone
```

## Beyond the basics

Run `gcloud dns --help` for the full command tree. Cloud DNS also supports DNSSEC (`gcloud dns managed-zones update --dnssec-state on`), routing policies (geo, weighted round-robin), and response policy zones for DNS-based firewall filtering.
