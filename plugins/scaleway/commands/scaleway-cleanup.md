---
name: scaleway-cleanup
description: Find orphaned or idle Scaleway resources that still bill and help clean them up safely
---

Find Scaleway resources that are likely wasting money and help the user remove them — carefully, one category at a time.

## Steps

1. Confirm authentication and the active project:
   ```bash
   scw config info
   ```
   If multiple zones are in use, repeat the scans below for each zone (`zone=nl-ams-1`, `zone=pl-waw-1`, etc.).

2. Scan for common sources of idle spend. Run all of these and collect the results before taking any action:

   **Stopped Instances (still bill for the server reservation and local volumes)**
   ```bash
   scw instance server list zone=fr-par-1 -o table=ID,Name,State,Type,Zone
   # Look for State=stopped — stopped Instances continue billing
   ```

   **Detached Block Storage volumes (bill regardless of attachment)**
   ```bash
   scw block volume list zone=fr-par-1 -o table=ID,Name,Size,Status
   # A volume with no server reference is detached and still billing
   ```

   **Detached Instance volumes (l_ssd / b_ssd — legacy)**
   ```bash
   scw instance volume list zone=fr-par-1 -o table=ID,Name,Size,ServerID
   # Empty ServerID = unattached
   ```

   **Unattached flexible (public) IPs (bill while unattached)**
   ```bash
   scw instance ip list zone=fr-par-1 -o table=ID,Address,ServerID
   # Empty ServerID = idle, billing
   ```

   **Old Block Storage snapshots**
   ```bash
   scw block snapshot list zone=fr-par-1 -o table=ID,Name,Size,CreatedAt
   # Old/forgotten snapshots from deleted volumes accumulate cost
   ```

   **Old Instance snapshots**
   ```bash
   scw instance snapshot list zone=fr-par-1 -o table=ID,Name,Size,CreatedAt
   ```

   **Empty or unused Load Balancers**
   ```bash
   scw lb lb list region=fr-par -o table=ID,Name,Status
   # A running LB with no backends attached bills continuously
   ```

   **Unused Kubernetes clusters**
   ```bash
   scw k8s cluster list region=fr-par -o table=ID,Name,Status,Version
   # Idle or test clusters still bill for control plane + node pool Instances
   ```

   **Unused Serverless Container / Function namespaces**
   ```bash
   scw container namespace list region=fr-par -o table=ID,Name,Region
   scw function namespace list  region=fr-par -o table=ID,Name,Region
   ```

3. Present the findings grouped by type. For each item include: resource ID, name, size/type, and the reason it is wasteful (e.g. "volume `vol-abc` — 100 GB, detached since creation", "IP `1.2.3.4` — unattached, ~€0.004/hr"). **Do not delete anything yet.**

4. Ask the user which categories or specific items to remove. Once they confirm a category, run the deletes one item at a time and echo each command:

   ```bash
   # Delete a stopped server (add with-volumes=all with-ip=true to remove its storage too)
   scw instance server delete <server-id> with-volumes=all with-ip=true zone=fr-par-1

   # Delete a detached Block volume
   scw block volume delete <volume-id> zone=fr-par-1

   # Delete a detached Instance volume
   scw instance volume delete <volume-id> zone=fr-par-1

   # Release an unattached flexible IP
   scw instance ip delete <ip-id> zone=fr-par-1

   # Delete a Block snapshot
   scw block snapshot delete <snapshot-id> zone=fr-par-1

   # Delete an Instance snapshot
   scw instance snapshot delete <snapshot-id> zone=fr-par-1

   # Delete a Load Balancer
   scw lb lb delete <lb-id> region=fr-par

   # Delete a Kubernetes cluster (add with-block-volumes=true to also remove PVs)
   scw k8s cluster delete <cluster-id> with-block-volumes=true region=fr-par
   ```

5. After each category is cleared, re-run the relevant list command to confirm the items are gone.

Never delete in bulk without per-category confirmation. When unsure whether something is truly orphaned (e.g. a stopped server that may be intentionally hibernated), flag it for the user rather than removing it. All deletes are **irreversible**.
