---
name: scaleway-containers
description: "Use when the user needs to run containers on Scaleway without managing Kubernetes — Serverless Containers (deploy HTTP workloads from a registry image) and the Scaleway Container Registry (push/pull private images)."
---

# Scaleway Containers

Scaleway offers two related products: **Serverless Containers** (`scw container`) — run any Docker image as an autoscaling, pay-per-request service — and **Container Registry** (`scw registry`) — a private image registry. Both are **regional**. Confirm exact flags with `scw container --help` and `scw registry --help`.

## Container Registry

The registry stores and serves Docker images. Namespaces group related images.

```bash
# List registry namespaces
scw registry namespace list region=fr-par

# Create a namespace (private by default)
scw registry namespace create \
  name=my-images \
  region=fr-par

# Create a public namespace
scw registry namespace create \
  name=public-images \
  is-public=true \
  region=fr-par

# Get namespace details (includes the endpoint URL)
scw registry namespace get <namespace-id> region=fr-par

# Delete a namespace (removes all images inside it)
scw registry namespace delete <namespace-id> region=fr-par
```

### Authenticating Docker to the Registry

```bash
# Install the Scaleway Docker credential helper (writes docker-credential-scw)
scw registry login region=fr-par

# Or authenticate manually using your secret key
docker login rg.fr-par.scw.cloud -u nologin --password-stdin <<< "$SCW_SECRET_KEY"
```

### Push and Pull Images

The registry endpoint follows the pattern `rg.<region>.scw.cloud/<namespace-name>`.

```bash
# Tag a local image
docker tag my-app:latest rg.fr-par.scw.cloud/my-images/my-app:latest

# Push to the registry
docker push rg.fr-par.scw.cloud/my-images/my-app:latest

# Pull from the registry
docker pull rg.fr-par.scw.cloud/my-images/my-app:latest
```

### List Images and Tags

```bash
scw registry image list namespace-id=<namespace-id> region=fr-par
scw registry image get <image-id> region=fr-par
scw registry tag list image-id=<image-id> region=fr-par
scw registry tag delete <tag-id> region=fr-par
```

## Serverless Containers

Serverless Containers run a Docker image as a managed HTTP service that scales to zero.

### Namespaces

Containers are grouped in namespaces (logical environments):

```bash
scw container namespace list region=fr-par

scw container namespace create \
  name=my-namespace \
  region=fr-par

scw container namespace get <namespace-id> region=fr-par

# Set shared environment variables for all containers in the namespace
scw container namespace update <namespace-id> \
  environment-variables.DB_HOST=db.example.com \
  region=fr-par

scw container namespace delete <namespace-id> region=fr-par
```

### Create and Deploy a Container

```bash
# Create a container (references an image already in the registry)
scw container container create \
  name=my-container \
  namespace-id=<namespace-id> \
  registry-image=rg.fr-par.scw.cloud/my-images/my-app:latest \
  port=8080 \
  memory-limit=256 \
  min-scale=0 \
  max-scale=5 \
  region=fr-par

# Deploy the container (makes it live / updates it)
scw container container deploy <container-id> region=fr-par

# List containers
scw container container list namespace-id=<namespace-id> region=fr-par

# Get details (includes the HTTPS endpoint URL)
scw container container get <container-id> region=fr-par

# Update a container (e.g. new image tag or env var)
scw container container update <container-id> \
  registry-image=rg.fr-par.scw.cloud/my-images/my-app:v2 \
  region=fr-par

# Delete a container
scw container container delete <container-id> region=fr-par
```

Key creation arguments:
- `registry-image=<url>` — Full image URL including tag
- `port=<n>` — Port the container listens on (default 8080)
- `memory-limit=<mb>` — RAM in MB (e.g. 128, 256, 512, 1024)
- `min-scale=0` — Scale to zero when idle (saves cost)
- `max-scale=<n>` — Maximum concurrent instances
- `environment-variables.KEY=value` — Runtime env vars
- `secret-environment-variables.0.key=SECRET` + `.0.value=<val>` — Injected as env vars, not stored in plaintext

### Container Logs

```bash
# Follow the logs for a container
scw container container get <container-id> region=fr-par   # check status

# Logs are available in the Scaleway console; the CLI get/list commands show current state
```

## Beyond the basics

Use `scw container --help` and `scw registry --help` for the full argument lists. For workloads requiring persistent state, cluster networking, or CronJob-style scheduling, consider Scaleway Kubernetes Kapsule (`scaleway-kubernetes`). For event-driven compute without an HTTP server, see Serverless Functions (`scaleway-serverless`).
