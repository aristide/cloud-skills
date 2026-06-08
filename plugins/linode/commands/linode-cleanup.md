---
name: linode-cleanup
description: Find orphaned/idle Linode resources that still bill and help clean them up
---

Find Linode resources that are likely wasting money, and help the user remove them — carefully.

## Steps

1. Confirm authentication and the active account:
   ```bash
   linode-cli account view
   linode-cli show-active-user
   ```

2. Scan for common sources of idle spend:

   - **Powered-off Linodes that still bill** — a shut-down Linode continues to accrue hourly charges; only deletion stops billing:
     ```bash
     linode-cli linodes list --text --format "id,label,status,type,region" --no-headers | grep offline
     ```

   - **Unattached Block Storage volumes** — volumes bill by the GB whether attached or not:
     ```bash
     linode-cli volumes list --text --format "id,label,size,status,linode_id,region" --no-headers
     ```
     Flag any row where `linode_id` is empty.

   - **NodeBalancers with no backends** — a NodeBalancer with zero backend nodes still bills hourly:
     ```bash
     linode-cli nodebalancers list --text --format "id,label,region" --no-headers
     ```
     For each, check its configs:
     ```bash
     linode-cli nodebalancers configs-list <nb-id>
     ```

   - **LKE clusters** — each LKE cluster's node pool Linodes bill normally; the control plane is free:
     ```bash
     linode-cli lke clusters-list --text --format "id,label,region,k8s_version,status" --no-headers
     ```
     Ask whether any clusters are unused test environments.

   - **Object Storage buckets** — billing is per GB stored and per GB transferred:
     ```bash
     linode-cli object-storage buckets-list
     ```
     Ask whether any buckets contain old or unused data.

   - **Old Linode backups and snapshots** — manual snapshots (taken via `linode-cli linodes snapshot`) bill for storage:
     ```bash
     linode-cli linodes list --text --format "id,label" --no-headers
     # For each linode:
     linode-cli linodes backups-list <linode-id>
     ```

3. Present the findings grouped by type, with the reason each is wasteful. For example:
   - "Linode `old-test-1` (id: 12345) — status: offline, type: g6-standard-4, region: us-east — powered off but still billing ~$24/month."
   - "Volume `logs-vol` (id: 67890) — 200 GB, detached (no linode_id) — billing ~$20/month."

   Do **not** delete anything yet.

4. Ask the user which items to remove. Only after explicit per-category confirmation, run the deletes one at a time, echoing each command:

   ```bash
   # Delete a Linode (irreversible — destroys disks)
   linode-cli linodes delete <linode-id>

   # Delete a volume (must be detached first)
   linode-cli volumes detach <volume-id>
   linode-cli volumes delete <volume-id>

   # Delete a NodeBalancer
   linode-cli nodebalancers delete <nb-id>

   # Delete an LKE cluster
   linode-cli lke cluster-delete <cluster-id>

   # Delete an Object Storage bucket (must be empty first)
   linode-cli object-storage bucket-delete <cluster-id> <bucket-label>

   # Delete a manual snapshot (backup)
   linode-cli linodes snapshot-delete <linode-id> <snapshot-id>
   ```

Never delete in bulk without per-category confirmation. The safety hook will also warn on each destructive call. When unsure whether something is truly orphaned (e.g. a volume with a meaningful label, or an LKE cluster with recent activity), flag it for the user rather than removing it.
