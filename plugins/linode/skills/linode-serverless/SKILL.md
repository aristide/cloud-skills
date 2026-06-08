---
name: linode-serverless
description: "Use when the user needs serverless functions (FaaS) on Linode — note that Linode does not offer a managed functions product; see alternatives below."
---

# Linode Serverless Functions

Linode does **not** offer a managed serverless functions (FaaS) product. There is no equivalent to AWS Lambda, Google Cloud Functions, or Azure Functions, and no `linode-cli functions` command group.

## Alternatives

### Option 1 — Run a functions framework on LKE

Deploy an open-source FaaS framework on Linode Kubernetes Engine (LKE):

- **OpenFaaS** — deploys via Helm onto an LKE cluster; supports any language packaged as a container.
- **Knative** — event-driven autoscaling on Kubernetes; works on LKE.
- **Fission** — Kubernetes-native FaaS; fast cold starts.

See the `linode-kubernetes` skill to create an LKE cluster, then install your chosen framework using `kubectl` or Helm.

```bash
# Example: install OpenFaaS onto an LKE cluster (after kubeconfig is set up)
helm repo add openfaas https://openfaas.github.io/faas-netes/
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm upgrade --install openfaas openfaas/openfaas \
  --namespace openfaas \
  --set functionNamespace=openfaas-fn \
  --set generateBasicAuth=true
```

### Option 2 — Long-running process on a Linode instance

For event-driven workloads that don't require auto-scaling to zero, run a lightweight HTTP server (Node.js, Python/FastAPI, Go, etc.) on a small Linode:

```bash
# Create a small Linode for a simple function server
linode-cli linodes create \
  --label fn-host \
  --type g6-nanode-1 \
  --region us-east \
  --image linode/ubuntu24.04 \
  --root_pass '<root-password>' \
  --authorized_keys "$(cat ~/.ssh/id_ed25519.pub)"
```

Expose it via a NodeBalancer (`linode-networking` skill) for high availability, or use a Cloud Firewall to restrict inbound access.

### Option 3 — External FaaS with Linode as the backend

Host your application on Linode and trigger it from an external FaaS platform (Cloudflare Workers, Vercel Edge Functions, etc.) via HTTP.

## Summary

| Need | Solution |
|---|---|
| Auto-scaling FaaS on Kubernetes | OpenFaaS / Knative on LKE (`linode-kubernetes`) |
| Simple single-host function server | Linode instance (`linode-compute`) |
| Serverless container (scale-to-zero) | Not available natively; use LKE + Knative |
