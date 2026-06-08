---
name: __PROVIDER__-networking
description: "Use when the user needs to manage __PROVIDER_DISPLAY__ networking — virtual networks/VPCs, subnets, firewalls/security groups, public/floating/reserved IPs, and load balancers."
---

# __PROVIDER_DISPLAY__ Networking

All commands are `__CLI__ <networking-group> ...`. See the `__PROVIDER__-setup` skill for auth/region selection.

## Virtual Networks / VPCs

```bash
# __CLI__ <network> create / list / describe / delete
```

Document create (CIDR/range), list, describe, and delete, plus subnets/routes if the provider models them separately.

## Firewalls / Security Groups

```bash
# __CLI__ <firewall|security-group> create / list / add-rule / remove-rule / delete
```

Cover creating a rule set, attaching it to instances, and adding/removing ingress/egress rules.

## Public / Floating / Reserved IPs

```bash
# __CLI__ <ip> create / list / assign / unassign / delete
```

Note which idle IPs bill while unattached.

## Load Balancers

```bash
# __CLI__ <load-balancer> create / list / add-target / add-service / delete
```

## Beyond the basics

Point at `__CLI__ <group> --help` for advanced flags. Keep this skill to the common networking workflows.
