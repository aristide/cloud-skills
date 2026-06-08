---
name: vultr-security
description: "Use when the user needs to manage Vultr security — SSH keys for instance access, firewall groups (see vultr-networking), and resource tags on instances."
---

# Vultr Security

Vultr's security model centers on SSH keys, network-level firewall groups, and resource tags. There is no managed TLS certificate product, no IAM/role system, and no secrets manager — these concerns are handled at the OS/application layer or by a third-party tool.

All commands use `vultr-cli <group> ...`. Confirm exact flags with `vultr-cli <group> --help`.

## SSH Keys

SSH keys are stored at the account level and injected into new instances at creation time. Manage them once; reuse across all instances.

### Add a key

```bash
# Import an existing public key
vultr-cli ssh-key create \
  --name "my-laptop" \
  --key  "$(cat ~/.ssh/id_ed25519.pub)"
```

### List and delete keys

```bash
vultr-cli ssh-key list
vultr-cli ssh-key delete <key-id>
```

### Attach keys when creating an instance

```bash
# Get key ids first
vultr-cli ssh-key list

vultr-cli instance create \
  --region    <region-id> \
  --plan      <plan-id> \
  --os        <os-id> \
  --host      my-server \
  --ssh-keys  <key-id>,<key-id2>
```

Keys are injected at first boot only. Adding a key to your account after instance creation does not automatically add it to running instances — copy it manually with `ssh-copy-id` or via user-data.

## Firewall Groups

Network-level firewalls are managed under `vultr-cli firewall`. See the `vultr-networking` skill for full details. Quick reference:

```bash
vultr-cli firewall group list
vultr-cli firewall group create --description "web-servers"
vultr-cli firewall rule create <group-id> \
  --protocol tcp --port "22" \
  --subnet "0.0.0.0" --size 0 --ip-type v4
```

Attach a firewall group to an instance at create time with `--firewall-group <group-id>`.

## Tags

Tags are free-form strings attached to instances for labelling, cost allocation, and filtering. They are not an access-control mechanism.

```bash
# Set tags at creation
vultr-cli instance create ... --tags env:prod,team:backend

# Update tags on an existing instance
vultr-cli instance tags <instance-id> --tags env:prod,team:backend,app:api

# Filter list output by tag (use jq for client-side filtering)
vultr-cli instance list -o json | jq '[.instances[] | select(.tags[] | contains("env:prod"))]'
```

## What Vultr Does Not Provide

- **Managed TLS/SSL certificates** — Use Let's Encrypt (`certbot`) on the instance, or configure the load balancer's SSL options (see `vultr-cli load-balancer ssl --help`).
- **IAM / roles / service accounts** — There is no sub-account role model. Use separate API keys per team member from the Vultr control panel (Account → API).
- **Secrets manager** — Store secrets in Vault, AWS Secrets Manager, or a `.env` file on the instance with restricted permissions (`chmod 600`).

## Beyond the basics

Run `vultr-cli ssh-key --help` or `vultr-cli firewall --help` for the full flag reference. For OS-level hardening (fail2ban, ufw, etc.) those steps happen inside the instance, not via vultr-cli.
