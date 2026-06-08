---
name: scaleway-status
description: Show an overview of Scaleway resources in the active project
---

Show a concise overview of the active Scaleway project's infrastructure.

## Steps

1. Confirm the active configuration (profile, project, default zone):
   ```bash
   scw config info
   ```

2. List core resources (skip any that error or return empty). Default zone is used unless you append `zone=<zone>`:
   - Instances:
     ```bash
     scw instance server list -o table=ID,Name,State,PublicIP,Type,Zone
     ```
   - Volumes: `scw instance volume list -o table=ID,Name,State,Size,ServerName`
   - Flexible IPs: `scw instance ip list -o table=ID,Address,ServerID`
   - Load balancers: `scw lb lb list -o table=ID,Name,Status`
   - Kubernetes clusters: `scw k8s cluster list -o table=ID,Name,Status,Version`

3. Present a concise summary highlighting:
   - Instance counts by state (skip states with zero)
   - Stopped instances whose volumes still bill
   - Volumes not attached to any server (`ServerName` empty)
   - Flexible IPs not attached to a server (`ServerID` empty — these bill while idle)
   - Anything in an error/transient state

Run the list commands and summarize. If not initialized, point the user to the `scaleway-setup` skill (`scw init`). Repeat key lists across other zones (`zone=nl-ams-1`, `zone=pl-waw-1`) if the user operates in multiple zones.
