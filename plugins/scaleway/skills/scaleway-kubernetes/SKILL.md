---
name: scaleway-kubernetes
description: "Use when the user needs to manage Scaleway Kubernetes Kapsule — create, list, upgrade, or delete clusters, manage node pools (including autoscaling), and fetch kubeconfig credentials for kubectl."
---

# Scaleway Kubernetes Kapsule

All commands are `scw k8s ...`. Kapsule is a **regional** managed Kubernetes service — pass `region=<region>` or rely on the default region from `scw config`. After fetching kubeconfig, use standard `kubectl` to interact with the cluster. Confirm exact flags with `scw k8s --help`.

## Clusters

### Create a Cluster

The cluster and its initial node pool are described together in a single command:

```bash
scw k8s cluster create \
  name=my-cluster \
  version=1.31.2 \
  cni=cilium \
  pools.0.name=default \
  pools.0.node-type=DEV1-M \
  pools.0.size=3 \
  region=fr-par
```

Common arguments:
- `version=<version>` — Kubernetes version (list available: `scw k8s version list region=fr-par`)
- `cni=<cni>` — CNI plugin: `cilium` (default), `calico`, `flannel`, `weave`
- `pools.0.node-type=<type>` — Instance type for nodes, e.g. `DEV1-M`, `GP1-S`, `PRO2-XS`
- `pools.0.size=<n>` — Initial number of nodes
- `pools.0.min-size=<n>` / `pools.0.max-size=<n>` — Required when autoscaling is enabled
- `pools.0.autoscaling=true` — Enable cluster autoscaler for the pool
- `pools.0.autohealing=true` — Automatically replace unhealthy nodes
- `tags.0=<tag>` — Resource tags

With autoscaling:

```bash
scw k8s cluster create \
  name=prod-cluster \
  version=1.31.2 \
  cni=cilium \
  pools.0.name=workers \
  pools.0.node-type=GP1-S \
  pools.0.size=2 \
  pools.0.min-size=1 \
  pools.0.max-size=10 \
  pools.0.autoscaling=true \
  pools.0.autohealing=true \
  region=fr-par
```

### List and Inspect Clusters

```bash
scw k8s cluster list region=fr-par
scw k8s cluster list -o table=ID,Name,Status,Version,Region

scw k8s cluster get <cluster-id> region=fr-par
```

### Upgrade a Cluster

```bash
# List available versions
scw k8s version list region=fr-par

# Upgrade the control plane
scw k8s cluster upgrade <cluster-id> version=1.32.0 region=fr-par
```

### Delete a Cluster

```bash
# Delete cluster only (node pools are also removed)
scw k8s cluster delete <cluster-id> region=fr-par

# Delete cluster and all associated Block volumes (persistent volumes)
scw k8s cluster delete <cluster-id> with-block-volumes=true region=fr-par
```

## Kubeconfig

Fetch credentials so `kubectl` can connect to the cluster:

```bash
# Merge kubeconfig into ~/.kube/config (recommended)
scw k8s kubeconfig install <cluster-id> region=fr-par

# Write raw kubeconfig to stdout (useful for CI/CD)
scw k8s kubeconfig get <cluster-id> region=fr-par > ~/.kube/my-cluster.kubeconfig

# Remove cluster credentials from ~/.kube/config
scw k8s kubeconfig uninstall <cluster-id> region=fr-par
```

After installing kubeconfig, verify connectivity:

```bash
kubectl get nodes
kubectl cluster-info
```

## Node Pools

Node pools allow mixing instance types or enabling autoscaling independently per pool.

```bash
# List pools in a cluster
scw k8s pool list cluster-id=<cluster-id> region=fr-par

# Create an additional pool
scw k8s pool create \
  cluster-id=<cluster-id> \
  name=gpu-pool \
  node-type=RENDER-S \
  size=2 \
  region=fr-par

# Get pool details
scw k8s pool get <pool-id> region=fr-par

# Scale a pool (change the node count)
scw k8s pool update <pool-id> size=5 region=fr-par

# Upgrade nodes in a pool to match the cluster version
scw k8s pool upgrade <pool-id> version=1.32.0 region=fr-par

# Delete a pool (drains nodes first)
scw k8s pool delete <pool-id> region=fr-par
```

## Individual Nodes

```bash
scw k8s node list pool-id=<pool-id> region=fr-par

# Replace a faulty node (drain + delete + reprovision)
scw k8s node replace <node-id> region=fr-par

# Reboot a node
scw k8s node reboot <node-id> region=fr-par
```

## Beyond the basics

Use `scw k8s --help` for the full argument list. For persistent storage inside Kapsule, see the `scaleway-storage` skill. For exposing services publicly, combine `kubectl` LoadBalancer services with the `scaleway-networking` skill.
