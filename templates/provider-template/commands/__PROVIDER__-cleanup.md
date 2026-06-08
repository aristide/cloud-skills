---
name: __PROVIDER__-cleanup
description: Find orphaned/idle __PROVIDER_DISPLAY__ resources that still bill and help clean them up
---

Find __PROVIDER_DISPLAY__ resources that are likely wasting money, and help the user remove them — carefully.

## Steps

1. Confirm authentication and the active account/project/region (see the `__PROVIDER__-setup` skill).

2. Scan for common sources of idle spend (skip categories the provider doesn't have):
   - **Stopped instances that still bill** — `# __CLI__ <compute> list` filtered to stopped/off
   - **Unattached block volumes** — `# __CLI__ <volume> list` where not attached
   - **Unassociated public/floating/reserved IPs** — `# __CLI__ <ip> list` where unattached
   - **Old snapshots/images** — `# __CLI__ <snapshot/image> list`
   - **Empty load balancers / unused networks**

3. Present the findings grouped by type, with the estimated reason each is wasteful (e.g. "volume X — 100 GB, detached"). Do **not** delete anything yet.

4. Ask the user which items to remove. Only after explicit confirmation, run the deletes one category at a time, echoing each command. The safety hook will also warn on each destructive call.

Never delete in bulk without per-category confirmation. When unsure whether something is truly orphaned, flag it for the user rather than removing it.
