---
name: ovh-containers
description: "Use when the user needs to run containers on OVHcloud Public Cloud — OVH does not offer a standalone managed container runtime (like Cloud Run or ECS); containers run on instances or via Managed Kubernetes."
---

# OVHcloud Public Cloud Containers

OVH Public Cloud does **not** offer a standalone managed container service (no equivalent of AWS ECS, Google Cloud Run, or Azure Container Instances) accessible through the OpenStack client or a dedicated OVH CLI.

## How to Run Containers on OVH Public Cloud

### Option 1 — Docker on a Compute Instance (most common)

Spin up an instance (see the `ovh-compute` skill), install Docker, and run containers directly:

```bash
# After SSH-ing into an OVH Public Cloud instance:
sudo apt-get update && sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER   # then re-login

# Run a container
docker run -d -p 80:80 --name my-app nginx

# Use Compose for multi-container workloads
docker compose up -d
```

This is fully self-managed: you handle restarts, networking, logging, and updates yourself.

### Option 2 — OVHcloud Managed Kubernetes (MKS)

For orchestrated, production-grade container workloads, provision a Managed Kubernetes cluster and deploy via `kubectl` (see the `ovh-kubernetes` skill). This is the recommended path for anything beyond a single-host setup.

### Option 3 — OVH Managed Private Registry

OVH offers a managed container registry (Harbor-based) for storing and distributing container images, available through the OVH control panel:

1. Navigate to **Public Cloud > \<project\> > Managed Private Registry**
2. Create a registry, set a plan, and note the endpoint URL
3. Log in and push images:

```bash
docker login <registry-url>
docker tag my-image:latest <registry-url>/my-namespace/my-image:latest
docker push <registry-url>/my-namespace/my-image:latest
```

The registry endpoint and credentials are found in the OVH control panel. It is not managed via the `openstack` CLI.

## Beyond the basics

If you need serverless container execution, see the `ovh-serverless` skill for what OVH currently offers in that area. For orchestration at scale, the `ovh-kubernetes` skill is the primary path on OVH Public Cloud.
