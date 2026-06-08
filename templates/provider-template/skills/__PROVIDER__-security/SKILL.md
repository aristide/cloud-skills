---
name: __PROVIDER__-security
description: "Use when the user needs to manage __PROVIDER_DISPLAY__ security — SSH keys, TLS/SSL certificates, and (where modeled) identity, roles, and resource tags/labels."
---

# __PROVIDER_DISPLAY__ Security

All commands are `__CLI__ <group> ...`. See the `__PROVIDER__-setup` skill for auth.

## SSH Keys

```bash
# __CLI__ <ssh-key> create --name <name> --public-key "<key>"
# __CLI__ <ssh-key> list
# __CLI__ <ssh-key> delete <id>
```

## TLS / SSL Certificates (if offered)

```bash
# __CLI__ <certificate> create / list / delete
```

Cover both uploaded and managed/auto-renewed certs if the provider supports them. If certs aren't a first-class resource, say so.

## Identity / Roles (if applicable)

```bash
# __CLI__ <iam|role|user> list ...
```

## Tags / Labels

```bash
# how this provider attaches tags/labels to resources
```

## Beyond the basics

Point at `__CLI__ <group> --help`.
