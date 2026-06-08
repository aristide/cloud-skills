---
name: scaleway-security
description: "Use when the user needs to manage Scaleway security — SSH keys, IAM users, applications, groups, policies and API keys, and resource tags."
---

# Scaleway Security

Security on Scaleway spans two main areas: **SSH keys** (used to access Instances) and **IAM** (Identity and Access Management) for controlling API access at the organization and project level. All IAM commands are `scw iam ...`; SSH key management is also under `scw iam`. Confirm exact flags with `scw iam --help`.

## SSH Keys

SSH keys are stored at the organization level and automatically injected into new Instances at boot time.

```bash
# List SSH keys
scw iam ssh-key list

# Add an SSH key (paste the full public key)
scw iam ssh-key create \
  name=my-laptop \
  public-key="ssh-ed25519 AAAA... user@host"

# Get details
scw iam ssh-key get <ssh-key-id>

# Disable an SSH key (stops it being injected into new servers)
scw iam ssh-key update <ssh-key-id> disabled=true

# Delete an SSH key
scw iam ssh-key delete <ssh-key-id>
```

To import a key from a file:

```bash
scw iam ssh-key create name=my-key public-key="$(cat ~/.ssh/id_ed25519.pub)"
```

## IAM Users and Invitations

```bash
# List users in the organization
scw iam user list

# Get a specific user
scw iam user get <user-id>

# Delete a user from the organization
scw iam user delete <user-id>
```

Inviting new users is done from the Scaleway console; the CLI manages existing members.

## IAM Applications (service accounts)

Applications are non-human principals used for programmatic access (CI/CD, automation):

```bash
# List applications
scw iam application list

# Create an application
scw iam application create name=my-app description="CI pipeline"

# Get details
scw iam application get <application-id>

# Delete an application
scw iam application delete <application-id>
```

## API Keys

API keys are scoped to either a user or an application:

```bash
# List API keys
scw iam api-key list

# Create an API key for an application
scw iam api-key create application-id=<application-id> description="prod key"

# Create an API key for a user
scw iam api-key create user-id=<user-id>

# Get details (secret key shown only at creation time)
scw iam api-key get <access-key>

# Delete an API key
scw iam api-key delete <access-key>
```

The secret key is shown only once at creation. Store it securely immediately.

## IAM Groups

Groups collect users and/or applications so a single policy can apply to all members:

```bash
scw iam group list
scw iam group create name=developers
scw iam group add-member <group-id> user-id=<user-id>
scw iam group add-member <group-id> application-id=<application-id>
scw iam group get <group-id>
scw iam group delete <group-id>
```

## IAM Policies

Policies attach permission sets to a principal (user, application, or group) scoped to the organization or a project:

```bash
# List policies
scw iam policy list

# Create a policy granting a group full Instances access in a project
scw iam policy create \
  name=dev-instances \
  group-id=<group-id> \
  rules.0.project-ids.0=<project-id> \
  rules.0.permission-set-names.0=InstancesFullAccess

# Create a policy scoped to the whole organization
scw iam policy create \
  name=org-read-only \
  user-id=<user-id> \
  rules.0.organization-id=<organization-id> \
  rules.0.permission-set-names.0=AllProductsRead

# Get / delete
scw iam policy get <policy-id>
scw iam policy delete <policy-id>
```

List available permission sets with:

```bash
scw iam permission-set list
```

## Resource Tags

Tags are set at resource creation or update time using the `tags.N=value` key-value syntax:

```bash
# Tag an Instance
scw instance server update <server-id> \
  tags.0=env:prod \
  tags.1=team:backend \
  zone=fr-par-1

# Tag a Block volume
scw block volume update <volume-id> \
  tags.0=env:prod \
  zone=fr-par-1
```

Tags are freeform strings; a `key:value` convention (e.g. `env:prod`) is recommended for filtering.

## Beyond the basics

Use `scw iam --help` for the complete list of resources and verbs. For Load Balancer TLS certificates, see the `scaleway-networking` skill (`scw lb certificate`). For Instance-level firewall rules, see the security groups section in `scaleway-networking`.
