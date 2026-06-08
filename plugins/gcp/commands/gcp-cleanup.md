---
name: gcp-cleanup
description: Find orphaned/idle Google Cloud resources that still bill and help clean them up
---

Find Google Cloud resources that are likely wasting money, and help the user remove them — carefully.

## Steps

1. Confirm authentication and the active project (see the `gcp-setup` skill):
   ```bash
   gcloud config list --format='table(core.account,core.project,compute.zone)'
   ```

2. Scan for common sources of idle spend. Run each command and collect the results:

   - **TERMINATED instances (stopped VMs — disks still bill)**
     ```bash
     gcloud compute instances list \
       --filter='status=TERMINATED' \
       --format='table(name,zone.basename(),machineType.basename(),status,lastStartTimestamp)'
     ```

   - **Unattached persistent disks (not used by any instance)**
     ```bash
     gcloud compute disks list \
       --filter='NOT users:*' \
       --format='table(name,zone.basename(),sizeGb,type.basename(),creationTimestamp)'
     ```

   - **RESERVED static IP addresses not attached to any resource**
     ```bash
     gcloud compute addresses list \
       --filter='status=RESERVED' \
       --format='table(name,address,region.basename(),addressType,creationTimestamp)'
     ```

   - **Old snapshots (check age and assess whether they are still needed)**
     ```bash
     gcloud compute snapshots list \
       --format='table(name,diskSizeGb,creationTimestamp,status)' \
       --sort-by=creationTimestamp
     ```

   - **Unused forwarding rules / load balancer components (no healthy backends)**
     ```bash
     gcloud compute forwarding-rules list \
       --format='table(name,IPAddress,region.basename(),target.basename())'
     gcloud compute backend-services list \
       --format='table(name,protocol,healthChecks.basename())'
     ```

3. Present the findings grouped by type, with the estimated reason each is wasteful (e.g. "disk `my-disk` — 100 GB pd-ssd, no instances attached since 2025-01-01"). Do **not** delete anything yet.

4. Ask the user which categories and specific items to remove. Only after explicit per-category confirmation, run the deletes one at a time, echoing each command:

   ```bash
   # Delete a TERMINATED instance (and its boot disk if desired)
   gcloud compute instances delete <name> --zone <zone>
   # Keep disks: gcloud compute instances delete <name> --zone <zone> --keep-disks=all

   # Delete an unattached disk
   gcloud compute disks delete <name> --zone <zone>

   # Release an unused static IP
   gcloud compute addresses delete <name> --region <region>
   # Global IP: gcloud compute addresses delete <name> --global

   # Delete an old snapshot
   gcloud compute snapshots delete <name>

   # Delete a forwarding rule
   gcloud compute forwarding-rules delete <name> --region <region>
   # Global: gcloud compute forwarding-rules delete <name> --global
   ```

5. After deletions, run the scan commands again to confirm the resources are gone and summarize the estimated monthly savings.

Never delete in bulk without per-category confirmation. When unsure whether something is truly orphaned (e.g. a disk that might belong to a future restore), flag it for the user rather than removing it.
