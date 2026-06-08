---
name: vultr-status
description: Show an overview of Vultr resources in the active account
---

Show a concise overview of the active Vultr account's infrastructure.

## Steps

1. Confirm the account:
   ```bash
   vultr-cli account info
   ```

2. List core resources (skip any that error or return empty):
   - Instances: `vultr-cli instance list`
   - Block storage: `vultr-cli block-storage list`
   - Reserved IPs: `vultr-cli reserved-ip list`
   - Load balancers: `vultr-cli load-balancer list`
   - SSH keys: `vultr-cli ssh-key list`
   - Snapshots: `vultr-cli snapshot list`

3. Present a concise summary highlighting:
   - Instance counts by status/power state (skip those with zero)
   - Stopped instances (these **still bill** on Vultr until deleted)
   - Block storage not attached to an instance
   - Reserved IPs not attached to anything (these bill while idle)
   - Anything in a pending/installing state

Run the list commands and summarize. If unauthenticated, point the user to the `vultr-setup` skill (`VULTR_API_KEY` / `~/.vultr-cli.yaml`, and ensure the caller IP is on the API access control list). Note: stopping a Vultr instance does **not** stop billing — only deleting it does.
