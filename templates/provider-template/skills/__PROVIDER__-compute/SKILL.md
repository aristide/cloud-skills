---
name: __PROVIDER__-compute
description: "Use when the user needs to create, list, inspect, start, stop, reboot, or delete __PROVIDER_DISPLAY__ compute instances, SSH into them, or look up instance types and images."
---

# __PROVIDER_DISPLAY__ Compute

All commands are `__CLI__ <compute-group> ...`. Add location/profile flags as needed (see the `__PROVIDER__-setup` skill).

## Instance Lifecycle

### Create an Instance

```bash
# __CLI__ <compute> create ...
```

Document the required and common flags (image, type/size, name, location, ssh key, user-data, tags).

### List / Describe Instances

```bash
# __CLI__ <compute> list
# __CLI__ <compute> describe <id>
```

## Power Management

```bash
# __CLI__ <compute> start  <id>
# __CLI__ <compute> stop   <id>
# __CLI__ <compute> reboot <id>
```

Note any billing nuance (e.g. "stop" still bills compute vs. a "deallocate"-style stop that doesn't).

### Delete (destroy)

```bash
# __CLI__ <compute> delete <id>
```

Call out irreversibility and whether attached disks/IPs are removed or orphaned.

## Access

### SSH / get IP

```bash
# __CLI__ <compute> ssh <id>          # if supported
# else: fetch the public IP and ssh manually
```

## Images and Instance Types

```bash
# __CLI__ <images list>
# __CLI__ <instance-types list>
```

## Beyond Compute

For networking, storage, load balancers, and IAM, use the same `__CLI__ <group> <command>` pattern; run `__CLI__ <group> --help`. This skill focuses on core compute; add more skills for broader coverage.
