---
name: __PROVIDER__-status
description: Show an overview of __PROVIDER_DISPLAY__ resources in the active account/project
---

Show a concise overview of the active __PROVIDER_DISPLAY__ account's infrastructure.

## Steps

1. Confirm the active identity / project / location:
   ```bash
   # __CLI__ account show / config info
   ```

2. List core resources (skip any that error or return empty):
   - Compute instances: `# __CLI__ <compute> list`
   - Volumes/disks: `# __CLI__ <volumes> list`
   - Public IPs: `# __CLI__ <ips> list`
   - Load balancers: `# __CLI__ <lb> list`

3. Present a concise summary highlighting:
   - Instance counts by state (skip states with zero)
   - Stopped instances whose storage still bills
   - Unattached volumes
   - Idle/unassociated public IPs (these usually bill)
   - Anything in an error state

Run the list commands and summarize. If unauthenticated, point the user to the `__PROVIDER__-setup` skill.
