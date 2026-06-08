# Scaleway — Reference & Documentation

Curated links to the official Scaleway documentation for the `scw` CLI. The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't go into.

## CLI

- CLI reference (all commands): <https://cli.scaleway.com/>
- Install / upgrade (GitHub repo + release binaries): <https://github.com/scaleway/scaleway-cli>
- Latest releases: <https://github.com/scaleway/scaleway-cli/releases>
- Authentication & configuration (`scw init`, `scw config`): <https://cli.scaleway.com/init/> and <https://cli.scaleway.com/config/>
- Output formatting / filtering (`-o` flag, Go templates): <https://cli.scaleway.com/help/>
- Environment variables (`SCW_ACCESS_KEY`, `SCW_SECRET_KEY`, etc.): <https://www.scaleway.com/en/docs/scaleway-cli/reference-content/environment-variables/>
- Quickstart guide: <https://www.scaleway.com/en/docs/scaleway-cli/quickstart/>

## API

- REST API reference (all products): <https://www.scaleway.com/en/developers/api/>
- IAM API keys — create & manage: <https://www.scaleway.com/en/docs/iam/how-to/create-api-keys/>
- IAM concepts (policies, permission sets, applications): <https://www.scaleway.com/en/docs/iam/concepts/>

## Platform

- Console / control panel: <https://console.scaleway.com>
- Product availability by region & zone: <https://www.scaleway.com/en/product-availability-by-region/>
- Pricing (all products): <https://www.scaleway.com/en/pricing/>
- Service health / status: <https://status.scaleway.com>
- Organizations & Projects concepts: <https://www.scaleway.com/en/docs/organizations-and-projects/concepts/>

## Concepts & gotchas

- **Organization ID vs Project ID.** Every resource belongs to a *Project*; projects belong to an *Organization*. The Organization ID is the top-level billing and IAM boundary. Both are UUIDs visible in the console under *Organizations & Projects*. The CLI exposes them as `organization-id=` and `project-id=` positional args, and as `SCW_DEFAULT_ORGANIZATION_ID` / `SCW_DEFAULT_PROJECT_ID` environment variables.

- **`zone=` and `region=` are positional args, not flags.** Most `scw` commands that are scoped to a location accept `zone=fr-par-1` or `region=fr-par` as plain `key=value` positional arguments rather than `--zone` flags. Example: `scw instance server list zone=nl-ams-1`.

- **All non-flag arguments are `key=value`.** The Scaleway CLI uses a consistent `key=value` syntax for resource fields (e.g., `scw instance server create image=ubuntu_focal type=DEV1-S zone=fr-par-1`), not positional order-dependent arguments.

- **Regions and zones.** Scaleway has four regions, each with up to three availability zones:
  - `fr-par` — Paris, France (zones: `fr-par-1`, `fr-par-2`, `fr-par-3`)
  - `nl-ams` — Amsterdam, Netherlands (zones: `nl-ams-1`, `nl-ams-2`, `nl-ams-3`)
  - `pl-waw` — Warsaw, Poland (zones: `pl-waw-1`, `pl-waw-2`, `pl-waw-3`)
  - `it-mil` — Milan, Italy (zone: `it-mil-1`)
  Instances are **zonal**; most managed services (databases, Object Storage) are **regional**.

- **IAM API keys are scoped to an IAM application or user.** Since Scaleway moved to full IAM, each API key is created within IAM and attached to an application or a user with a specific set of permission sets and an optional preferred project. A single organization can have many keys with different scopes — avoid sharing one key across all scripts.

- **Config file and profile precedence.** Environment variables override the config file (`~/.config/scw/config.yaml`). The `-p <profile>` flag or `SCW_PROFILE` env var selects a named profile. `scw config info` shows the currently effective values.

- **`scw init` is interactive.** It prompts for Access Key, Secret Key, default Organization/Project, default zone, and default region, then writes the config file. For CI/CD, skip it and use environment variables or a pre-written config file.
