---
name: azure-kubernetes
description: "Use when the user needs to manage Azure Kubernetes Service (AKS) — create, list, and delete clusters, manage node pools, scale, and fetch kubeconfig credentials."
---

# Azure Kubernetes Service (AKS)

All commands are `az aks ...`. AKS clusters live in a resource group; pass `--resource-group/-g` (or set a default — see the `azure-setup` skill).

## Clusters

### Create a cluster

```bash
az aks create \
  --resource-group <rg> \
  --name <cluster-name> \
  --node-count 2 \
  --node-vm-size Standard_D2s_v5 \
  --generate-ssh-keys \
  --location <region>
```

Common flags:
- `--node-count` — initial node count in the default node pool (default 3)
- `--node-vm-size` — VM SKU for nodes (default `Standard_DS2_v2`)
- `--kubernetes-version` — pin a Kubernetes version (see `az aks get-versions`)
- `--enable-managed-identity` — use a system-assigned managed identity (recommended)
- `--network-plugin azure` — use Azure CNI instead of kubenet
- `--attach-acr <acr-name>` — grant the cluster pull access to an ACR

### List clusters

```bash
az aks list -g <rg> -o table
az aks list \
  --query '[].{name:name,rg:resourceGroup,k8s:kubernetesVersion,nodes:agentPoolProfiles[0].count,state:provisioningState}' \
  -o table
```

### Show cluster details

```bash
az aks show -g <rg> -n <cluster-name>
az aks show -g <rg> -n <cluster-name> --query '{fqdn:fqdn,k8s:kubernetesVersion,state:provisioningState}'
```

### Delete a cluster

```bash
az aks delete -g <rg> -n <cluster-name> --yes --no-wait
```

## Kubeconfig

Download and merge cluster credentials into `~/.kube/config` so `kubectl` works:

```bash
az aks get-credentials \
  --resource-group <rg> \
  --name <cluster-name>

# Verify the connection
kubectl get nodes
```

`--overwrite-existing` refreshes an existing context entry without prompting. Use `--admin` for cluster-admin credentials (requires appropriate RBAC).

## Node Pools

AKS clusters have at least one **system** node pool and optionally one or more **user** node pools.

### List node pools

```bash
az aks nodepool list -g <rg> --cluster-name <cluster-name> -o table
```

### Add a node pool

```bash
az aks nodepool add \
  --resource-group <rg> \
  --cluster-name <cluster-name> \
  --name <pool-name> \
  --node-count 2 \
  --node-vm-size Standard_D4s_v5 \
  --mode User
```

### Scale a node pool

```bash
az aks nodepool scale \
  --resource-group <rg> \
  --cluster-name <cluster-name> \
  --name <pool-name> \
  --node-count 5
```

The `az aks scale` shorthand scales the default node pool:

```bash
az aks scale -g <rg> -n <cluster-name> --node-count 3
```

### Delete a node pool

```bash
az aks nodepool delete \
  --resource-group <rg> \
  --cluster-name <cluster-name> \
  --name <pool-name> \
  --no-wait
```

## Kubernetes Version Management

```bash
# List available Kubernetes versions for a region
az aks get-versions --location <region> -o table

# Upgrade a cluster's control plane
az aks upgrade -g <rg> -n <cluster-name> --kubernetes-version 1.30.0

# Upgrade a specific node pool
az aks nodepool upgrade \
  --resource-group <rg> \
  --cluster-name <cluster-name> \
  --name <pool-name> \
  --kubernetes-version 1.30.0
```

## Beyond the basics

Run `az aks --help` for the full subcommand list. Key advanced topics include enabling the cluster autoscaler (`--enable-cluster-autoscaler`), workload identity (`az aks update --enable-workload-identity`), Azure Monitor / container insights (`--enable-addons monitoring`), and GitOps with Flux (`az k8s-configuration`). After fetching credentials, manage workloads with `kubectl` or `helm`.
