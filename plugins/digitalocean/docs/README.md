# Documentation

Welcome to the documentation for **DigitalOcean (`doctl` CLI)**. This documentation is organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://docs.digitalocean.com/reference/doctl/how-to/install/)** — step-by-step guides to install, authenticate, and take your first actions with `doctl`.
- **[Guides](https://docs.digitalocean.com/products/)** — task-oriented how-to documentation for every DigitalOcean product and workflow.
- **[Reference](https://docs.digitalocean.com/reference/doctl/reference/)** — the full `doctl` command reference. See also: [API](https://docs.digitalocean.com/reference/api/reference/) · [regions](https://docs.digitalocean.com/platform/regional-availability/) · [pricing](https://www.digitalocean.com/pricing)

## Getting help

- 🖥️ [Console / control panel](https://cloud.digitalocean.com)
- 📡 [Service status](https://status.digitalocean.com/)
- 🐛 [Issues / support](https://github.com/digitalocean/doctl/issues)

## Concepts & gotchas

- **Auth contexts** — `doctl` supports named authentication contexts (`doctl auth init --context <name>`), stored in `~/.config/doctl/config.yaml`. Switch with `doctl auth switch --context <name>` or override per command with `--access-token` / `DIGITALOCEAN_ACCESS_TOKEN`. Run `doctl auth list` to see all contexts.

- **PAT scopes** — Tokens have granular CRUD scopes (Create, Read, Update, Delete) per resource type. Scopes cannot be changed after token creation; if you need different permissions, create a new token. Read-only tokens are sufficient for `doctl` queries but write tokens are needed for creates/deletes/updates.

- **Powered-off Droplets still bill** — Shutting down or powering off a Droplet does not stop billing. Reserved CPU/RAM and the root disk continue to accrue charges. To stop billing, destroy the Droplet (and take a snapshot first if you need to restore it later).

- **No global default region** — Unlike some cloud CLIs, `doctl` has no persistent default region setting. Pass `--region <slug>` on each resource-creation command. Use `doctl compute region list` to list available slugs (e.g. `nyc3`, `sfo3`, `ams3`, `sgp1`, `fra1`).

- **Spaces = S3-compatible object storage** — The Spaces API is interoperable with the AWS S3 API, so any S3-compatible tool or SDK works against a Spaces endpoint (`<bucket>.<region>.digitaloceanspaces.com`). Spaces uses separate access keys (not PATs); generate them at <https://cloud.digitalocean.com/spaces>.

- **API rate limits** — The DigitalOcean API enforces 5 000 requests per hour and 250 requests per minute per token. Check current usage with `doctl account ratelimit`.

- **Resource quotas** — New accounts start at Tier 1 with conservative limits on Droplet count, databases, etc. Limits increase automatically as payment history builds, or immediately via prepayment. View current limits in the control panel under **Settings → Resource Limits**.
