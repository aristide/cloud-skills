---
name: vultr-containers
description: "Use when the user needs to manage Vultr Container Registry — create registries, push and pull images, manage repositories, and get Docker credentials. Note: Vultr has no managed container-run service; use VKE (vultr-kubernetes) to run containers."
---

# Vultr Containers

## What Vultr Offers (and What It Does Not)

Vultr provides a **Container Registry** — a private OCI-compatible image registry you can push to and pull from. All registry commands use `vultr-cli container-registry ...`.

Vultr does **not** offer a managed container-run service (no equivalent of Cloud Run, Fargate, or App Platform). To run containers in production, deploy them on:
- **VKE (Vultr Kubernetes Engine)** — recommended; see the `vultr-kubernetes` skill.
- **A plain instance** — install Docker or Podman and run containers directly.

## Container Registry

### List plans and regions

```bash
vultr-cli container-registry plans
vultr-cli container-registry regions
```

Available plans: `start_up`, `business`, `premium` (storage and bandwidth differ by plan).

### Create a registry

```bash
vultr-cli container-registry create \
  --name   "my-registry" \
  --region sjc \
  --plan   start_up \
  --public false
```

`--public true` makes all images publicly pullable without authentication.

### List, inspect, update, delete

```bash
vultr-cli container-registry list
vultr-cli container-registry get    <registry-id>
vultr-cli container-registry update <registry-id> --plan business
vultr-cli container-registry delete <registry-id>
```

## Docker Credentials

Get Docker login credentials for a registry:

```bash
vultr-cli container-registry credentials docker <registry-id>
```

This prints a `docker login` command with the registry's hostname, username, and password. Run the printed command to authenticate, then push/pull normally:

```bash
# After running the credentials command and logging in:
docker build -t <registry-hostname>/myapp:latest .
docker push    <registry-hostname>/myapp:latest
docker pull    <registry-hostname>/myapp:latest
```

## Repository Management

```bash
# List all repositories in a registry
vultr-cli container-registry repository list <registry-id>

# Inspect a specific repository
vultr-cli container-registry repository get <registry-id> <repository-name>

# Update repository description
vultr-cli container-registry repository update <registry-id> <repository-name>

# Delete a repository (removes all its tags/images)
vultr-cli container-registry repository delete <registry-id> <repository-name>
```

## Using the Registry with VKE

Once you have pushed an image, create a Kubernetes pull secret and reference it in your workload:

```bash
# 1. Get credentials
vultr-cli container-registry credentials docker <registry-id>
# Note the registry hostname, username, and password from the output

# 2. Create a pull secret in your cluster
kubectl create secret docker-registry vultr-registry \
  --docker-server=<registry-hostname> \
  --docker-username=<username> \
  --docker-password=<password>

# 3. Reference it in your Pod/Deployment spec
# spec:
#   imagePullSecrets:
#     - name: vultr-registry
#   containers:
#     - image: <registry-hostname>/myapp:latest
```

## Beyond the basics

Run `vultr-cli container-registry --help` for the full flag reference. For running containers without Kubernetes, see the `vultr-compute` skill (create an instance, install Docker, and run `docker run ...`).
