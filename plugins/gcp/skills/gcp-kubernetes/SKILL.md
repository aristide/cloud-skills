---
name: gcp-kubernetes
description: "Use when the user needs to manage Google Kubernetes Engine (GKE) — create, list, or delete clusters, manage node pools, fetch kubeconfig credentials, and resize or upgrade clusters."
---

# Google Kubernetes Engine (GKE)

All commands are `gcloud container ...`. Enable the API first: `gcloud services enable container.googleapis.com`. After fetching credentials, use `kubectl` to manage workloads.

## Clusters

### Create

```bash
# Standard zonal cluster (single control-plane zone)
gcloud container clusters create my-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type e2-standard-2 \
  --disk-size 50GB

# Regional cluster (control plane and nodes spread across zones — recommended for production)
gcloud container clusters create my-cluster \
  --region us-central1 \
  --num-nodes 1 \
  --machine-type e2-standard-2

# Autopilot cluster (Google manages nodes; pay per pod, not node)
gcloud container clusters create-auto my-autopilot-cluster \
  --region us-central1

# Common optional flags:
#   --cluster-version <version>       pin the GKE version
#   --enable-autoscaling --min-nodes 1 --max-nodes 5
#   --network my-vpc --subnetwork my-subnet
#   --enable-private-nodes --master-ipv4-cidr 172.16.0.0/28
#   --workload-pool=PROJECT_ID.svc.id.goog   (Workload Identity)
```

### List and describe

```bash
gcloud container clusters list
gcloud container clusters list \
  --format='table(name,location,status,currentMasterVersion,currentNodeCount)'
gcloud container clusters describe my-cluster --zone us-central1-a
```

### Upgrade

```bash
# List available versions
gcloud container get-server-config --zone us-central1-a

# Upgrade control plane
gcloud container clusters upgrade my-cluster \
  --zone us-central1-a \
  --master

# Upgrade a node pool
gcloud container clusters upgrade my-cluster \
  --zone us-central1-a \
  --node-pool default-pool
```

### Delete

```bash
gcloud container clusters delete my-cluster --zone us-central1-a
```

## Kubeconfig

Fetch credentials and merge them into `~/.kube/config` so `kubectl` works:

```bash
gcloud container clusters get-credentials my-cluster --zone us-central1-a

# Verify context
kubectl config current-context
kubectl get nodes
```

## Node Pools

```bash
# List node pools
gcloud container node-pools list --cluster my-cluster --zone us-central1-a

# Add a new node pool (e.g. GPU pool)
gcloud container node-pools create gpu-pool \
  --cluster my-cluster \
  --zone us-central1-a \
  --machine-type n1-standard-4 \
  --accelerator type=nvidia-tesla-t4,count=1 \
  --num-nodes 2

# Resize an existing node pool
gcloud container clusters resize my-cluster \
  --zone us-central1-a \
  --node-pool default-pool \
  --num-nodes 5

# Enable autoscaling on a node pool
gcloud container node-pools update default-pool \
  --cluster my-cluster \
  --zone us-central1-a \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 10

# Delete a node pool
gcloud container node-pools delete gpu-pool \
  --cluster my-cluster \
  --zone us-central1-a
```

## Cluster Credentials for CI/CD

For non-interactive environments, authenticate with a service account:

```bash
gcloud auth activate-service-account --key-file=sa-key.json
gcloud container clusters get-credentials my-cluster \
  --zone us-central1-a \
  --project PROJECT_ID
```

## Beyond the basics

Run `gcloud container --help` for the full command tree. GKE also supports **Gateway API**, **Config Connector**, **Binary Authorization**, **GKE Dataplane V2**, and fleet management via `gcloud container fleet`. For workload management use `kubectl` — GKE is fully Kubernetes-conformant.
