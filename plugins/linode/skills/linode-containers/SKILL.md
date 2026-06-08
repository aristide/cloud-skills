---
name: linode-containers
description: "Use when the user needs to run containers on Linode without managing Kubernetes themselves — note that Linode has no managed serverless-container product; see alternatives below."
---

# Linode Containers

Linode does **not** offer a managed serverless container product (no equivalent to AWS Fargate, Google Cloud Run, or Azure Container Instances). There is no `linode-cli containers` command group.

## Alternatives

### Option 1 — LKE (Linode Kubernetes Engine)

For production container workloads, LKE is the recommended path. It provides a managed Kubernetes control plane with full container orchestration:

- See the `linode-kubernetes` skill for cluster creation, node pool management, and kubeconfig setup.
- Deploy containers using standard `kubectl apply` or Helm after fetching the kubeconfig.
- Use the Linode CSI driver (pre-installed on LKE) for persistent volume claims backed by Block Storage.

### Option 2 — Docker on a Linode instance

For simpler single-host container use cases, install Docker directly on a Linode:

```bash
# 1. Create a Linode (see the linode-compute skill)
linode-cli linodes create \
  --label docker-host \
  --type g6-standard-2 \
  --region us-east \
  --image linode/ubuntu24.04 \
  --root_pass '<root-password>' \
  --authorized_keys "$(cat ~/.ssh/id_ed25519.pub)"

# 2. SSH in (use IP from: linode-cli linodes view <id>)
ssh root@<public-ip>

# 3. Install Docker (inside the Linode)
curl -fsSL https://get.docker.com | sh

# 4. Run containers
docker run -d -p 80:80 nginx
docker compose up -d   # if using Compose
```

For multi-host Docker setups, Docker Swarm can be configured manually across multiple Linode instances.

### Option 3 — Docker Compose with Cloud-init

Bootstrap Docker and start a Compose stack automatically at creation time using cloud-init user data:

```bash
USER_DATA=$(base64 <<'EOF'
#cloud-config
packages: [docker.io, docker-compose-v2]
runcmd:
  - systemctl enable --now docker
  - docker run -d -p 80:80 nginx
EOF
)

linode-cli linodes create \
  --label docker-host \
  --type g6-standard-2 \
  --region us-east \
  --image linode/ubuntu24.04 \
  --root_pass '<root-password>' \
  --metadata.user_data "$USER_DATA"
```

## Summary

| Need | Solution |
|---|---|
| Orchestrated containers (production) | LKE — `linode-kubernetes` skill |
| Single-host Docker | Docker on a Linode instance |
| Auto-start on boot | Cloud-init user data |
