---
name: azure-status
description: Show an overview of Azure resources in the active subscription
---

Show a concise overview of the active Azure subscription's infrastructure.

## Steps

1. Confirm the active account and subscription:
   ```bash
   az account show --query '{name:name,id:id,user:user.name}' -o table
   ```

2. List core resources (skip any that error or return empty):
   - Resource groups: `az group list -o table`
   - Virtual machines (with power state + IP):
     ```bash
     az vm list -d --query '[].{name:name,rg:resourceGroup,size:hardwareProfile.vmSize,power:powerState,ip:publicIps}' -o table
     ```
   - Managed disks: `az disk list --query '[].{name:name,rg:resourceGroup,size:diskSizeGb,state:diskState}' -o table`
   - Public IPs: `az network public-ip list --query '[].{name:name,ip:ipAddress,assoc:ipConfiguration.id}' -o table`
   - Load balancers: `az network lb list --query '[].{name:name,rg:resourceGroup}' -o table`

3. Present a concise summary highlighting:
   - VM counts by power state (skip states with zero)
   - VMs that are **stopped but not deallocated** (still incurring compute cost)
   - Unattached disks (`diskState` = `Unattached`)
   - Public IPs not associated with anything (these bill while idle)
   - Empty resource groups and anything in a failed/error state

Run the list commands and summarize. If not signed in, point the user to the `azure-setup` skill (`az login`, `az account set`).
