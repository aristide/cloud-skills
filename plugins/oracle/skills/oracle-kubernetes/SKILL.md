---
name: oracle-kubernetes
description: "Use when the user needs to manage Oracle Cloud Infrastructure (OCI) managed Kubernetes (OKE) — create, list, or delete clusters, manage node pools, fetch kubeconfig credentials, and interact with cluster workloads."
---

# Oracle Cloud Infrastructure Kubernetes (OKE)

Commands are `oci ce ...` (Container Engine). Nearly everything needs `--compartment-id <ocid>`. After fetching kubeconfig, drive workloads with `kubectl`. See the `oracle-setup` skill for auth and OCIDs.

## Clusters

### Create a Cluster

```bash
oci ce cluster create \
  --compartment-id <compartment-ocid> \
  --name my-k8s-cluster \
  --kubernetes-version v1.29.1 \
  --vcn-id <vcn-ocid> \
  --service-lb-subnet-ids '["<lb-subnet-ocid>"]' \
  --endpoint-config '{"isPublicIpEnabled":true,"subnetId":"<endpoint-subnet-ocid>"}' \
  --wait-for-state ACTIVE
```

Key parameters:
- `--kubernetes-version` — list available versions with `oci ce cluster-options get --cluster-option-id all`
- `--vcn-id` — the VCN the cluster lives in
- `--service-lb-subnet-ids` — subnets used by load balancers created via `type: LoadBalancer` Services
- `--endpoint-config` — controls whether the Kubernetes API endpoint is public or private

### List and Inspect Clusters

```bash
oci ce cluster list --compartment-id <compartment-ocid> --output table
oci ce cluster get --cluster-id <cluster-ocid>

# List available Kubernetes versions for a cluster
oci ce cluster-options get --cluster-option-id all \
  --query 'data."kubernetes-versions"'
```

### Delete a Cluster

```bash
oci ce cluster delete --cluster-id <cluster-ocid>
```

This does not delete node pool instances or associated VCN resources — clean those up separately.

## Node Pools

```bash
# Create a node pool
oci ce node-pool create \
  --compartment-id <compartment-ocid> \
  --cluster-id <cluster-ocid> \
  --name workers \
  --kubernetes-version v1.29.1 \
  --node-shape VM.Standard.E4.Flex \
  --node-shape-config '{"ocpus":2,"memoryInGBs":16}' \
  --node-config-details '{
    "size":3,
    "placementConfigs":[
      {"availabilityDomain":"<AD-name>","subnetId":"<worker-subnet-ocid>"}
    ]
  }' \
  --node-source-details '{
    "sourceType":"IMAGE",
    "imageId":"<oke-node-image-ocid>"
  }' \
  --wait-for-state ACTIVE

oci ce node-pool list --compartment-id <compartment-ocid> --cluster-id <cluster-ocid> --output table
oci ce node-pool get --node-pool-id <node-pool-ocid>

# Scale a node pool (update the size)
oci ce node-pool update \
  --node-pool-id <node-pool-ocid> \
  --node-config-details '{
    "size":5,
    "placementConfigs":[
      {"availabilityDomain":"<AD-name>","subnetId":"<worker-subnet-ocid>"}
    ]
  }'

oci ce node-pool delete --node-pool-id <node-pool-ocid>
```

Find OKE node images with:

```bash
oci compute image list \
  --compartment-id <tenancy-ocid> \
  --shape VM.Standard.E4.Flex \
  --operating-system "Oracle Linux" \
  --operating-system-version "8" \
  --output table
```

## Kubeconfig

```bash
oci ce cluster create-kubeconfig \
  --cluster-id <cluster-ocid> \
  --file ~/.kube/config \
  --region <region> \
  --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT
```

`--kube-endpoint` can be `PUBLIC_ENDPOINT`, `PRIVATE_ENDPOINT`, or `VCN_HOSTNAME`. After this, `kubectl` uses the merged context automatically:

```bash
kubectl config get-contexts
kubectl get nodes
kubectl get pods --all-namespaces
```

## Workload Management (kubectl)

Once kubeconfig is configured, standard `kubectl` commands apply:

```bash
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl get services
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/bash
kubectl delete pod <pod-name>
```

## Node and Cluster Upgrades

```bash
# Upgrade the control plane
oci ce cluster update \
  --cluster-id <cluster-ocid> \
  --kubernetes-version v1.30.1

# Upgrade a node pool (rolling replacement)
oci ce node-pool update \
  --node-pool-id <node-pool-ocid> \
  --kubernetes-version v1.30.1
```

Upgrade the control plane before upgrading node pools; you can only upgrade one minor version at a time.

## Beyond the basics

Run `oci ce --help` for the full subcommand list. OKE also supports virtual node pools (serverless nodes), cluster add-ons (`oci ce addon`), and work requests (`oci ce work-request`). For private clusters behind a bastion, configure `--kube-endpoint PRIVATE_ENDPOINT` and use OCI Bastion service or a jump host.
