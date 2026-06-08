---
name: linode-status
description: Show an overview of Linode resources in the active account
---

Show a concise overview of the active Linode account's infrastructure.

## Steps

1. Confirm the active account/user:
   ```bash
   linode-cli account view
   linode-cli show-active-user
   ```

2. List core resources (skip any that error or return empty):
   - Linodes:
     ```bash
     linode-cli linodes list --text --format "id,label,status,ipv4,region,type" --no-headers
     ```
   - Volumes: `linode-cli volumes list --text --format "id,label,size,status,linode_id" --no-headers`
   - NodeBalancers: `linode-cli nodebalancers list --text --format "id,label,region,ipv4" --no-headers`
   - Domains: `linode-cli domains list --text --format "id,domain,type" --no-headers`
   - SSH keys: `linode-cli sshkeys list --text --format "id,label" --no-headers`

3. Present a concise summary highlighting:
   - Linode counts by status (skip statuses with zero)
   - Linodes that are `offline` but still billing (a powered-off Linode still bills)
   - Volumes not attached to a Linode (`linode_id` empty)
   - Anything in a `provisioning`/`rebuilding`/error state

Run the list commands and summarize. If not configured, point the user to the `linode-setup` skill (`linode-cli configure`). Note: shutting a Linode down does **not** stop billing — only deleting it does.
