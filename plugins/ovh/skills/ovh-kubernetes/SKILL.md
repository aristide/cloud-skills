---
name: ovh-kubernetes
description: "Use when the user needs to manage OVHcloud Managed Kubernetes Service (MKS) — OVH MKS clusters are provisioned via the OVH API, control panel, or Terraform; once running, use kubectl with a downloaded kubeconfig."
---

# OVHcloud Managed Kubernetes Service (MKS)

OVH Managed Kubernetes Service is **not** managed through the OpenStack client (`openstack`). Clusters are provisioned via the **OVH API**, the **OVH control panel**, or **Terraform**, and then driven with standard `kubectl` once you download the kubeconfig.

## Provision a Cluster — OVH Control Panel

For a quick start:

1. Log in at [https://www.ovh.com/manager](https://www.ovh.com/manager)
2. Navigate to **Public Cloud > \<project\> > Managed Kubernetes Service**
3. Click **Create a cluster**, pick a region, Kubernetes version, and node flavors
4. Once `READY`, download the kubeconfig from the cluster's detail page

## Provision a Cluster — Terraform `ovh` Provider

```hcl
terraform {
  required_providers {
    ovh = { source = "ovh/ovh" }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_app_key
  application_secret = var.ovh_app_secret
  consumer_key       = var.ovh_consumer_key
}

resource "ovh_cloud_project_kube" "my_cluster" {
  service_name = var.ovh_project_id   # OVH Public Cloud project ID
  name         = "my-cluster"
  region       = "GRA7"
  version      = "1.29"
}

resource "ovh_cloud_project_kube_nodepool" "default" {
  service_name  = var.ovh_project_id
  kube_id       = ovh_cloud_project_kube.my_cluster.id
  name          = "default-pool"
  flavor_name   = "b3-8"
  desired_nodes = 3
  min_nodes     = 1
  max_nodes     = 5
  autoscale     = true
}

# Write kubeconfig to a local file
resource "local_file" "kubeconfig" {
  content  = ovh_cloud_project_kube.my_cluster.kubeconfig
  filename = "${path.module}/kubeconfig.yaml"
}
```

Apply with `terraform init && terraform apply`.

## Download Kubeconfig — OVH API

```bash
# Using curl + jq; replace PROJECT_ID and CLUSTER_ID with your values
curl -s -X POST \
  "https://api.ovh.com/v1/cloud/project/${PROJECT_ID}/kube/${CLUSTER_ID}/kubeconfig" \
  -H "X-Ovh-Application: ${OVH_APP_KEY}" \
  -H "X-Ovh-Consumer: ${OVH_CONSUMER_KEY}" \
  -H "X-Ovh-Timestamp: $(date +%s)" \
  -H "X-Ovh-Signature: ..." \
  | jq -r '.content' > kubeconfig.yaml
```

In practice, use the OVH Python SDK or the control panel download button to avoid manually computing HMAC signatures.

## Using kubectl Once You Have the Kubeconfig

```bash
# Point kubectl at the downloaded config
export KUBECONFIG=/path/to/kubeconfig.yaml

# Verify connection
kubectl cluster-info
kubectl get nodes

# Deploy a workload
kubectl apply -f my-app.yaml

# Scale a deployment
kubectl scale deployment my-app --replicas=3

# Check pod status
kubectl get pods -A

# View cluster events
kubectl get events --sort-by='.lastTimestamp'
```

## Manage Node Pools

Node pool scaling is done via the OVH control panel, OVH API, or Terraform (`ovh_cloud_project_kube_nodepool` resource). The autoscaler (if enabled) adjusts node count automatically within your `min_nodes`/`max_nodes` bounds.

## Beyond the basics

See the OVH MKS documentation at [https://help.ovhcloud.com/csm/en-gb-public-cloud-kubernetes](https://help.ovhcloud.com/csm/en-gb-public-cloud-kubernetes) and the Terraform OVH provider docs at [https://registry.terraform.io/providers/ovh/ovh/latest/docs](https://registry.terraform.io/providers/ovh/ovh/latest/docs). For running self-managed Kubernetes on plain OVH instances, see the `ovh-compute` skill.
