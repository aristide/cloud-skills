---
name: digitalocean-kubernetes
description: "Use when the user needs to manage DigitalOcean Kubernetes (DOKS) — create, list, inspect, or delete clusters; manage node pools; fetch kubeconfig; or upgrade the control plane."
---

# DigitalOcean Kubernetes (DOKS)

All commands are `doctl kubernetes cluster ...` or `doctl kubernetes cluster node-pool ...`. After fetching kubeconfig, the cluster is driven with `kubectl`. See the `digitalocean-setup` skill for auth/region selection.

## Clusters

### Create a cluster

```bash
doctl kubernetes cluster create my-cluster \
  --region nyc3 \
  --version latest \
  --node-pool "name=default;size=s-2vcpu-4gb;count=3" \
  --wait
```

Common flags:
- `--region <slug>` — e.g. `nyc3`, `fra1`, `sgp1` (required)
- `--version <k8s-version>` — use `latest` or a specific version from `doctl kubernetes options versions`
- `--node-pool "name=...;size=...;count=..."` — defines the initial node pool; repeat for multiple pools
- `--vpc-uuid <uuid>` — place the cluster in a specific VPC
- `--tag <tag>,...` — apply tags
- `--wait` — block until the cluster is provisioned (takes several minutes)

### List and inspect

```bash
doctl kubernetes cluster list
doctl kubernetes cluster list --format ID,Name,Region,Version,Status --no-header

doctl kubernetes cluster get <cluster-id-or-name>
```

### Upgrade the control plane

```bash
# See available upgrade versions
doctl kubernetes cluster get <cluster-id> --format Version
doctl kubernetes options versions

# Upgrade
doctl kubernetes cluster upgrade <cluster-id> --version <new-version>
```

### Delete a cluster

```bash
doctl kubernetes cluster delete <cluster-id-or-name>
doctl kubernetes cluster delete <cluster-id> --force    # skip confirmation
```

Deletion destroys all nodes and the control plane. Volumes and load balancers created by Kubernetes PersistentVolumeClaims or Services may need to be cleaned up separately (see `digitalocean-cleanup`).

## Node Pools

```bash
# List node pools in a cluster
doctl kubernetes cluster node-pool list <cluster-id>

# Add a node pool
doctl kubernetes cluster node-pool create <cluster-id> \
  --name workers \
  --size s-4vcpu-8gb \
  --count 2 \
  --tag backend

# Scale an existing pool
doctl kubernetes cluster node-pool update <cluster-id> <node-pool-id> \
  --count 5

# Delete a node pool (must have at least one pool remaining)
doctl kubernetes cluster node-pool delete <cluster-id> <node-pool-id>
```

## Kubeconfig

```bash
# Save / merge credentials into ~/.kube/config
doctl kubernetes cluster kubeconfig save <cluster-id-or-name>

# Print kubeconfig to stdout (useful for CI/CD pipelines)
doctl kubernetes cluster kubeconfig show <cluster-id-or-name>

# Expiry: DOKS tokens are short-lived; doctl refreshes them automatically
# Remove credentials when done
doctl kubernetes cluster kubeconfig remove <cluster-id-or-name>
```

After saving kubeconfig, verify access:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Useful Options

```bash
# List supported regions and Kubernetes versions
doctl kubernetes options regions
doctl kubernetes options versions

# List node sizes available for DOKS
doctl kubernetes options sizes
```

## Beyond the basics

Run `doctl kubernetes --help` for the full surface, including cluster maintenance windows, surge upgrades, and auto-scaling (configured in the node pool `--auto-scale`, `--min-nodes`, `--max-nodes` flags). Persistent storage and LoadBalancer Services are provisioned automatically via the DigitalOcean Container Storage Interface (CSI) and Cloud Controller Manager bundled in every DOKS cluster.
