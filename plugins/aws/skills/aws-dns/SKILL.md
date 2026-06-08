---
name: aws-dns
description: "Use when the user needs to manage AWS DNS — Route 53 hosted zones and records (A, AAAA, CNAME, MX, TXT, alias) including create, list, update, and delete."
---

# AWS DNS (Route 53)

All commands are `aws route53 ...`. Route 53 is a global service — no `--region` flag is required. See the `aws-setup` skill for auth.

## Hosted Zones

A hosted zone holds the DNS records for a domain. Public zones are authoritative for internet traffic; private zones resolve only within a VPC.

```bash
# Create a public hosted zone
# --caller-reference must be unique per request (timestamp is fine)
aws route53 create-hosted-zone \
  --name example.com \
  --caller-reference "$(date +%s)"

# Create a private hosted zone (resolves inside a VPC only)
aws route53 create-hosted-zone \
  --name internal.example.com \
  --caller-reference "$(date +%s)" \
  --vpc VPCRegion=us-east-1,VPCId=<vpc-id>

# List all hosted zones
aws route53 list-hosted-zones \
  --query 'HostedZones[].{id:Id,name:Name,private:Config.PrivateZone,records:ResourceRecordSetCount}' \
  --output table

# Get the nameservers to delegate from your registrar
aws route53 get-hosted-zone --id <zone-id> \
  --query 'DelegationSet.NameServers'

# Delete a zone (all records except the default NS/SOA must be removed first)
aws route53 delete-hosted-zone --id <zone-id>
```

## Records

Route 53 records are managed via a `change-resource-record-sets` call with a JSON change batch. This handles creates, upserts, and deletes in a single atomic request.

### Upsert (create or replace) common record types

```bash
# Upsert an A record
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "www.example.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "203.0.113.10"}]
      }
    }]
  }'

# Upsert a CNAME record
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "blog.example.com",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{"Value": "my-alb-1234.us-east-1.elb.amazonaws.com"}]
      }
    }]
  }'

# Upsert a TXT record (e.g. for domain verification or SPF)
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "example.com",
        "Type": "TXT",
        "TTL": 300,
        "ResourceRecords": [{"Value": "\"v=spf1 include:amazonses.com ~all\""}]
      }
    }]
  }'
```

### Alias records (free; no TTL; point at AWS resources)

Alias records resolve to AWS resources (ALB, CloudFront, S3 static website, etc.) without a query charge.

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "<alb-hosted-zone-id>",
          "DNSName": "my-alb-1234.us-east-1.elb.amazonaws.com",
          "EvaluateTargetHealth": true
        }
      }
    }]
  }'
```

The ALB's hosted zone ID is found in `aws elbv2 describe-load-balancers --query 'LoadBalancers[].CanonicalHostedZoneId'`.

### List records in a zone

```bash
aws route53 list-resource-record-sets --hosted-zone-id <zone-id> \
  --query 'ResourceRecordSets[].{name:Name,type:Type,ttl:TTL}' \
  --output table
```

### Delete a record

Change the `Action` to `DELETE` and provide the exact record name, type, TTL, and value as it currently exists:

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch '{
    "Changes": [{
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "www.example.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "203.0.113.10"}]
      }
    }]
  }'
```

### Check propagation status

```bash
aws route53 get-change --id <change-id>
# Status will be PENDING then INSYNC
```

## Beyond the basics

Use `aws route53 help` for the full operation list and `aws route53domains` for domain registration/transfer. Related: `aws-networking` for load balancers to alias-record against, `aws-security` for ACM certificate DNS validation records.
