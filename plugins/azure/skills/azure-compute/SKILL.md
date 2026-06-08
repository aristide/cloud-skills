---
name: azure-compute
description: "Use when the user needs to create, list, inspect, start, stop, deallocate, restart, resize, or delete Azure Virtual Machines, manage VM sizes/images, or open ports and get a VM's IP."
---

# Azure Virtual Machines

All commands are `az vm ...`. VMs live in a resource group; pass `--resource-group/-g` (or set a default — see the `azure-setup` skill).

## VM Lifecycle

### Create a VM

```bash
az vm create \
  --resource-group <rg> \
  --name <vm-name> \
  --image <image> \
  --size <size> \
  --admin-username <user> \
  --generate-ssh-keys
```

Common flags:
- `--image <urn|alias>` - e.g. `Ubuntu2204`, `Debian12`, or a full URN (required)
- `--size <size>` - e.g. `Standard_B1s`, `Standard_D2s_v5` (default `Standard_DS1_v2`)
- `--admin-username <user>` - Admin/login user
- `--generate-ssh-keys` - Create/reuse `~/.ssh/id_rsa` and inject the public key
- `--ssh-key-values <path-or-key>` - Use a specific public key
- `--admin-password <pw>` - Password auth (Windows, or Linux with `--authentication-type password`)
- `--location <region>` - Override location
- `--vnet-name` / `--subnet` - Place in an existing network
- `--public-ip-address ""` - Create without a public IP
- `--nsg <name>` - Network security group (firewall)
- `--custom-data <cloud-init-file>` - Bootstrap script
- `--tags key=value` - Tags
- `--no-wait` - Don't block on provisioning

### List / Show VMs

```bash
az vm list -o table
az vm list -g <rg> -o table
az vm show -g <rg> -n <vm-name>
```

Include live power state:

```bash
az vm list -d -o table          # -d / --show-details adds powerState + public IP
az vm get-instance-view -g <rg> -n <vm-name> \
  --query 'instanceView.statuses[?starts_with(code, `PowerState`)].displayStatus' -o tsv
```

## Power Management

```bash
az vm start      -g <rg> -n <vm-name>
az vm stop       -g <rg> -n <vm-name>     # stops the OS; compute MAY still bill
az vm deallocate -g <rg> -n <vm-name>     # stops AND releases compute — stops compute billing
az vm restart    -g <rg> -n <vm-name>
```

Important: only `deallocate` stops compute billing. A plain `stop` can leave the VM allocated and still charged. Disks/IPs continue to bill in both cases.

### Delete (destroy)

```bash
az vm delete -g <rg> -n <vm-name> --yes
```

`az vm delete` removes the VM but may leave NIC, disk, public IP, and NSG behind. To remove everything, delete the resource group instead:

```bash
az group delete --name <rg> --yes
```

## Resize

```bash
az vm list-vm-resize-options -g <rg> -n <vm-name> -o table
az vm resize -g <rg> -n <vm-name> --size Standard_D2s_v5
```

## Access

### Get the public IP

```bash
az vm list-ip-addresses -g <rg> -n <vm-name> \
  --query '[0].virtualMachine.network.publicIpAddresses[0].ipAddress' -o tsv
```

### SSH

No built-in connect for plain VMs — use the IP and key:

```bash
ssh <admin-username>@<public-ip>
```

For private VMs without a public IP, use Azure Bastion or `az ssh`:

```bash
az ssh vm -g <rg> -n <vm-name>    # requires the ssh extension + Azure AD login
```

### Open a port (quick NSG rule)

```bash
az vm open-port -g <rg> -n <vm-name> --port 80 --priority 900
```

### Run a command in the VM (no SSH)

```bash
az vm run-command invoke -g <rg> -n <vm-name> \
  --command-id RunShellScript --scripts "uname -a"
```

## Images and Sizes

```bash
az vm image list --output table                       # popular aliases
az vm image list --all --publisher Canonical -o table # full catalog (slow)
az vm list-sizes --location westeurope -o table
```

## Beyond Compute

For networking (`az network`), disks (`az disk`), load balancers (`az network lb`), AKS (`az aks`), storage (`az storage`), and identity (`az role`/`az ad`), use the same `az <group> <command>` pattern; run `az <group> --help` for subcommands. This skill focuses on core VM compute; broader coverage can be added as additional skills.
