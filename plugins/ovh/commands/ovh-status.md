---
name: ovh-status
description: Show an overview of OVHcloud Public Cloud (OpenStack) resources in the active project
---

Show a concise overview of the active OVHcloud Public Cloud project (via the OpenStack client).

## Steps

1. Confirm credentials and the active project/region:
   ```bash
   openstack token issue -f value -c project_id
   echo "region: $OS_REGION_NAME"
   ```

2. List core resources (skip any that error or return empty):
   - Servers: `openstack server list --long`
   - Volumes: `openstack volume list`
   - Floating IPs: `openstack floating ip list`
   - Keypairs: `openstack keypair list`
   - Security groups: `openstack security group list`
   - Networks: `openstack network list`

3. Present a concise summary highlighting:
   - Server counts by status (skip statuses with zero)
   - `SHUTOFF` servers (these **still bill** on OVH Public Cloud until deleted)
   - Volumes with status `available` (not attached to a server)
   - Floating IPs not associated with a server (these bill while idle)
   - Anything in an `ERROR`/`BUILD` state

Run the list commands and summarize. If unauthenticated, point the user to the `ovh-setup` skill (source the OpenStack RC file or set `OS_*`). Each region is a separate OpenStack endpoint — re-run with a different `OS_REGION_NAME` to cover multiple OVH regions. Note: a stopped instance still bills; only deleting it stops charges.
