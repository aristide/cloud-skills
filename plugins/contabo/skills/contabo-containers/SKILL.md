---
name: contabo-containers
description: "Use when the user needs to run containers on Contabo — note that Contabo does not offer a managed container runtime, so this skill explains how to run Docker on a Contabo instance."
---

# Contabo Containers

**Contabo does not offer a managed container runtime** (no Container-as-a-Service, no managed registry). The `cntb` CLI has no container or registry commands.

## Running Docker on a Contabo instance

Provision a Contabo VPS or VDS (see `contabo-compute`), then install and use Docker directly:

```bash
# Install Docker (Debian/Ubuntu)
curl -fsSL https://get.docker.com | sh

# Pull and run a container
docker pull nginx:latest
docker run -d -p 80:80 --name web nginx:latest

# View running containers
docker ps

# Stop and remove
docker stop web && docker rm web
```

### Docker Compose

```bash
# Install Compose plugin
sudo apt-get install docker-compose-plugin

# Deploy a stack
docker compose up -d
docker compose logs -f
docker compose down
```

## Container registry

Contabo provides no managed registry. Options:
- **Docker Hub** — free tier for public images, paid for private
- **GitHub Container Registry (ghcr.io)** — free for public repos
- **Self-hosted registry** — run `registry:2` as a container on a Contabo instance

```bash
# Self-hosted registry example
docker run -d -p 5000:5000 --name registry registry:2
docker tag myimage localhost:5000/myimage
docker push localhost:5000/myimage
```

## Running Kubernetes / orchestration

For multi-node container orchestration, see the `contabo-kubernetes` skill for self-hosted Kubernetes options (kubeadm, k3s, MicroK8s).
