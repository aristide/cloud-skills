---
name: ovh-security
description: "Use when the user needs to manage OVHcloud Public Cloud security — SSH keypairs, OpenStack identity roles and role assignments, application credentials for non-interactive auth, and resource metadata/tags."
---

# OVHcloud Public Cloud Security (OpenStack)

OVH Public Cloud security is handled through OpenStack Keystone (identity) and Nova (keypairs). Ensure your `OS_*` credentials/region are set (see the `ovh-setup` skill). Security groups (firewall rules) are covered in the `ovh-networking` skill.

## SSH Keypairs

Keypairs are stored in Nova and injected into instances at creation time via cloud-init.

```bash
# Import an existing public key
openstack keypair create --public-key ~/.ssh/id_ed25519.pub my-key

# Generate a new keypair and save the private key locally (OpenStack generates it)
openstack keypair create my-key > my-key.pem
chmod 600 my-key.pem

# List keypairs
openstack keypair list

# Show a keypair (fingerprint and public key)
openstack keypair show my-key

# Delete a keypair (does not affect already-running instances)
openstack keypair delete my-key
```

Use `--key-name my-key` when running `openstack server create` to inject the key.

## Application Credentials

Application credentials let scripts and CI pipelines authenticate without a username/password. They are scoped to a project and can have a subset of roles.

```bash
# Create an application credential (stores secret only on creation — copy it now)
openstack application credential create my-app-cred \
  --description "CI pipeline for project X"

# Create with restricted roles
openstack application credential create my-app-cred \
  --role member --description "read-only automation"

# Set an expiry
openstack application credential create my-app-cred \
  --expiration "2026-12-31T00:00:00"

# List application credentials
openstack application credential list

# Show details (secret is not re-displayed)
openstack application credential show my-app-cred

# Delete an application credential
openstack application credential delete my-app-cred
```

To use an application credential, set these env vars instead of `OS_USERNAME`/`OS_PASSWORD`:

```bash
export OS_AUTH_TYPE=v3applicationcredential
export OS_APPLICATION_CREDENTIAL_ID=<id>
export OS_APPLICATION_CREDENTIAL_SECRET=<secret>
```

## Identity: Users, Roles, and Role Assignments

On OVH Public Cloud, users and project membership are managed in the OVH control panel (or via the OVH API). The OpenStack client can list and inspect roles and assignments:

```bash
# List available roles in the project
openstack role list

# List role assignments in the current project
openstack role assignment list --project <project-id>

# Show roles for a specific user
openstack role assignment list --user <user-id> --project <project-id>
```

Granting or revoking roles on OVH Public Cloud is done through the OVH control panel under "Public Cloud > Users & Roles", not via the OpenStack client directly.

## Resource Metadata / Properties (Tags)

OpenStack does not have a universal tag API; metadata is set as properties on individual resource types.

```bash
# Set metadata on a server
openstack server set --property env=production --property owner=devops <server>

# Show server properties
openstack server show <server> -c properties

# Set metadata on a volume
openstack volume set --property env=production <volume>

# Set metadata on an image
openstack image set --property team=platform <image-id>
```

## TLS Certificates (Barbican / Octavia)

OVH Public Cloud supports TLS termination on load balancers via Octavia. Certificates can be stored in OpenStack Barbican (Key Manager) if enabled, or passed inline. Check availability in your region:

```bash
openstack secret list       # Barbican — may not be enabled in all OVH regions
```

For HTTPS load balancer listeners, upload the cert to Barbican first, then reference the secret URI when creating the Octavia listener with `--protocol TERMINATED_HTTPS`.

## Beyond the basics

Run `openstack keypair --help`, `openstack application credential --help`, or `openstack role --help` for full options. For MFA and advanced IAM, use the OVH control panel or the OVH API directly.
