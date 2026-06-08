---
name: __PROVIDER__-containers
description: "Use when the user needs to run containers on __PROVIDER_DISPLAY__ without managing Kubernetes — container instances/apps/services and the container registry."
---

# __PROVIDER_DISPLAY__ Containers (serverless containers / registry)

All commands are `__CLI__ <group> ...`. See the `__PROVIDER__-setup` skill for auth.

> If this provider has **no** managed container runtime beyond Kubernetes, replace this body with a short note saying so (point users to the `__PROVIDER__-kubernetes` skill or to running Docker on an instance), or remove the skill.

## Container Service / Apps

```bash
# __CLI__ <container|app> deploy --image <image> ...
# __CLI__ <container|app> list
# __CLI__ <container|app> delete <name>
```

Cover deploying from an image, setting env/ports/scaling, and viewing logs/status.

## Container Registry (if offered)

```bash
# __CLI__ <registry> create / list / login / delete
```

## Beyond the basics

Point at `__CLI__ <group> --help`.
