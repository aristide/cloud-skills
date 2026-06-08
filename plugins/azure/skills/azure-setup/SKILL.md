---
name: azure-setup
description: "Use when the user needs to install, configure, or authenticate the Azure CLI (az), sign in, select a subscription, set default resource group/location, or control output format (json/table/tsv) for Azure commands."
---

# Azure CLI Setup and Configuration

The Azure CLI binary is `az`. Verify with `az version`.

## Installation

### macOS

```bash
brew install azure-cli
```

### Linux (Debian/Ubuntu)

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Windows

```powershell
winget install Microsoft.AzureCLI
```

## Authentication

### Interactive login

```bash
az login                       # opens a browser
az login --use-device-code     # headless / remote shells
```

### Service principal (automation / CI)

```bash
az login --service-principal \
  --username <app-id> \
  --password <client-secret-or-cert> \
  --tenant <tenant-id>
```

### Managed identity (on an Azure VM)

```bash
az login --identity
```

### Show signed-in account

```bash
az account show
```

## Subscriptions

A tenant can hold many subscriptions; commands run against the active one.

```bash
az account list --output table
az account set --subscription "<name-or-id>"
az account show --query id --output tsv
```

## Defaults (avoid repeating --resource-group / --location)

```bash
az configure --defaults group=my-rg location=westeurope
```

Set per-command instead with `--resource-group <rg>` / `--location <region>`.

List locations:

```bash
az account list-locations --query '[].name' --output tsv
```

## Resource Groups

Every resource belongs to a resource group.

```bash
az group create --name my-rg --location westeurope
az group list --output table
az group delete --name my-rg --yes --no-wait   # deletes ALL resources within
```

## Output Format

`--output` (`-o`) accepts `json` (default), `jsonc`, `table`, `tsv`, `yaml`, `none`.

```bash
az configure --defaults output=table
az vm list -o table
```

### Server-side shaping with --query (JMESPath)

```bash
az vm list --query '[].{name:name,rg:resourceGroup,size:hardwareProfile.vmSize}' -o table
```

### tsv for scripting

```bash
ip=$(az vm list-ip-addresses -n myvm -g my-rg \
  --query '[0].virtualMachine.network.publicIpAddresses[0].ipAddress' -o tsv)
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--subscription <id>` | Target a specific subscription |
| `--resource-group, -g <rg>` | Resource group (or set a default) |
| `--output, -o <fmt>` | json \| table \| tsv \| yaml \| none |
| `--query <expr>` | JMESPath expression to filter/shape output |
| `--no-wait` | Return immediately instead of polling the operation |
| `--verbose` / `--debug` | Increase logging |
