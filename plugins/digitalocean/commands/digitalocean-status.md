---
name: digitalocean-status
description: Show an overview of DigitalOcean resources in the active account
---

Show a concise overview of the active DigitalOcean account's infrastructure.

## Steps

1. Confirm the active account/context:
   ```bash
   doctl account get
   doctl auth list
   ```

2. List core resources (skip any that error or return empty):
   - Droplets:
     ```bash
     doctl compute droplet list --format ID,Name,PublicIPv4,Region,Status,Memory,Disk --no-header
     ```
   - Volumes: `doctl compute volume list --format ID,Name,Size,Region,DropletIDs --no-header`
   - Reserved IPs: `doctl compute reserved-ip list`
   - Load balancers: `doctl compute load-balancer list --format ID,Name,Status,IP --no-header`
   - SSH keys: `doctl compute ssh-key list --format ID,Name --no-header`
   - Kubernetes clusters: `doctl kubernetes cluster list`

3. Present a concise summary highlighting:
   - Droplet counts by status (skip statuses with zero)
   - Droplets that are `off` but still billing (DigitalOcean bills powered-off Droplets)
   - Volumes not attached to any Droplet (`DropletIDs` empty)
   - Reserved IPs not assigned to a Droplet (these bill while idle)
   - Anything in an error/new state

Run the list commands and summarize. If not authenticated, point the user to the `digitalocean-setup` skill (`doctl auth init`). Note: powering a Droplet off does **not** stop billing — only deleting it does.
