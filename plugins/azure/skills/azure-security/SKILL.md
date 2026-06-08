---
name: azure-security
description: "Use when the user needs to manage Azure security — SSH keys, Key Vault certificates, RBAC role assignments, service principals, and resource tags."
---

# Azure Security

Azure security spans several CLI command groups: `az sshkey`, `az keyvault`, `az role`, `az ad`, and resource-level `--tags` flags.

## SSH Keys

Azure can store SSH public keys as first-class resources and inject them into VMs at creation time.

```bash
# Generate a new key pair and store the public key in Azure
az sshkey create \
  --resource-group <rg> \
  --name <key-name> \
  --location <region>
# The private key is written locally; the public key is stored in Azure.

# Import an existing public key
az sshkey create \
  --resource-group <rg> \
  --name <key-name> \
  --public-key "$(cat ~/.ssh/id_rsa.pub)"

# List stored keys
az sshkey list -g <rg> -o table

# Show a key (including the public key value)
az sshkey show -g <rg> -n <key-name>

# Delete a key resource (does not affect VMs already using it)
az sshkey delete -g <rg> -n <key-name> --yes
```

Reference the key when creating a VM with `--ssh-key-name <key-name>`.

## Key Vault — Secrets, Keys, and Certificates

Key Vault stores cryptographic keys, secrets, and TLS/SSL certificates.

### Create a Key Vault

```bash
az keyvault create \
  --resource-group <rg> \
  --name <vault-name> \
  --location <region>
```

Vault names must be globally unique and 3–24 alphanumeric/hyphen characters.

### Certificates

```bash
# Create a self-signed certificate using a default policy
az keyvault certificate create \
  --vault-name <vault-name> \
  --name <cert-name> \
  --policy "$(az keyvault certificate get-default-policy)"

# Import an existing PEM/PFX certificate
az keyvault certificate import \
  --vault-name <vault-name> \
  --name <cert-name> \
  --file ./certificate.pfx \
  --password <pfx-password>

# List certificates
az keyvault certificate list --vault-name <vault-name> -o table

# Download a certificate
az keyvault certificate download \
  --vault-name <vault-name> \
  --name <cert-name> \
  --file ./cert.pem \
  --encoding PEM

# Delete a certificate (moves to soft-delete state)
az keyvault certificate delete --vault-name <vault-name> -n <cert-name>
az keyvault certificate purge --vault-name <vault-name> -n <cert-name>  # permanent
```

### Secrets (for passwords, tokens, etc.)

```bash
az keyvault secret set --vault-name <vault-name> -n <secret-name> --value "<value>"
az keyvault secret list --vault-name <vault-name> -o table
az keyvault secret show --vault-name <vault-name> -n <secret-name> --query value -o tsv
az keyvault secret delete --vault-name <vault-name> -n <secret-name>
```

## RBAC — Role Assignments

Azure RBAC controls who can do what on which resources.

```bash
# List built-in roles
az role definition list --query '[].{name:roleName,desc:description}' -o table

# Assign a role to a user
az role assignment create \
  --assignee <user-email-or-object-id> \
  --role "Contributor" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>

# Assign to a resource group (shorthand)
az role assignment create \
  --assignee <user-email-or-object-id> \
  --role "Reader" \
  --resource-group <rg>

# List role assignments in a resource group
az role assignment list -g <rg> -o table

# Remove a role assignment
az role assignment delete \
  --assignee <user-email-or-object-id> \
  --role "Contributor" \
  --resource-group <rg>
```

## Service Principals

Service principals are app identities used for automation, CI/CD pipelines, or cross-resource access.

```bash
# Create a service principal with Contributor on a resource group
az ad sp create-for-rbac \
  --name <sp-name> \
  --role Contributor \
  --scopes /subscriptions/<sub-id>/resourceGroups/<rg>
# Outputs appId, password, tenant — save the password; it cannot be retrieved later.

# List service principals
az ad sp list --display-name <sp-name> -o table

# Reset credentials
az ad sp credential reset --id <app-id>

# Delete a service principal
az ad sp delete --id <app-id>
```

## Resource Tags

Tags are key-value pairs attached to any Azure resource for cost tracking, ownership, or environment labeling.

```bash
# Add tags at creation time (works on most az * create commands)
az vm create ... --tags env=prod owner=team-a

# Update tags on an existing resource
az tag update \
  --resource-id <resource-id> \
  --operation Merge \
  --tags env=prod owner=team-a

# List all tags on a resource
az tag list --resource-id <resource-id>

# Remove a specific tag key
az tag update \
  --resource-id <resource-id> \
  --operation Delete \
  --tags env=''

# Get the resource ID of a resource group
az group show -g <rg> --query id -o tsv
```

## Beyond the basics

Run `az keyvault --help`, `az role --help`, and `az ad --help` for the full subcommand lists. Advanced topics include managed identities (`az identity`), Key Vault access policies vs. RBAC (`az keyvault set-policy`), Conditional Access, and Microsoft Defender for Cloud (`az security`).
