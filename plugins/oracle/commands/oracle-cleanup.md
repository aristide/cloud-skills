---
name: oracle-cleanup
description: Find orphaned and idle Oracle Cloud Infrastructure (OCI) resources that still bill and help clean them up safely
---

Find OCI resources that are likely wasting money and help the user remove them — carefully, one category at a time.

## Steps

1. Confirm authentication and the active region (see the `oracle-setup` skill):
   ```bash
   oci iam region list --output table
   ```
   Ask for the target **compartment OCID** (or `$OCI_COMPARTMENT`). Confirm before scanning.

2. Scan for common sources of idle spend. Run all of the following and collect the results:

   **STOPPED compute instances** — compute billing stops when stopped, but boot/block volumes keep billing:
   ```bash
   oci compute instance list \
     --compartment-id <compartment-ocid> \
     --lifecycle-state STOPPED \
     --query 'data[].{name:"display-name",id:"id",shape:shape,ad:"availability-domain"}' \
     --output table
   ```

   **Unattached block volumes** — `AVAILABLE` volumes with no instance attachment:
   ```bash
   oci bv volume list \
     --compartment-id <compartment-ocid> \
     --lifecycle-state AVAILABLE \
     --query 'data[].{name:"display-name",id:"id",gb:"size-in-gbs",vpus:"vpus-per-gb"}' \
     --output table
   ```
   Cross-check attachments: `oci compute volume-attachment list --compartment-id <compartment-ocid>`

   **Orphaned boot volumes** — boot volumes that remain after an instance was terminated:
   ```bash
   oci bv boot-volume list \
     --compartment-id <compartment-ocid> \
     --availability-domain <AD-name> \
     --query 'data[].{name:"display-name",id:"id",gb:"size-in-gbs",state:"lifecycle-state"}' \
     --output table
   ```

   **Reserved public IPs not assigned to any resource**:
   ```bash
   oci network public-ip list \
     --compartment-id <compartment-ocid> \
     --scope REGION \
     --lifetime RESERVED \
     --query 'data[?!"assigned-entity-id"].{name:"display-name",id:"id",ip:"ip-address"}' \
     --output table
   ```
   Reserved IPs with no `assigned-entity-id` bill while idle.

   **Old block volume backups** — list all and flag ones older than 30 days:
   ```bash
   oci bv backup list \
     --compartment-id <compartment-ocid> \
     --query 'data[].{name:"display-name",id:"id",gb:"size-in-gbs",type:"type",created:"time-created"}' \
     --output table
   ```

   **Old boot volume backups**:
   ```bash
   oci bv boot-volume-backup list \
     --compartment-id <compartment-ocid> \
     --query 'data[].{name:"display-name",id:"id",created:"time-created"}' \
     --output table
   ```

3. Present findings grouped by category. For each item include: name, OCID (truncated), size/cost signal, and why it is wasteful (e.g. "100 GB block volume — AVAILABLE, no attachment found"). **Do not delete anything yet.**

   Key billing reminders to surface:
   - A STOPPED instance saves compute cost but its **boot volume keeps billing** (at block storage rates per GB).
   - An AVAILABLE block volume bills at its provisioned size regardless of attachment.
   - A reserved public IP bills ~$0.004/hour while unassigned.
   - Backups bill at compressed object-storage rates but accumulate over time.

4. Ask the user which categories or specific items to remove. When unsure whether something is truly orphaned (e.g. a boot volume with a non-obvious name), **flag it for review** rather than deleting.

5. Only after explicit per-category confirmation, run deletes one at a time, echoing each command:

   ```bash
   # Terminate a STOPPED instance (optionally deleting its boot volume)
   oci compute instance terminate \
     --instance-id <instance-ocid> \
     --preserve-boot-volume false

   # Delete an unattached block volume
   oci bv volume delete --volume-id <volume-ocid>

   # Delete an orphaned boot volume
   oci bv boot-volume delete --boot-volume-id <boot-volume-ocid>

   # Release a reserved public IP
   oci network public-ip delete --public-ip-id <public-ip-ocid>

   # Delete an old block volume backup
   oci bv backup delete --volume-backup-id <backup-ocid>

   # Delete an old boot volume backup
   oci bv boot-volume-backup delete --boot-volume-backup-id <boot-backup-ocid>
   ```

   Pause between categories and confirm before proceeding to the next.

6. After cleanup, re-run the scan queries to confirm the resources are gone or in a `TERMINATING` state.

Never bulk-delete without per-category confirmation. If a resource name or tag suggests it may be in use (e.g. tagged `env:prod`, recently attached, or created within the last 24 hours), surface it as a warning rather than a candidate for immediate deletion.
