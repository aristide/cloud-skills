---
name: contabo-security
description: "Use when the user needs to manage Contabo security credentials — SSH key secrets, password secrets, and resource tags — or wants to understand what security primitives are available."
---

# Contabo Security

All commands are `cntb <verb> secret[s] ...` or `cntb <verb> tag[s] ...`. Confirm exact flags with `cntb create secret --help` etc.

> **Scope note:** Contabo does not offer a managed TLS/SSL certificate product, an IAM system, or role-based access control through `cntb`. Certificate management should be handled on your instance (e.g. Let's Encrypt / Certbot). There are no sub-user or team-role primitives in the `cntb` CLI.

## Secrets (SSH Keys & Passwords)

Secrets store sensitive values — SSH public keys and root passwords — that are referenced by ID when creating instances, so you never pass plaintext credentials directly on the command line.

### List secrets

```bash
cntb get secrets
cntb get secrets -o json
```

### Create an SSH key secret

```bash
cntb create secret \
  --type ssh \
  --name "<descriptive-name>" \
  --value "ssh-ed25519 AAAA..."
```

### Create a password secret

```bash
cntb create secret \
  --type password \
  --name "<descriptive-name>" \
  --value "<password>"
```

Store the returned secret ID — use it as `--sshKeys <secret-id>` or `--rootPassword <secret-id>` when running `cntb create instance` (see `contabo-compute`).

### Get a specific secret

```bash
cntb get secret <secret-id>
```

Note: `cntb` does not return the raw secret value after creation for security reasons.

### Update a secret

```bash
cntb update secret <secret-id> --name "<new-name>"
```

Updating the value of an existing secret may require deleting and recreating it — check `cntb update secret --help`.

### Delete a secret

```bash
cntb delete secret <secret-id>
```

Ensure the secret is not referenced by any instance before deleting it.

## Tags

Tags are key-value labels attached to Contabo resources (instances, object storages, etc.) for organisation and filtering.

### List tags

```bash
cntb get tags
cntb get tags -o json
```

### Get a specific tag

```bash
cntb get tag <tag-id>
```

### Create a tag

```bash
cntb create tag --name "<tag-name>"
```

### Assign a tag to a resource

```bash
cntb create tagAssignment <tag-id> <resourceType> <resource-id>
```

Arguments are positional (verify order with `cntb create tagAssignment --help`).
Common `resourceType` values: `instance`, `objectStorage`.

### List tag assignments

```bash
cntb get tagAssignments <tag-id>
```

### Delete a tag

```bash
cntb delete tag <tag-id>
```

Remove all tag assignments first with `cntb delete tagAssignment`.

## TLS / SSL certificates

Contabo does not provide a managed certificate product. Obtain and renew TLS certificates directly on your instance:

```bash
# Example using Certbot (Let's Encrypt) on the instance
sudo certbot --nginx -d example.com
```

## Beyond the basics

```bash
cntb get secrets --help
cntb create secret --help
cntb get tags --help
cntb create tagAssignment --help
```

Secrets created here are used at instance creation time in the `contabo-compute` skill. For identifying idle/unused secrets, see the `contabo-cleanup` command.
