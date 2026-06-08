---
name: linode-security
description: "Use when the user needs to manage Linode security — SSH keys, account users and grants, resource tags, and TLS/SSL certificates (NodeBalancer inline certs)."
---

# Linode Security

All commands are `linode-cli <group> ...`. See the `linode-setup` skill for auth.

## SSH Keys

SSH keys stored in your Linode account profile can be injected into new Linodes at creation time.

```bash
# List saved SSH keys
linode-cli sshkeys list
linode-cli sshkeys list --text --format "id,label,created" --no-headers

# Add an SSH key from a local public key file
linode-cli sshkeys create \
  --label "my-laptop" \
  --ssh_key "$(cat ~/.ssh/id_ed25519.pub)"

# View a key
linode-cli sshkeys view <key-id>

# Delete an SSH key (does not affect already-provisioned Linodes)
linode-cli sshkeys delete <key-id>
```

Inject a key at Linode creation time with `--authorized_keys "$(cat ~/.ssh/id_ed25519.pub)"` or by referencing its ID with `--authorized_users <username>` (which injects all keys associated with that user).

## Users and Grants

Linode accounts support multiple sub-users with granular per-resource access controls.

```bash
# List users on the account
linode-cli users list
linode-cli users list --text --format "username,email,restricted" --no-headers

# View a user's profile
linode-cli users view <username>

# Create a restricted user (they receive an email to set their password)
linode-cli users create \
  --username jdoe \
  --email jdoe@example.com \
  --restricted true

# View what a restricted user is allowed to do
linode-cli users grants-view <username>

# Update user grants (grant full access to a specific Linode)
linode-cli users grants-update <username> \
  --global '{"account_access":null}' \
  --linode '[{"id":<linode-id>,"permissions":"read_write"}]'

# Delete a user
linode-cli users delete <username>
```

Unrestricted users have full account access. Grant levels per resource: `read_only` or `read_write`.

## TLS / SSL Certificates

Linode does not provide a standalone managed TLS certificate resource. Certificates are configured inline when setting up an HTTPS NodeBalancer config:

```bash
linode-cli nodebalancers config-create <nb-id> \
  --port 443 \
  --protocol https \
  --ssl_cert "$(cat /path/to/fullchain.pem)" \
  --ssl_key "$(cat /path/to/privkey.pem)"
```

Use [Certbot](https://certbot.eff.org/) or another ACME client to obtain Let's Encrypt certificates, then pass them to NodeBalancer configs as shown above. Certificates are not stored as a separate first-class resource — they are embedded in the NodeBalancer config.

## Tags

Tags are free-form strings that can be applied to most Linode resources for organization and filtering.

```bash
# List all tags on the account
linode-cli tags list

# Create a tag (tags are account-wide labels)
linode-cli tags create --label production

# Delete a tag
linode-cli tags delete <tag-label>

# Apply a tag when creating a Linode
linode-cli linodes create --label web-1 --tags production --tags web ...

# Update tags on an existing Linode (replaces all existing tags)
linode-cli linodes update <linode-id> --tags production --tags web
```

Tags can also be passed as `--tags <value>` when creating NodeBalancers, volumes, domains, and LKE clusters.

## Beyond the basics

Run `linode-cli users --help`, `linode-cli sshkeys --help`, or `linode-cli tags --help` for the full flag reference. For network-layer access control (firewall rules), see the `linode-networking` skill. For API token management, use the Linode Cloud Manager (cloud.linode.com) under My Profile > API Tokens — the CLI does not manage tokens itself.
