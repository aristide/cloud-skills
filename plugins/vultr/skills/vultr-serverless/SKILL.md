---
name: vultr-serverless
description: "Use when the user asks about serverless functions (FaaS) on Vultr — to clarify that Vultr does not offer a managed functions product and to suggest the right alternative."
---

# Vultr Serverless Functions

## Not offered

Vultr does **not** have a managed serverless functions (FaaS) product. There is no `vultr-cli functions` command and no equivalent of AWS Lambda, Google Cloud Functions, or Cloudflare Workers in the Vultr product line.

## Alternatives on Vultr

### Run your own function runtime on a Vultr instance

Deploy any open-source FaaS framework on a standard compute instance:

- **OpenFaaS** — Kubernetes-native; deploy on VKE (`vultr-kubernetes` skill) with `helm install openfaas`.
- **Fission** — Another Kubernetes-native FaaS; works on VKE.
- **Knative Serving** — Serverless workloads on Kubernetes; works on VKE.

```bash
# Example: deploy OpenFaaS on an existing VKE cluster
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm install openfaas openfaas/openfaas \
  --namespace openfaas \
  --set functionNamespace=openfaas-fn \
  --set generateBasicAuth=true
```

### Use a Vultr instance as a lightweight functions host

For simpler use cases, run a small HTTP server (Node.js, Python FastAPI, Go `net/http`) on a `vc2-1c-1gb` instance behind a load balancer:

```bash
vultr-cli instance create \
  --region ewr --plan vc2-1c-1gb --os 2284 \
  --host fn-host --label "functions"
```

### Use an external FaaS provider

If you need a fully managed FaaS product, consider a provider that offers one (Cloudflare Workers, AWS Lambda, Vercel Functions) and call Vultr-hosted backends from there.

## Summary

| Need | Recommendation |
|------|----------------|
| Kubernetes-based FaaS | OpenFaaS or Knative on VKE (`vultr-kubernetes`) |
| Simple HTTP handler | Instance + `vultr-compute` |
| Fully managed FaaS | External provider (not Vultr) |

If Vultr adds a serverless product in the future, check the [Vultr product page](https://www.vultr.com/products/) and update this skill.
