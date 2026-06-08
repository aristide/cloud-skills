# Contabo — Reference & Documentation

Curated links to the official Contabo documentation for the `cntb` CLI. The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't cover.

## CLI

- CLI reference & README (all commands): <https://github.com/contabo/cntb>
- Install / upgrade (releases): <https://github.com/contabo/cntb/releases>
- Authentication & configuration (README — "Getting Started"): <https://github.com/contabo/cntb#getting-started>
- Output formatting / filtering (README — "Examples"): <https://github.com/contabo/cntb#examples>

## API

- REST API reference (interactive OpenAPI docs): <https://api.contabo.com/>
- API authentication — obtain OAuth2 credentials (control panel): <https://my.contabo.com/api/details>
- API access guide (help article): <https://help.contabo.com/en/support/solutions/articles/103000270527-how-can-i-access-the-contabo-api->
- API documentation index (help section): <https://help.contabo.com/en/support/solutions/103000250584>

## Platform

- Console / control panel: <https://my.contabo.com>
- Regions & data center locations: <https://contabo.com/en/locations/>
- Pricing: <https://contabo.com/en/pricing/>
- Service health / status: <https://contabo-status.com>
- Object storage limits (quotas): <https://help.contabo.com/en/support/solutions/articles/103000275478-what-limits-are-there-on-object-storage->
- Help center: <https://help.contabo.com>

## Concepts & gotchas

- **Subscription billing — cancel vs. delete.** Contabo products are subscriptions. Stopping a running instance does not end billing. To stop being charged, you must *cancel* the subscription (`cntb cancel instance <id>`), not merely delete a record. Cancellation takes effect at the end of the current billing period.
- **Two separate credential pairs for the API.** The Contabo API uses OAuth2 and requires four values: a *Client ID* and *Client Secret* (generated in the control panel under Account → API) **plus** an *API User* (your account email) and an *API Password* (a distinct password set in the control panel — not your login password). All four are required; missing any one causes auth failures.
- **DNS is managed in the control panel only — `cntb` has no DNS commands.** DNS zones and records are configured through the Contabo control panel (Network Services → DNS Management). The REST API at `api.contabo.com` does expose DNS endpoints, but the `cntb` CLI does not implement any DNS subcommands (the `cmd/` tree contains no DNS module). If you need to automate DNS changes, call the REST API directly.
- **No managed Kubernetes, containers, or serverless.** Contabo offers VPS, VDS, dedicated servers, and S3-compatible object storage. There is no managed Kubernetes service, container registry, or serverless platform — the platform is infrastructure-focused (IaaS).
- **Region codes used by `cntb`.** When creating instances, regions are specified as coarse slugs: `EU`, `US-central`, `US-east`, `US-west`, `SIN` (Singapore), `JPN` (Japan), `AUS` (Australia), `IND` (India). Use `cntb get datacenters` to list available options.
