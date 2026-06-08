---
name: azure-deploy
description: Guided interactive deployment of an Azure Virtual Machine with smart defaults
---

Guide the user through deploying an Azure VM, asking only for what's needed and filling sensible defaults.

## Steps

1. Confirm authentication and the active subscription:
   ```bash
   az account show --query '{name:name,id:id,user:user.name}' -o table
   ```
   If not signed in, stop and point the user to the `azure-setup` skill (`az login`, `az account set`).

2. Confirm or create a resource group:
   ```bash
   az group list -o table
   # Create one if needed:
   az group create --name <rg> --location <region>
   ```

3. Gather choices, offering defaults and listing options where useful:

   - **Location/region** — show available locations if the user is unsure:
     ```bash
     az account list-locations --query '[].{name:name,display:displayName}' -o table
     ```

   - **VM size** — default to `Standard_B2s` (cheap, general-purpose); list options for a region:
     ```bash
     az vm list-sizes --location <region> -o table
     ```

   - **Image/OS** — default to current Ubuntu LTS (`Ubuntu2204`); show popular aliases:
     ```bash
     az vm image list -o table    # popular aliases, no API call
     ```

   - **SSH key** — list existing Azure-stored keys; offer to create or import one (see `azure-security`):
     ```bash
     az sshkey list -g <rg> -o table
     # Create a new key pair if needed:
     az sshkey create -g <rg> --name <key-name>
     ```

   - **VM name** — ask the user; suggest a short, lowercase kebab-case name.

   - **Tags** — offer `env=dev owner=<user>` as a default.

4. Show the exact command that will be run and ask for confirmation before executing:
   ```bash
   az vm create \
     --resource-group <rg> \
     --name <vm-name> \
     --image Ubuntu2204 \
     --size Standard_B2s \
     --admin-username azureuser \
     --ssh-key-name <key-name> \
     --location <region> \
     --tags env=dev owner=<user>
   ```

5. Create the VM, wait for it to become ready, then report the public IP and SSH command:
   ```bash
   az vm list-ip-addresses -g <rg> -n <vm-name> \
     --query '[0].virtualMachine.network.publicIpAddresses[0].ipAddress' -o tsv
   # SSH:
   # ssh azureuser@<public-ip>
   ```

6. Offer logical follow-ups:
   - Open a port: `az vm open-port -g <rg> -n <vm-name> --port 80` (see `azure-networking`)
   - Attach a data disk (see `azure-storage`)
   - Create a DNS record pointing to the public IP (see `azure-dns`)
   - Apply RBAC or tags (see `azure-security`)

Keep it conversational — never destroy or overwrite anything as part of "deploy".
