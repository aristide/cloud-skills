---
name: ovh-serverless
description: "Use when the user needs to run serverless workloads on OVHcloud — OVH offers Serverless Functions and Serverless Containers in some regions, managed via the OVH control panel or ovhai CLI, not the OpenStack client."
---

# OVHcloud Serverless

OVH Public Cloud does **not** expose serverless functions or serverless containers through the OpenStack client (`openstack`). OVH does offer serverless products under the **AI & Machine Learning** and **Serverless** sections of the control panel, but they are managed separately.

## OVH Serverless Functions

OVH Serverless Functions (available in select regions) lets you deploy event-driven code without managing servers. It is managed via the **OVH control panel** or the **`ovhai` CLI** (OVH AI & Serverless CLI), not via `openstack`.

```bash
# Install the ovhai CLI (Linux/macOS)
curl -fsSL https://cli.gra.ai.cloud.ovh.net/install.sh | bash

# Log in
ovhai login

# Deploy a function (example — exact syntax subject to OVH CLI version)
ovhai function create my-function \
  --image python39 \
  --handler handler.run \
  --source ./my-function/

# List functions
ovhai function list

# Invoke a function
ovhai function run my-function --input '{"key": "value"}'
```

Check the OVH documentation for current region availability and the exact `ovhai` CLI syntax, as the serverless platform is still evolving.

## OVH Serverless Containers

OVH Serverless Containers lets you run containerized workloads on demand without a Kubernetes cluster. Also managed via the control panel or `ovhai` CLI:

```bash
# Deploy a container from a registry image
ovhai app run my-app \
  --image <registry-url>/my-namespace/my-image:latest \
  --cpu 1 --memory 512

# List running apps
ovhai app list

# Delete an app
ovhai app delete my-app
```

## When to Use What

| Need | Recommended path |
|------|-----------------|
| Event-driven code (FaaS) | OVH Serverless Functions via control panel / `ovhai` |
| Serverless containers | OVH Serverless Containers via control panel / `ovhai` |
| Orchestrated containers | OVH Managed Kubernetes — see `ovh-kubernetes` skill |
| Single-host Docker workload | Instance + Docker — see `ovh-containers` skill |

## Beyond the basics

See the OVH Serverless documentation at [https://help.ovhcloud.com/csm/en-public-cloud-ai-notebooks-introduction](https://help.ovhcloud.com/csm/en-public-cloud-ai-notebooks-introduction) and the general OVH AI/Serverless section at [https://www.ovhcloud.com/en-gb/public-cloud/serverless/](https://www.ovhcloud.com/en-gb/public-cloud/serverless/). The `openstack` client is not used for these services.
