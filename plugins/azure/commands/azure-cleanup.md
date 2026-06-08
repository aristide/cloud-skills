---
name: azure-cleanup
description: Find orphaned/idle Azure resources that still bill and help clean them up
---

Find Azure resources that are likely wasting money and help the user remove them — carefully.

## Steps

1. Confirm authentication and the active subscription:
   ```bash
   az account show --query '{name:name,id:id,user:user.name}' -o table
   ```
   If not signed in, point the user to the `azure-setup` skill.

2. Scan for common sources of idle spend (run each command, collect the results):

   - **VMs stopped but NOT deallocated** (still incurring compute charges):
     ```bash
     az vm list -d \
       --query "[?powerState=='VM stopped'].{name:name,rg:resourceGroup,size:hardwareProfile.vmSize,state:powerState}" \
       -o table
     ```
     A plain `az vm stop` stops the OS but may leave the VM allocated. Only `az vm deallocate` stops compute billing.

   - **Deallocated VMs** (compute free, but disks and public IPs still bill):
     ```bash
     az vm list -d \
       --query "[?powerState=='VM deallocated'].{name:name,rg:resourceGroup,size:hardwareProfile.vmSize,state:powerState}" \
       -o table
     ```

   - **Unattached managed disks** (still billed by size):
     ```bash
     az disk list \
       --query "[?diskState=='Unattached'].{name:name,rg:resourceGroup,sizeGb:diskSizeGb,sku:sku.name}" \
       -o table
     ```

   - **Unassociated public IP addresses** (Standard SKU IPs bill ~$3–5/month while idle):
     ```bash
     az network public-ip list \
       --query "[?ipConfiguration==null].{name:name,rg:resourceGroup,ip:ipAddress,sku:sku.name}" \
       -o table
     ```

   - **Old snapshots** (billed for stored data):
     ```bash
     az snapshot list \
       --query '[].{name:name,rg:resourceGroup,sizeGb:diskSizeGb,created:timeCreated}' \
       -o table
     ```

   - **Empty resource groups** (no cost, but clutter):
     ```bash
     az group list --query '[].name' -o tsv | while read rg; do
       count=$(az resource list -g "$rg" --query 'length(@)')
       [ "$count" = "0" ] && echo "$rg"
     done
     ```
     *(PowerShell equivalent: `az group list --query '[].name' -o tsv | ForEach-Object { if ((az resource list -g $_ --query 'length(@)' -o tsv) -eq 0) { $_ } }`)*

3. Present the findings grouped by type, noting the reason each wastes money (e.g. "disk my-old-disk — 128 GB, unattached since VM was deleted"). Do **not** delete anything yet.

4. Ask the user which categories or specific items to remove. Only after explicit per-category confirmation, run the deletes:

   ```bash
   # Deallocate a stopped VM (fixes compute billing without deleting)
   az vm deallocate -g <rg> -n <vm-name>

   # Delete a VM (leaves disks/NICs/IPs — clean up separately)
   az vm delete -g <rg> -n <vm-name> --yes

   # Delete an unattached disk
   az disk delete -g <rg> -n <disk-name> --yes

   # Delete an idle public IP
   az network public-ip delete -g <rg> -n <ip-name>

   # Delete a snapshot
   az snapshot delete -g <rg> -n <snapshot-name> --yes

   # Delete an empty resource group (removes ALL resources inside — confirm carefully)
   az group delete --name <rg> --yes
   ```

5. After deletes, re-run the relevant list commands to confirm the resources are gone. Remind the user that some deletions (e.g. Key Vault with soft-delete, ACR images) may need a purge step.

Never delete in bulk without per-category confirmation. When unsure whether something is truly orphaned (e.g. a stopped VM that may be intentionally paused), flag it for the user rather than removing it.
