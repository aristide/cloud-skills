---
name: __PROVIDER__-serverless
description: "Use when the user needs to manage __PROVIDER_DISPLAY__ serverless functions — deploy, list, invoke, update, view logs, and delete functions (FaaS)."
---

# __PROVIDER_DISPLAY__ Serverless Functions

All commands are `__CLI__ <group> ...`. See the `__PROVIDER__-setup` skill for auth.

> If this provider has **no** functions/FaaS product, replace this body with a short note saying so (point to the `__PROVIDER__-containers` skill or an external FaaS), or remove the skill.

## Functions

```bash
# __CLI__ <function> create/deploy --name <name> --runtime <runtime> --handler <h> ...
# __CLI__ <function> list
# __CLI__ <function> invoke <name> --payload '<json>'
# __CLI__ <function> update <name> ...
# __CLI__ <function> logs <name>
# __CLI__ <function> delete <name>
```

Cover runtime selection, deploying code (zip/dir/registry image), invoking with a payload, and reading logs.

## Triggers (if modeled separately)

```bash
# __CLI__ <trigger> create ...   # HTTP, cron/schedule, queue, etc.
```

## Beyond the basics

Point at `__CLI__ <group> --help`.
