---
name: gcp-status
description: Show an overview of Google Cloud resources in the active project
---

Show a concise overview of the active GCP project's infrastructure.

## Steps

1. Confirm the active account, project, and zone:
   ```bash
   gcloud config list --format='table(core.account,core.project,compute.zone)'
   ```

2. List core resources (skip any that error — often a disabled API — or return empty):
   - Compute Engine instances:
     ```bash
     gcloud compute instances list \
       --format='table(name,zone.basename(),machineType.basename(),status,EXTERNAL_IP:label=EXTERNAL_IP)'
     ```
   - Persistent disks: `gcloud compute disks list --format='table(name,zone.basename(),sizeGb,status,users.basename())'`
   - Static addresses: `gcloud compute addresses list --format='table(name,address,status,region.basename())'`
   - Firewall rules: `gcloud compute firewall-rules list --format='table(name,network,direction,allowed[].map().firewall_rule().list())'`
   - Forwarding rules (load balancers): `gcloud compute forwarding-rules list --format='table(name,IPAddress,target.basename())'`

3. Present a concise summary highlighting:
   - Instance counts by status (skip statuses with zero)
   - `TERMINATED` (stopped) instances whose disks still bill
   - Unattached disks (no `users`)
   - `RESERVED` static addresses not in use (these bill while idle)
   - Anything in an error/provisioning state

Run the list commands and summarize. If not authenticated or no project is set, point the user to the `gcp-setup` skill (`gcloud auth login`, `gcloud config set project`). If a list errors with an API-not-enabled message, suggest `gcloud services enable <api>`.
