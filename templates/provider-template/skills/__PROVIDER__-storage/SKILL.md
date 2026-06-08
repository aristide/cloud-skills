---
name: __PROVIDER__-storage
description: "Use when the user needs to manage __PROVIDER_DISPLAY__ storage — block volumes/disks (create, attach, detach, resize, snapshot, delete) and, where offered, object storage."
---

# __PROVIDER_DISPLAY__ Storage

All commands are `__CLI__ <storage-group> ...`. See the `__PROVIDER__-setup` skill for auth/region selection.

## Block Volumes / Disks

```bash
# __CLI__ <volume> create --size <gb> --region <region>
# __CLI__ <volume> list
# __CLI__ <volume> attach <volume> --instance <id>
# __CLI__ <volume> detach <volume>
# __CLI__ <volume> resize <volume> --size <gb>
# __CLI__ <volume> delete <volume>
```

Note: a detached/unattached volume usually **still bills**.

## Snapshots

```bash
# __CLI__ <snapshot> create / list / delete
```

## Object Storage (if offered)

```bash
# __CLI__ <object-storage|bucket> create / list / delete
```

If this provider has no object storage, say so and point to the alternative (e.g. an S3-compatible endpoint).

## Beyond the basics

Point at `__CLI__ <group> --help` for advanced flags.
