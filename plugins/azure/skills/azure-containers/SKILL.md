---
name: azure-containers
description: "Use when the user needs to run containers on Azure without managing Kubernetes — Azure Container Instances for quick runs, Azure Container Apps for scalable apps, and Azure Container Registry for storing images."
---

# Azure Containers

Azure offers three container surfaces without full Kubernetes management: **Container Instances** (ACI) for one-off or short-lived containers, **Container Apps** (ACA) for scalable HTTP/event-driven apps, and **Container Registry** (ACR) for storing images.

## Azure Container Registry (ACR)

ACR is a private Docker-compatible registry for storing and building images.

### Create a registry

```bash
az acr create \
  --resource-group <rg> \
  --name <registry-name> \
  --sku Basic \
  --location <region>
```

Registry names must be globally unique. SKUs: `Basic`, `Standard`, `Premium`.

### Log in and push/pull images

```bash
# Authenticate Docker to the registry
az acr login --name <registry-name>

# Tag and push a local image
docker tag myapp:latest <registry-name>.azurecr.io/myapp:latest
docker push <registry-name>.azurecr.io/myapp:latest

# Build an image in ACR from a local Dockerfile (no local Docker required)
az acr build \
  --registry <registry-name> \
  --image myapp:v1 \
  .
```

### List registries and repositories

```bash
az acr list -g <rg> -o table
az acr repository list --name <registry-name> -o table
az acr repository show-tags --name <registry-name> --repository myapp -o table
```

### Delete a registry

```bash
az acr delete -g <rg> -n <registry-name> --yes
```

## Azure Container Instances (ACI)

ACI runs containers directly — no cluster required. Ideal for batch jobs, CI runners, or quick tests.

### Create and start a container

```bash
az container create \
  --resource-group <rg> \
  --name <container-name> \
  --image <registry-name>.azurecr.io/myapp:latest \
  --cpu 1 \
  --memory 1.5 \
  --ports 80 \
  --dns-name-label <unique-dns-label> \
  --location <region>
```

Common flags:
- `--image` — any Docker-compatible image URI
- `--registry-login-server` / `--registry-username` / `--registry-password` — private registry credentials
- `--environment-variables KEY=VALUE` — env vars (use `--secure-environment-variables` for secrets)
- `--os-type` — `Linux` (default) or `Windows`
- `--restart-policy` — `Always`, `OnFailure`, or `Never`

### List, show, and stream logs

```bash
az container list -g <rg> -o table
az container show -g <rg> -n <container-name> \
  --query '{state:instanceView.state,fqdn:ipAddress.fqdn}' -o table
az container logs -g <rg> -n <container-name>
az container logs -g <rg> -n <container-name> --follow   # stream live
```

### Delete a container instance

```bash
az container delete -g <rg> -n <container-name> --yes
```

## Azure Container Apps (ACA)

Container Apps is a serverless platform for HTTP APIs, microservices, and event-driven workloads with built-in autoscaling. It requires the `containerapp` extension.

### Install the extension

```bash
az extension add --name containerapp --upgrade
```

### Create a Container Apps environment

```bash
az containerapp env create \
  --resource-group <rg> \
  --name <env-name> \
  --location <region>
```

### Deploy a container app

```bash
az containerapp create \
  --resource-group <rg> \
  --environment <env-name> \
  --name <app-name> \
  --image <registry-name>.azurecr.io/myapp:latest \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 5
```

Common flags:
- `--ingress external` — publicly reachable; `internal` for VNet-only
- `--target-port` — port the container listens on
- `--min-replicas` / `--max-replicas` — autoscale bounds
- `--env-vars KEY=VALUE` — environment variables
- `--registry-server` / `--registry-username` / `--registry-password` — private registry

### List, show logs, and delete

```bash
az containerapp list -g <rg> -o table
az containerapp logs show -g <rg> -n <app-name> --follow
az containerapp delete -g <rg> -n <app-name> --yes
```

### Update (redeploy with a new image)

```bash
az containerapp update \
  --resource-group <rg> \
  --name <app-name> \
  --image <registry-name>.azurecr.io/myapp:v2
```

## Beyond the basics

Run `az container --help`, `az containerapp --help`, and `az acr --help` for the full subcommand lists. Advanced ACR topics include geo-replication (`az acr replication`), image signing, and vulnerability scanning. For multi-container workloads requiring orchestration, see the `azure-kubernetes` skill.
