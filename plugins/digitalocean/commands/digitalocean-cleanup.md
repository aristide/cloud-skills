---
name: digitalocean-cleanup
description: Find orphaned/idle DigitalOcean resources that still bill and help clean them up
---

Find DigitalOcean resources that are likely wasting money and help the user remove them — carefully.

## Steps

1. Confirm authentication and the active account:
   ```bash
   doctl account get
   doctl auth list
   ```
   If not authenticated, point the user to the `digitalocean-setup` skill.

2. Scan for common sources of idle spend, running each command and collecting results:

   - **Powered-off Droplets** — DigitalOcean bills for powered-off Droplets at the full hourly rate. Only deletion stops charges:
     ```bash
     doctl compute droplet list --format ID,Name,PublicIPv4,Region,Status,Memory --no-header | grep -i "off"
     ```

   - **Unattached block volumes** — Volumes not attached to any Droplet still bill per GB-month:
     ```bash
     doctl compute volume list --format ID,Name,Size,Region,DropletIDs --no-header
     ```
     Flag any rows where `DropletIDs` is empty.

   - **Unassigned reserved IPs** — A reserved IP not assigned to a Droplet incurs a small hourly charge:
     ```bash
     doctl compute reserved-ip list
     ```
     Flag any IPs where the `DropletID` column is blank.

   - **Old snapshots** — Snapshots bill per GB-month; old or forgotten snapshots accumulate silently:
     ```bash
     doctl compute snapshot list --resource-type droplet
     doctl compute snapshot list --resource-type volume
     ```

   - **Load balancers with no healthy Droplets** — Empty load balancers still bill hourly:
     ```bash
     doctl compute load-balancer list --format ID,Name,Status,IP,DropletIDs --no-header
     ```
     Flag any with empty `DropletIDs`.

   - **Kubernetes clusters** — DOKS clusters bill for worker nodes even when idle:
     ```bash
     doctl kubernetes cluster list --format ID,Name,Region,Status,NodePools --no-header
     ```

3. Present the findings grouped by resource type, with the reason each is wasteful (e.g. "Volume `data-01` — 100 GiB, no attached Droplet"). Do **not** delete anything yet.

4. Ask the user which items to remove. Only after explicit confirmation per category, run the deletes and echo each command:

   ```bash
   # Example deletes — always confirm with the user first
   doctl compute droplet delete <id> --force
   doctl compute volume delete <volume-id> --force
   doctl compute reserved-ip delete <ip>
   doctl compute snapshot delete <snapshot-id>
   doctl compute load-balancer delete <lb-id>
   doctl kubernetes cluster delete <cluster-id>
   ```

5. After each batch of deletes, re-run the relevant list command to confirm the resources are gone.

Never delete in bulk without per-category confirmation. When unsure whether a resource is truly orphaned (e.g. a volume with no current Droplet but clearly named after an active service), flag it for the user rather than removing it. The safety hook will also warn on each destructive call.
