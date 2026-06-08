---
name: contabo-kubernetes
description: "Use when the user needs to run Kubernetes on Contabo — note that Contabo does not offer managed Kubernetes, so this skill explains how to self-host it on Contabo instances."
---

# Contabo Kubernetes

**Contabo does not offer a managed Kubernetes (KaaS) product.** The `cntb` CLI has no cluster, node-pool, or kubeconfig commands.

## Running Kubernetes yourself on Contabo

You can self-host any Kubernetes distribution on Contabo VPS/VDS instances. Common approaches:

### kubeadm (vanilla upstream)

Provision one or more instances (see `contabo-compute`), then bootstrap the cluster with `kubeadm`:

```bash
# On each node (after SSH-ing in)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16   # control-plane only
sudo kubeadm join <control-plane-ip>:6443 --token ... # worker nodes
```

### k3s (lightweight, single-binary)

```bash
# Control plane
curl -sfL https://get.k3s.io | sh -

# Worker (use token from /var/lib/rancher/k3s/server/node-token on control plane)
curl -sfL https://get.k3s.io | K3S_URL=https://<cp-ip>:6443 K3S_TOKEN=<token> sh -
```

### MicroK8s (Ubuntu snap)

```bash
sudo snap install microk8s --classic
sudo microk8s status --wait-ready
```

## Recommended instance sizing

| Role | Minimum | Recommended |
|---|---|---|
| Control plane | 2 vCPU, 2 GB RAM | 4 vCPU, 4 GB RAM |
| Worker node | 2 vCPU, 4 GB RAM | 4+ vCPU, 8 GB RAM |

Use the `contabo-compute` skill to provision instances, and the `contabo-networking` skill to set up a private network between nodes.

## After cluster creation

Use standard `kubectl` and Helm — there is nothing Contabo-specific once the cluster is running.

```bash
kubectl get nodes
kubectl apply -f my-deployment.yaml
helm install my-release my-chart/
```
