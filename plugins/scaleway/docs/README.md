# Documentation

Welcome to the documentation for **Scaleway (`scw` CLI)**. This documentation is written and organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://www.scaleway.com/en/docs/scaleway-cli/quickstart/)** — step-by-step lessons that walk you through installing, configuring, and using the `scw` CLI from scratch.
- **[Guides](https://www.scaleway.com/en/docs/)** — task-oriented how-to guides covering specific Scaleway products and workflows.
- **[Reference](https://cli.scaleway.com/)** — the full `scw` command reference. See also: [API](https://www.scaleway.com/en/developers/api/) · [regions](https://www.scaleway.com/en/product-availability-by-region/) · [pricing](https://www.scaleway.com/en/pricing/)

## Getting help

- 🖥️ [Console / control panel](https://console.scaleway.com)
- 📡 [Service status](https://status.scaleway.com)
- 🐛 [Issues / support](https://github.com/scaleway/scaleway-cli/issues)

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
