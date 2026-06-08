---
name: digitalocean-containers
description: "Use when the user needs to deploy containerised applications on DigitalOcean App Platform or manage images in DigitalOcean Container Registry (DOCR)."
---

# DigitalOcean Containers

DigitalOcean offers two container-focused services: **App Platform** for running apps from a spec without managing servers, and **Container Registry (DOCR)** for storing private container images. App Platform commands are `doctl apps ...`; registry commands are `doctl registry ...`. See the `digitalocean-setup` skill for auth.

## App Platform

App Platform deploys apps from a spec file (YAML). It supports containers, static sites, workers, and jobs.

### Minimal app spec

Create `app.yaml`:

```yaml
name: my-app
region: nyc
services:
  - name: web
    image:
      registry_type: DOCKER_HUB
      registry: library
      repository: nginx
      tag: latest
    http_port: 80
    instance_size_slug: basic-xxs
    instance_count: 1
```

### Create and deploy

```bash
doctl apps create --spec app.yaml
```

### List and inspect

```bash
doctl apps list
doctl apps list --format ID,Spec.Name,DefaultIngress,ActiveDeployment.Phase --no-header

doctl apps get <app-id>
```

### View deployments and logs

```bash
# List deployments for an app
doctl apps list-deployments <app-id>

# Get deployment details
doctl apps get-deployment <app-id> <deployment-id>

# Stream component logs
doctl apps logs <app-id> --component web --follow
```

### Update the spec and redeploy

```bash
doctl apps update <app-id> --spec app.yaml

# Force a new deployment without changing the spec
doctl apps create-deployment <app-id>
```

### Delete

```bash
doctl apps delete <app-id>
doctl apps delete <app-id> --force
```

## Container Registry (DOCR)

Each DigitalOcean account can have one registry (the name is globally unique). Images are stored per repository within it.

### Create and inspect

```bash
# Create the registry (do once per account; name must be globally unique)
doctl registry create my-registry --subscription-tier basic

# Get registry info
doctl registry get
```

### Authenticate Docker to the registry

```bash
doctl registry login
# This configures Docker's credential store; you can then docker push/pull
```

### Push an image

```bash
docker tag my-image registry.digitalocean.com/my-registry/my-image:v1
docker push registry.digitalocean.com/my-registry/my-image:v1
```

### List repositories and tags

```bash
doctl registry repository list
doctl registry repository list-tags my-image
```

### Garbage-collect unreferenced layers

```bash
doctl registry garbage-collection start --include-untagged-manifests
doctl registry garbage-collection get-active
```

### Delete

```bash
# Delete a tag (marks manifest for GC)
doctl registry repository delete-tag my-image v1

# Delete an entire repository
doctl registry repository delete-manifest my-image <digest>

# Delete the registry (all images gone — irreversible)
doctl registry delete
```

### Integrate registry with DOKS

```bash
# Push registry credentials as a secret into your Kubernetes cluster
doctl registry kubernetes-manifest | kubectl apply -f -
```

## Beyond the basics

Run `doctl apps --help` and `doctl registry --help` for the full surface. App Platform supports GitHub/GitLab-connected deployments (source code auto-build), environment variables, managed databases, and custom domains — all configurable in the spec YAML or via `doctl apps update`.
