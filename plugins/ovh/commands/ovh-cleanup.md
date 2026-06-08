---
name: ovh-cleanup
description: Find orphaned/idle OVHcloud Public Cloud resources that still bill and help clean them up
---

Find OVHcloud Public Cloud resources that are likely wasting money, and help the user remove them carefully.

## Steps

1. Confirm authentication and the active project/region (see the `ovh-setup` skill):
   ```bash
   openstack token issue -f value -c project_id
   echo "region: $OS_REGION_NAME"
   ```
   Remind the user that each OVH region is a separate endpoint — repeat with a different `OS_REGION_NAME` to cover multiple regions.

2. Scan for common sources of idle spend. Run each command and collect the results:

   **Stopped instances (SHUTOFF) — still billing**
   ```bash
   openstack server list --status SHUTOFF --long
   ```
   On OVH Public Cloud, a stopped instance keeps billing at the full hourly rate. Only deleting it stops charges.

   **Instances in ERROR or stuck in BUILD**
   ```bash
   openstack server list --status ERROR
   openstack server list --status BUILD
   ```

   **Unattached block volumes (`available` status) — still billing**
   ```bash
   openstack volume list --status available
   ```

   **Unassociated floating IPs — still billing**
   ```bash
   openstack floating ip list
   ```
   Flag any floating IP where the `Fixed IP Address` and `Port` columns are empty — those are unattached and billing.

   **Old volume snapshots — accumulate cost**
   ```bash
   openstack volume snapshot list
   ```

   **Unused load balancers**
   ```bash
   openstack loadbalancer list
   ```
   Flag any load balancer with zero members or in `ERROR` state.

   **Old custom images**
   ```bash
   openstack image list --private
   ```

3. Present the findings grouped by type. For each item include its name/ID, size or type where relevant, and the reason it is wasteful. Example format:

   - **SHUTOFF server** `my-old-server` (b3-8, 30 days stopped) — billing at full rate; delete to stop charges
   - **Unattached volume** `data-vol-2` (100 GB, status: available) — billing with no instance using it
   - **Unassociated floating IP** `51.x.x.x` — billing while idle
   - **Snapshot** `snap-2024-01` (50 GB, 180 days old) — review if still needed

   Do **not** delete anything at this stage.

4. Ask the user which categories or specific items to remove. Only after explicit per-category confirmation, run deletes one item at a time, echoing each command:

   ```bash
   # Delete a stopped server (irreversible)
   openstack server delete <name-or-id>

   # Delete an unattached volume (irreversible)
   openstack volume delete <name-or-id>

   # Release an unassociated floating IP
   openstack floating ip delete <floating-ip>

   # Delete a snapshot
   openstack volume snapshot delete <name-or-id>

   # Delete a load balancer and all its sub-resources
   openstack loadbalancer delete --cascade <name-or-id>

   # Delete a private image
   openstack image delete <image-id>
   ```

5. After each category's deletes complete, re-run the relevant list command to confirm the items are gone.

Never delete in bulk without per-category confirmation. If something looks ambiguous (e.g. a volume whose server was recently deleted), flag it for the user to verify rather than removing it automatically.
