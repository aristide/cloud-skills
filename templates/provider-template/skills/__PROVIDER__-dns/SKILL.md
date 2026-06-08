---
name: __PROVIDER__-dns
description: "Use when the user needs to manage __PROVIDER_DISPLAY__ DNS — zones/domains and records (A, AAAA, CNAME, MX, TXT, etc.), including create, list, update, and delete."
---

# __PROVIDER_DISPLAY__ DNS

All commands are `__CLI__ <dns-group> ...`. See the `__PROVIDER__-setup` skill for auth.

> If this provider does **not** offer managed DNS, replace this skill's body with a short note saying so and pointing to the usual alternative (e.g. the registrar or an external DNS provider), or remove the skill.

## Zones / Domains

```bash
# __CLI__ <zone|domain> create <name>
# __CLI__ <zone|domain> list
# __CLI__ <zone|domain> delete <name>
```

## Records

```bash
# __CLI__ <record> create --zone <name> --type A --name www --value <ip> --ttl 3600
# __CLI__ <record> list --zone <name>
# __CLI__ <record> update ...
# __CLI__ <record> delete ...
```

Cover the common record types (A, AAAA, CNAME, MX, TXT) and TTL handling.

## Beyond the basics

Point at `__CLI__ <group> --help`.
