---
name: digitalocean-security
description: "Use when the user needs to manage DigitalOcean security — SSH keys, TLS/SSL certificates, resource tags, and Projects for access organisation."
---

# DigitalOcean Security

SSH keys are under `doctl compute ssh-key`; certificates under `doctl compute certificate`; tags under `doctl compute tag`; and projects under `doctl projects`. See the `digitalocean-setup` skill for auth.

## SSH Keys

SSH keys stored in your account can be injected into Droplets at creation time.

```bash
# List keys already in the account
doctl compute ssh-key list
doctl compute ssh-key list --format ID,Name,FingerPrint --no-header

# Create (paste a public-key string)
doctl compute ssh-key create my-key \
  --public-key "$(cat ~/.ssh/id_ed25519.pub)"

# Import from a file
doctl compute ssh-key import my-key \
  --public-key-file ~/.ssh/id_ed25519.pub

# Get a key by ID or fingerprint
doctl compute ssh-key get <id-or-fingerprint>

# Delete
doctl compute ssh-key delete <id>
```

Pass key IDs or fingerprints via `--ssh-keys` when creating a Droplet. Without SSH keys, DigitalOcean emails a root password.

## TLS / SSL Certificates

Certificates can be uploaded (custom) or issued automatically via Let's Encrypt (managed). Managed certs auto-renew.

```bash
# List certificates
doctl compute certificate list
doctl compute certificate get <cert-id>

# Create a custom certificate (upload your own chain + key)
doctl compute certificate create \
  --name my-cert \
  --type custom \
  --certificate-chain-path ./fullchain.pem \
  --private-key-path ./privkey.pem \
  --leaf-certificate-path ./cert.pem

# Create a Let's Encrypt managed certificate (DO controls renewal)
doctl compute certificate create \
  --name my-managed-cert \
  --type lets_encrypt \
  --dns-names "example.com,www.example.com"
```

The domain(s) must resolve to a DigitalOcean Load Balancer IP before a Let's Encrypt cert can be issued. After creation, attach the certificate to a Load Balancer forwarding rule.

```bash
# Delete a certificate
doctl compute certificate delete <cert-id>
```

## Tags

Tags are free-form labels you attach to most DigitalOcean resources (Droplets, volumes, load balancers, etc.).

```bash
# Create a tag
doctl compute tag create env:prod

# List tags
doctl compute tag list

# Get resources under a tag
doctl compute tag get env:prod

# Delete a tag (does not affect the tagged resources)
doctl compute tag delete env:prod
```

Attach tags at resource-creation time with `--tag-names`, or add them after creation via the tag resource's `--resource-id`/`--resource-type` flags.

## Projects

Projects let you group resources (Droplets, domains, spaces, load balancers, etc.) and set default regions and environments.

```bash
# List projects
doctl projects list

# Create a project
doctl projects create \
  --name "my-project" \
  --purpose "Application hosting" \
  --environment production

# List resources in a project
doctl projects resources list <project-id>

# Assign resources to a project
doctl projects resources assign <project-id> \
  --resource=do:droplet:<droplet-id> \
  --resource=do:volume:<volume-id>
```

## Beyond the basics

Run `doctl compute ssh-key --help`, `doctl compute certificate --help`, `doctl compute tag --help`, and `doctl projects --help` for the full flag surface. For fine-grained API token scopes and team member access, use the DigitalOcean control panel under **Settings → Security**.
