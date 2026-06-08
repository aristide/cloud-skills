---
name: ovh-dns
description: "Use when the user needs to manage OVHcloud DNS zones and records — OVH DNS is managed via the OVH API or Terraform ovh provider, not the OpenStack client."
---

# OVHcloud DNS

OVH DNS zones are **not** managed through the OpenStack client (`openstack`). OpenStack includes a DNS service called Designate, but OVH Public Cloud does not expose it — DNS on OVH is managed through the **OVH API** or the **OVH control panel**, or via the **Terraform `ovh` provider**.

## Option 1 — OVH Control Panel

For one-off changes, the simplest path is the web control panel:

1. Log in at [https://www.ovh.com/manager](https://www.ovh.com/manager)
2. Navigate to **Web Cloud > Domain names > \<your-domain\> > DNS zone**
3. Add, edit, or delete A, AAAA, CNAME, MX, TXT, and other record types from the UI

## Option 2 — OVH API

The OVH API (`api.ovh.com`) manages DNS zones and records programmatically. Install the Python wrapper:

```bash
pip install ovh
```

Example: add an A record via the OVH API (Python):

```python
import ovh

client = ovh.Client(
    endpoint='ovh-eu',                        # or ovh-ca, ovh-us
    application_key='<APP_KEY>',
    application_secret='<APP_SECRET>',
    consumer_key='<CONSUMER_KEY>',
)

# Create an A record
result = client.post('/domain/zone/example.com/record',
    fieldType='A',
    subDomain='www',
    target='1.2.3.4',
    ttl=3600,
)
print(result)

# Apply changes (required after modifying records)
client.post('/domain/zone/example.com/refresh')
```

List and delete records:

```python
# List all record IDs in a zone
records = client.get('/domain/zone/example.com/record')

# Show a record
client.get(f'/domain/zone/example.com/record/{record_id}')

# Delete a record
client.delete(f'/domain/zone/example.com/record/{record_id}')
client.post('/domain/zone/example.com/refresh')
```

Credentials are obtained from the OVH API token console at [https://www.ovh.com/auth/api/createToken](https://www.ovh.com/auth/api/createToken).

## Option 3 — Terraform `ovh` Provider

For infrastructure-as-code management of DNS alongside compute resources:

```hcl
terraform {
  required_providers {
    ovh = { source = "ovh/ovh" }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_app_key
  application_secret = var.ovh_app_secret
  consumer_key       = var.ovh_consumer_key
}

resource "ovh_domain_zone_record" "www" {
  zone      = "example.com"
  subdomain = "www"
  fieldtype = "A"
  ttl       = 3600
  target    = "1.2.3.4"
}
```

Apply with the standard `terraform init && terraform apply` workflow.

## Beyond the basics

See the full OVH API reference at [https://api.ovh.com/console/](https://api.ovh.com/console/) (filter by `/domain/zone`) and the Terraform OVH provider docs at [https://registry.terraform.io/providers/ovh/ovh/latest/docs](https://registry.terraform.io/providers/ovh/ovh/latest/docs).
