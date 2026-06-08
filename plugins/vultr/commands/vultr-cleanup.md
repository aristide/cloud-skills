---
name: vultr-cleanup
description: Find orphaned or idle Vultr resources that still bill and help clean them up safely
---

Find Vultr resources that are likely wasting money, and help the user remove them carefully.

## Steps

1. Confirm authentication and the active account:
   ```bash
   vultr-cli account info
   ```
   If this fails, stop and help the user authenticate (see the `vultr-setup` skill).

2. Scan for common sources of idle spend. Run all of the following and collect the output:

   **Stopped instances (still billing)**
   ```bash
   vultr-cli instance list -o json \
     | jq '[.instances[] | select(.power_status == "stopped") | {id, label, plan, region, main_ip, power_status}]'
   ```
   On Vultr a **stopped instance keeps billing** at the full plan rate. Only deleting the instance stops charges.

   **Unattached block storage volumes**
   ```bash
   vultr-cli block-storage list -o json \
     | jq '[.block_storages[] | select(.attached_to_instance == "") | {id, label, region, size_gb, cost}]'
   ```

   **Idle reserved IPs (unattached)**
   ```bash
   vultr-cli reserved-ip list -o json \
     | jq '[.reserved_ips[] | select(.instance_id == "") | {id, label, region, subnet, type}]'
   ```
   Unattached reserved IPs bill a small monthly fee until deleted.

   **Old snapshots**
   ```bash
   vultr-cli snapshot list -o json \
     | jq '[.snapshots[] | {id, description, date_created, size, status}]'
   ```
   Snapshots bill based on stored GB. Old or unlabelled snapshots are common forgotten costs.

   **Idle load balancers**
   ```bash
   vultr-cli load-balancer list -o json \
     | jq '[.load_balancers[] | {id, label, region, status, instances}]'
   ```
   Flag any load balancer with zero attached instances.

   **Kubernetes clusters with zero-node pools** (optional)
   ```bash
   vultr-cli kubernetes list
   ```

3. Present the findings grouped by resource type. For each item note the reason it appears wasteful (e.g. "Block storage `data-vol` — 200 GB, detached since creation"). Do **not** delete anything at this stage.

4. Ask the user which items to remove. Confirm per category before running any deletes. Then, for each confirmed item, run the appropriate delete command and echo it:

   ```bash
   # Delete a stopped instance
   vultr-cli instance delete <instance-id>

   # Delete an unattached block storage volume
   vultr-cli block-storage delete <block-storage-id>

   # Delete an idle reserved IP
   vultr-cli reserved-ip delete <reserved-ip-id>

   # Delete an old snapshot
   vultr-cli snapshot delete <snapshot-id>

   # Delete an empty load balancer
   vultr-cli load-balancer delete <lb-id>
   ```

   The safety hook will warn on each destructive call.

5. After deletes, re-run `vultr-cli account info` and the relevant list commands to confirm resources are gone and report estimated monthly savings.

**Rules:**
- Never delete in bulk without per-category confirmation.
- If unsure whether a resource is truly orphaned (e.g., a snapshot with no description), flag it for the user rather than deleting it.
- Remind the user that all deletes are irreversible — Vultr does not have a recycle bin.
