---
name: aws-kubernetes
description: "Use when the user needs to manage AWS managed Kubernetes (EKS) — create or delete clusters, manage node groups, and fetch kubeconfig credentials."
---

# AWS Managed Kubernetes (EKS)

EKS clusters can be created with the `eksctl` higher-level tool (recommended) or with the lower-level `aws eks` commands. Both approaches are shown. See the `aws-setup` skill for auth.

`eksctl` must be installed separately (`brew install eksctl` / [github.com/eksctl-io/eksctl](https://github.com/eksctl-io/eksctl)). The `aws eks` subcommands are part of the standard AWS CLI.

## Clusters — eksctl (recommended)

`eksctl` creates the VPC, subnets, node group, and IAM roles in one command.

```bash
# Create a cluster with a managed node group
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# List clusters via eksctl
eksctl get cluster --region us-east-1

# Delete cluster and all associated resources
eksctl delete cluster --name my-cluster --region us-east-1
```

## Clusters — aws eks

Use `aws eks` when you need fine-grained control or are managing clusters created outside of `eksctl`.

```bash
# Create a cluster (VPC/subnets/role must exist first)
aws eks create-cluster \
  --name my-cluster \
  --role-arn arn:aws:iam::<account-id>:role/EKSClusterRole \
  --resources-vpc-config subnetIds=<subnet-1>,<subnet-2>,securityGroupIds=<sg-id>

# List clusters
aws eks list-clusters --query 'clusters' --output table

# Describe a cluster (status, endpoint, version)
aws eks describe-cluster --name my-cluster \
  --query 'cluster.{status:status,endpoint:endpoint,version:version}' --output table

# Delete a cluster (node groups must be deleted first)
aws eks delete-cluster --name my-cluster
```

## Node Groups

```bash
# Create a managed node group
aws eks create-nodegroup \
  --cluster-name my-cluster \
  --nodegroup-name workers \
  --node-role arn:aws:iam::<account-id>:role/EKSNodeRole \
  --subnets <subnet-1> <subnet-2> \
  --instance-types t3.medium \
  --scaling-config minSize=1,maxSize=4,desiredSize=2

# List node groups
aws eks list-nodegroups --cluster-name my-cluster

# Scale an existing node group
aws eks update-nodegroup-config \
  --cluster-name my-cluster \
  --nodegroup-name workers \
  --scaling-config minSize=1,maxSize=6,desiredSize=3

# Delete a node group
aws eks delete-nodegroup --cluster-name my-cluster --nodegroup-name workers
```

## Kubeconfig

Fetch credentials and merge them into `~/.kube/config` so `kubectl` can connect:

```bash
aws eks update-kubeconfig --name my-cluster --region us-east-1

# Optionally specify a custom kubeconfig path
aws eks update-kubeconfig --name my-cluster --region us-east-1 \
  --kubeconfig ~/.kube/my-cluster.yaml

# Verify connectivity
kubectl get nodes
kubectl get namespaces
```

## Kubernetes Version Upgrades

```bash
# Check available versions
aws eks describe-addon-versions --query 'addons[0].addonVersions[0]' --output text

# Upgrade the control plane first
aws eks update-cluster-version --name my-cluster --kubernetes-version 1.30

# Then upgrade each node group
aws eks update-nodegroup-version \
  --cluster-name my-cluster \
  --nodegroup-name workers \
  --kubernetes-version 1.30
```

## Beyond the basics

Use `eksctl help`, `aws eks help`, and the [EKS documentation](https://docs.aws.amazon.com/eks/) for add-ons (CoreDNS, kube-proxy, VPC CNI), Fargate profiles, and OIDC/IRSA (IAM roles for service accounts). After connecting, drive the cluster with `kubectl`.
