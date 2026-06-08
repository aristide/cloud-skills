---
name: ovh-serverless
description: "Use when the user needs to run serverless workloads on OVHcloud — OVH does not offer a general-purpose FaaS (functions-as-a-service); serverless-style workloads use AI Deploy (ovhai CLI) for AI/ML serving or self-managed Knative on Managed Kubernetes."
---

# OVHcloud Serverless

OVH Public Cloud does **not** expose serverless functions or serverless containers through the OpenStack client (`openstack`), and as of mid-2026 **OVHcloud does not offer a general-purpose FaaS (Function-as-a-Service) product** equivalent to AWS Lambda or Google Cloud Functions. Requests for such a service are tracked on the public roadmap but have not shipped.

What OVHcloud does offer in the "serverless" space:

1. **AI Deploy** (via `ovhai` CLI) — deploys containerised AI/ML models as long-running HTTP endpoints; not event-driven FaaS.
2. **Knative on Managed Kubernetes** — self-installed Knative on an OVH MKS cluster gives serverless-style container scaling; not an OVH-managed service.
3. **AI Endpoints** — serverless access to hosted open-source LLMs; not for running arbitrary user code.

## Option 1 — AI Deploy (ovhai CLI)

The `ovhai` CLI is OVHcloud's **AI & Machine Learning** CLI. It manages AI Notebooks, AI Training jobs, and AI Deploy apps. It has **no `function` subcommand** and is not a general FaaS tool.

Install:

```bash
# Linux/macOS
curl -fsSL https://cli.bhs.ai.cloud.ovh.net/install.sh | bash

# Log in
ovhai login
```

Deploy a containerised app (AI Deploy):

```bash
# Image is a positional argument; use --cpu or --gpu (not --memory)
ovhai app run <registry-url>/my-namespace/my-image:latest \
  --cpu 1 \
  --name my-app

# With a specific resource flavour
ovhai app run <registry-url>/my-namespace/my-image:latest \
  --flavor ai1-1-cpu \
  --name my-app

# List running apps
ovhai app list

# Delete an app
ovhai app delete <app-id>
```

Key flags for `ovhai app run`:
- Positional `<image>` — full registry path and tag (required)
- `--cpu <n>` — number of CPUs (ignored if `--gpu` is set)
- `--gpu <n>` — number of GPUs
- `--flavor <flavor>` — resource flavour (check with `ovhai capabilities flavor list`)
- `--replicas <n>` — static replica count
- `--name <name>` — human-readable name
- `--volume <spec>` — attach an OVH Object Storage container as a volume

AI Deploy is intended for serving AI/ML models, not general event-driven workloads.

## Option 2 — Knative on OVH Managed Kubernetes (self-managed)

For event-driven or scale-to-zero serverless containers, install Knative on an OVH MKS cluster yourself. OVHcloud provides a tutorial but does **not** manage Knative for you:

See [https://help.ovhcloud.com/csm/en-public-cloud-kubernetes-install-knative](https://help.ovhcloud.com/csm/en-public-cloud-kubernetes-install-knative) and the `ovh-kubernetes` skill for cluster provisioning.

## Option 3 — OpenFaaS on OVH Managed Kubernetes (self-managed)

OVHcloud also documents deploying OpenFaaS on MKS for a self-hosted FaaS experience:

See [https://help.ovhcloud.com/csm/en-public-cloud-kubernetes-install-openfaas](https://help.ovhcloud.com/csm/en-public-cloud-kubernetes-install-openfaas).

## When to Use What

| Need | Recommended path |
|------|-----------------|
| Serve an AI/ML model as an HTTP endpoint | AI Deploy via `ovhai app run` |
| Event-driven / scale-to-zero containers | Knative on OVH MKS (self-install) |
| Custom FaaS platform | OpenFaaS on OVH MKS (self-install) |
| Orchestrated containers (production) | OVH Managed Kubernetes — see `ovh-kubernetes` skill |
| Single-host Docker workload | Instance + Docker — see `ovh-containers` skill |

## Beyond the basics

- OVHcloud AI Deploy docs: [https://help.ovhcloud.com/csm/en-public-cloud-ai-deploy-getting-started](https://help.ovhcloud.com/csm/en-public-cloud-ai-deploy-getting-started)
- OVHcloud AI tools overview: [https://help.ovhcloud.com/csm/en-public-cloud-ai-faq](https://help.ovhcloud.com/csm/en-public-cloud-ai-faq)
- FaaS roadmap issue: [https://github.com/ovh/public-cloud-roadmap/issues/205](https://github.com/ovh/public-cloud-roadmap/issues/205)

The `openstack` client is not used for any of these services.
