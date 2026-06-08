---
name: contabo-dns
description: "Use when the user needs to manage DNS for resources hosted on Contabo — note that Contabo does not offer managed DNS, so this skill explains the alternatives."
---

# Contabo DNS

**Contabo does not offer a managed DNS product.** The `cntb` CLI has no DNS zone or record commands.

## Alternatives

Point your domain's DNS to Contabo instance IPs using your **domain registrar's DNS panel** or an **external DNS provider**:

- **Registrar DNS panel** — log in to wherever you registered the domain (Namecheap, GoDaddy, OVH, etc.) and add an `A` record pointing to the instance's public IP.
- **Cloudflare DNS** (free tier) — transfer your zone to Cloudflare for a feature-rich DNS UI/API. Use the Cloudflare CLI (`flarectl`) or Terraform provider to manage records as code.
- **Route 53 (AWS), Google Cloud DNS, Hetzner DNS** — all offer free or low-cost zones with CLI/API access.

## Finding a Contabo instance IP

```bash
cntb get instance <instance-id> -o json
# look for .ipConfig.v4.ip in the output
```

Use that IP as the value when creating an `A` record in your DNS provider of choice.

## Provisioning instances with a known IP

To get a predictable IP for DNS use, ask about a **VIP** (Virtual IP) via the Contabo Customer Control Panel or `cntb get vips` — see the `contabo-networking` skill.
