---
name: vultr-kubernetes
description: "Use when the user needs to manage Vultr Kubernetes Engine (VKE) — create, list, or delete clusters, manage node pools, fetch kubeconfig credentials, and handle version upgrades."
---

# Vultr Kubernetes Engine (VKE)

VKE is Vultr's managed Kubernetes service. Vultr manages the control plane; you manage node pools. All commands use `vultr-cli kubernetes ...`. Confirm exact flags with `vultr-cli kubernetes --help`.

## Clusters

### List available Kubernetes versions

```bash
vultr-cli kubernetes versions
```

### Create a cluster

Node pools are passed as comma-separated key=value pairs; multiple pools are separated by `/`.

```bash
vultr-cli kubernetes create \
  --region  ewr \
  --version 1.31.0+1 \
  --label   "my-cluster" \
  --node-pools "quantity:2,plan:vc2-2c-4gb,label:workers"
```

Common node-pool keys: `quantity`, `plan`, `label`, `tag`. Run `vultr-cli plans list` for plan ids.

Optional flags:
- `--enable-firewall` — create a managed firewall group for the cluster nodes
- `--high-avail` — deploy highly available (multi-node) control planes

### List and inspect

```bash
vultr-cli kubernetes list
vultr-cli kubernetes get <cluster-id>
```

### Update label or delete

```bash
vultr-cli kubernetes update <cluster-id> --label "new-label"
vultr-cli kubernetes delete <cluster-id>
```

## Kubeconfig

Download and merge the cluster's kubeconfig so `kubectl` can talk to it:

```bash
vultr-cli kubernetes config <cluster-id>
# By default this prints the kubeconfig YAML; pipe it or redirect to a file:
vultr-cli kubernetes config <cluster-id> > ~/.kube/vultr-cluster.yaml

# Merge into your default kubeconfig
KUBECONFIG=~/.kube/config:~/.kube/vultr-cluster.yaml \
  kubectl config view --flatten > /tmp/merged.yaml && mv /tmp/merged.yaml ~/.kube/config

# Verify
kubectl config get-contexts
kubectl get nodes
```

## Node Pools

```bash
# List all node pools in a cluster
vultr-cli kubernetes node-pool list <cluster-id>

# Add a new node pool
vultr-cli kubernetes node-pool create <cluster-id> \
  --quantity 3 \
  --plan     vc2-4c-8gb \
  --label    "gpu-workers"

# Get / update / scale
vultr-cli kubernetes node-pool get    <cluster-id> <node-pool-id>
vultr-cli kubernetes node-pool update <cluster-id> <node-pool-id> --quantity 5

# Delete a node pool (drains nodes first)
vultr-cli kubernetes node-pool delete <cluster-id> <node-pool-id>
```

Manage individual nodes within a pool:

```bash
vultr-cli kubernetes node-pool node list   <cluster-id> <node-pool-id>
```

## Version Upgrades

```bash
# See available upgrade targets for a cluster
vultr-cli kubernetes upgrades list <cluster-id>

# Start an upgrade
vultr-cli kubernetes upgrades start <cluster-id> --version <target-version>
```

Upgrades are rolling; control plane upgrades first, then node pools.

## Beyond the basics

Run `vultr-cli kubernetes --help` and `vultr-cli kubernetes node-pool --help` for the full flag reference. After fetching kubeconfig, use `kubectl`, `helm`, and standard Kubernetes tooling. For a private container image registry alongside your cluster, see the `vultr-containers` skill.
