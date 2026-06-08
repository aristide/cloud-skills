---
name: __PROVIDER__-kubernetes
description: "Use when the user needs to manage __PROVIDER_DISPLAY__ managed Kubernetes — create/list/delete clusters, manage node pools, and fetch kubeconfig credentials."
---

# __PROVIDER_DISPLAY__ Managed Kubernetes

All commands are `__CLI__ <k8s-group> ...`. See the `__PROVIDER__-setup` skill for auth.

> If this provider does **not** offer managed Kubernetes, replace this body with a short note saying so (and point to running k8s on plain instances, or to `kubectl`/Terraform), or remove the skill.

## Clusters

```bash
# __CLI__ <cluster> create --name <name> --region <region> --node-pool ...
# __CLI__ <cluster> list
# __CLI__ <cluster> delete <name-or-id>
```

## Node Pools

```bash
# __CLI__ <node-pool> create / list / scale / delete
```

## Kubeconfig

```bash
# __CLI__ <cluster> kubeconfig <name>   # write/merge credentials for kubectl
```

After fetching kubeconfig, the user drives the cluster with `kubectl`.

## Beyond the basics

Point at `__CLI__ <group> --help`.
