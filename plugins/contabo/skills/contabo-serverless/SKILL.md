---
name: contabo-serverless
description: "Use when the user needs to run serverless functions on Contabo — note that Contabo does not offer a serverless/FaaS product, so this skill explains the alternatives."
---

# Contabo Serverless

**Contabo does not offer a serverless functions (FaaS) product.** The `cntb` CLI has no function, trigger, or event-source commands.

## Alternatives

### Self-host a FaaS framework on a Contabo instance

Deploy an open-source FaaS platform on a Contabo VPS (see `contabo-compute`):

- **OpenFaaS** — Docker/Kubernetes-based, supports any language via function containers
- **Knative** — runs on Kubernetes (see `contabo-kubernetes`)
- **Fission** — fast cold-starts on Kubernetes

### Use an external serverless provider

If you only need serverless functions and want a fully managed experience, use a dedicated provider alongside your Contabo infrastructure:

- **Cloudflare Workers** — edge functions with a generous free tier
- **AWS Lambda** — invoke functions from your Contabo instance via the AWS SDK/CLI
- **Vercel / Netlify Functions** — suitable for frontend-adjacent workloads

### Scheduled scripts as a lightweight alternative

For simple cron-style tasks, run scripts directly on a Contabo instance using `cron`:

```bash
# Edit crontab on the instance
crontab -e

# Example: run a script every 5 minutes
*/5 * * * * /home/user/scripts/my-task.sh >> /var/log/my-task.log 2>&1
```

For container-based workloads, see the `contabo-containers` skill.
