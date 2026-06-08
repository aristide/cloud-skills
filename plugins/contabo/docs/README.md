# Documentation

Welcome to the documentation for **Contabo (`cntb` CLI)**. This documentation is written and organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://github.com/contabo/cntb#getting-started)** — step-by-step walkthrough to install `cntb`, configure credentials, and run your first commands against the Contabo API.
- **[Guides](https://help.contabo.com)** — task-oriented how-to articles covering the control panel, API access, billing, and product-specific workflows.
- **[Reference](https://github.com/contabo/cntb)** — the full `cntb` reference. See also: [API](https://api.contabo.com/) · [regions](https://contabo.com/en/locations/) · [pricing](https://contabo.com/en/pricing/)

## Getting help

- 🖥️ [Control panel](https://my.contabo.com)
- 📡 [Service status](https://contabo-status.com)
- 🐛 [Issues / support](https://github.com/contabo/cntb/issues)

## Concepts & gotchas

- **Subscription billing — cancel vs. delete.** Contabo products are subscriptions. Stopping a running instance does not end billing. To stop being charged, you must *cancel* the subscription (`cntb cancel instance <id>`), not merely delete a record. Cancellation takes effect at the end of the current billing period.
- **Two separate credential pairs for the API.** The Contabo API uses OAuth2 and requires four values: a *Client ID* and *Client Secret* (generated in the control panel under Account → API) **plus** an *API User* (your account email) and an *API Password* (a distinct password set in the control panel — not your login password). All four are required; missing any one causes auth failures.
- **DNS is managed in the control panel only — `cntb` has no DNS commands.** DNS zones and records are configured through the Contabo control panel (Network Services → DNS Management). The REST API at `api.contabo.com` does expose DNS endpoints, but the `cntb` CLI does not implement any DNS subcommands (the `cmd/` tree contains no DNS module). If you need to automate DNS changes, call the REST API directly.
- **No managed Kubernetes, containers, or serverless.** Contabo offers VPS, VDS, dedicated servers, and S3-compatible object storage. There is no managed Kubernetes service, container registry, or serverless platform — the platform is infrastructure-focused (IaaS).
- **Region codes used by `cntb`.** When creating instances, regions are specified as coarse slugs: `EU`, `US-central`, `US-east`, `US-west`, `SIN` (Singapore), `JPN` (Japan), `AUS` (Australia), `IND` (India). Use `cntb get datacenters` to list available options.
