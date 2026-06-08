---
name: contabo-cleanup
description: Find idle or orphaned Contabo resources that are still billing and help clean them up safely
---

Find Contabo resources that are likely wasting money and help the user remove them — carefully, one category at a time.

> **Critical Contabo billing rules:**
> - **Stopped instances still bill.** Powering off an instance does NOT end its contract — only `cntb cancel instance <id>` does.
> - **Object storage is a subscription.** An empty bucket still bills until cancelled with `cntb cancel objectStorage <id>`.
> - There is no plain "delete" for instances or object storages — termination is `cntb cancel`.

## Steps

1. Confirm authentication:
   ```bash
   cntb get instances -o json
   ```
   If this errors, stop and help the user authenticate.

2. Scan for idle/orphaned resources:

   **Instances that are stopped but still billing:**
   ```bash
   cntb get instances -o json
   # flag any with status "stopped" or "error" — they still bill until cancelled
   ```

   **Instances pending cancellation or in an error state:**
   ```bash
   cntb get instances -o json
   # look for status "cancelled" (may still be in wind-down period) or "error"
   ```

   **Object storages that are empty or unused:**
   ```bash
   cntb get objectStorages -o json
   # note each one's region, size, and creation date
   # empty buckets still bill — confirm with user if any look unused
   ```

   **Unused snapshots:**
   ```bash
   # For each instance ID found above:
   cntb get snapshots <instance-id> -o json
   # old snapshots accumulate and may incur storage costs
   ```

   **Unused custom images:**
   ```bash
   cntb get images -o json
   # filter for custom (non-standard) images; note large or old ones
   ```

   **Orphaned secrets:**
   ```bash
   cntb get secrets -o json
   # secrets whose referenced instance has been cancelled are safe to remove
   ```

3. Present findings grouped by type, for example:
   - "Instance `<id>` (`<name>`) — status: **stopped**, still billing, contract period ends `<date>`"
   - "Object storage `<id>` — 2 TB in EU, last modified unknown, still billing"
   - "Snapshot `<id>` on instance `<id>` — created 6 months ago"
   - "Secret `<id>` (`<name>`) — no active instance references found"

   Do **not** cancel or delete anything yet.

4. Ask the user which items to remove. Explain the irreversibility for each type:
   - Cancelling an instance ends the subscription and destroys all data. There is no undo.
   - Cancelling object storage destroys all stored objects. There is no undo.
   - Deleting a snapshot removes that restore point permanently.

5. After explicit per-category confirmation, run cancellations/deletions one at a time, echoing each command:

   **Cancel an instance (terminates subscription, destroys data):**
   ```bash
   cntb cancel instance <instance-id>
   ```

   **Cancel object storage (terminates subscription, destroys all objects):**
   ```bash
   cntb cancel objectStorage <objectStorage-id>
   ```

   **Delete a snapshot:**
   ```bash
   cntb delete snapshot <instance-id> <snapshot-id>
   ```

   **Delete a custom image:**
   ```bash
   cntb delete image <image-id>
   ```

   **Delete an unused secret:**
   ```bash
   cntb delete secret <secret-id>
   ```

Never cancel in bulk without per-item or per-category explicit confirmation. When unsure whether something is truly orphaned, flag it for the user rather than cancelling it. If in doubt about billing periods or end dates, direct the user to the Contabo Customer Control Panel for contract details.
