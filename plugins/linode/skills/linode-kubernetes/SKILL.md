---
name: linode-kubernetes
description: "Use when the user needs to manage Linode Kubernetes Engine (LKE) — create, list, inspect, and delete clusters; manage node pools; fetch kubeconfig credentials; and upgrade Kubernetes versions."
---

# Linode Kubernetes Engine (LKE)

All commands are `linode-cli lke ...`. LKE provides managed Kubernetes clusters with a free control plane. See the `linode-setup` skill for auth and region selection.

## Clusters

### Create a cluster

```bash
linode-cli lke cluster-create \
  --label my-cluster \
  --region us-east \
  --k8s_version 1.31 \
  --node_pools '[{"type":"g6-standard-2","count":3}]'
```

Common flags:
- `--label <name>` - Cluster display name
- `--region <region>` - Must be an LKE-supported region (`linode-cli regions list`)
- `--k8s_version <version>` - Available versions from `linode-cli lke versions-list`
- `--node_pools '[{"type":"<type>","count":<n>}]'` - At least one pool required
- `--tags <tag>` - Apply a tag (repeatable)
- `--control_plane.high_availability true` - Enable HA control plane (additional cost)

### List and view clusters

```bash
linode-cli lke clusters-list
linode-cli lke clusters-list --text --format "id,label,region,k8s_version,status" --no-headers

linode-cli lke cluster-view <cluster-id>
```

### Update a cluster label

```bash
linode-cli lke cluster-update <cluster-id> --label new-label
```

### Upgrade Kubernetes version

```bash
# List available versions
linode-cli lke versions-list

# Recycle all nodes in a cluster after upgrading (rolling restart):
linode-cli lke cluster-nodes-recycle <cluster-id>
```

### Delete a cluster

```bash
linode-cli lke cluster-delete <cluster-id>
```

Deleting a cluster destroys all node pool Linodes and their disks. Detach and back up any persistent volumes before deleting.

## Node Pools

```bash
# List node pools in a cluster
linode-cli lke pools-list <cluster-id>
linode-cli lke pools-list <cluster-id> --text --format "id,type,count,status" --no-headers

# View a specific pool
linode-cli lke pool-view <cluster-id> <pool-id>

# Create an additional node pool
linode-cli lke pool-create <cluster-id> \
  --type g6-standard-4 \
  --count 2

# Resize a node pool (scale up or down)
linode-cli lke pool-update <cluster-id> <pool-id> --count 5

# Recycle (rolling restart) a specific node pool
linode-cli lke pool-recycle <cluster-id> <pool-id>

# Delete a node pool (drains and destroys those nodes)
linode-cli lke pool-delete <cluster-id> <pool-id>
```

## Kubeconfig

Fetch and merge credentials so `kubectl` can connect to the cluster:

```bash
# View (base64-encoded) kubeconfig and decode it
linode-cli lke kubeconfig-view <cluster-id> --text --no-headers \
  | awk '{print $1}' \
  | base64 --decode > ~/.kube/linode-cluster.yaml

# Merge into default kubeconfig
KUBECONFIG=~/.kube/config:~/.kube/linode-cluster.yaml kubectl config view --flatten > ~/.kube/merged.yaml
mv ~/.kube/merged.yaml ~/.kube/config

# Or export for the current shell session only
export KUBECONFIG=~/.kube/linode-cluster.yaml
kubectl get nodes
```

After merging, drive the cluster with standard `kubectl` commands.

## Dashboard and Node Access

```bash
# View dashboard URL for a cluster
linode-cli lke cluster-dashboard <cluster-id>

# List individual nodes (Linodes) in a pool
linode-cli lke pool-nodes-list <cluster-id> <pool-id>

# Delete a single node (it will be recreated by LKE to maintain pool count)
linode-cli lke node-delete <cluster-id> <node-id>
```

## Common Workflow: Launch a Cluster and Deploy an App

```bash
# 1. Create cluster
linode-cli lke cluster-create \
  --label prod-cluster \
  --region us-east \
  --k8s_version 1.31 \
  --node_pools '[{"type":"g6-standard-2","count":3}]'

CLUSTER_ID=<id-from-above>

# 2. Wait for cluster to be ready (status: ready)
linode-cli lke cluster-view "$CLUSTER_ID" --text --format "status" --no-headers

# 3. Fetch kubeconfig
linode-cli lke kubeconfig-view "$CLUSTER_ID" --text --no-headers \
  | awk '{print $1}' | base64 --decode > ~/.kube/lke.yaml
export KUBECONFIG=~/.kube/lke.yaml

# 4. Verify nodes
kubectl get nodes

# 5. Deploy workloads normally via kubectl or Helm
kubectl apply -f my-app.yaml
```

## Beyond the basics

Run `linode-cli lke --help` for the full subcommand list. For persistent storage in LKE, use the Linode CSI driver (pre-installed on LKE clusters) and create PersistentVolumeClaims backed by Block Storage. For container image hosting, push to any public or private registry (Docker Hub, GitHub Container Registry, etc.) — Linode has no managed container registry. See the `linode-networking` skill for attaching Cloud Firewalls to LKE node pools.
