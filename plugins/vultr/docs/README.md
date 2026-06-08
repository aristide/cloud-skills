# Vultr — Reference & Documentation

Curated links to the official Vultr documentation for the `vultr-cli` CLI (v3). The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't go into.

## CLI

- CLI reference (all commands): https://docs.vultr.com/reference/vultr-cli
- Reference index (CLI + Terraform provider): https://docs.vultr.com/reference
- Install / upgrade (GitHub releases — pin a version): https://github.com/vultr/vultr-cli/releases
- GitHub repository (README covers install via Homebrew, Go, Arch, Fedora, OpenBSD, Docker): https://github.com/vultr/vultr-cli
- Authentication & configuration (`VULTR_API_KEY` env var, `~/.vultr-cli.yaml` config file): https://github.com/vultr/vultr-cli#authentication

## API

- REST API v2 reference: https://www.vultr.com/api/
- API key management (one key per account, scoping, expiration, rate limits): https://docs.vultr.com/support/platform/api
- API access control list — IP allowlist (required before API calls will succeed): https://docs.vultr.com/platform/other/api/manage-api-access-control

## Platform

- Console / customer portal: https://my.vultr.com
- Regions & datacenter locations: https://www.vultr.com/features/datacenter-regions/
- Pricing: https://www.vultr.com/pricing/
- Service health / status: https://status.vultr.com/
- API & open-source changelog: https://docs.vultr.com/platform/api-opensource-changelog

## Concepts & gotchas

- **API key + IP allowlist**: Vultr enforces an IP-based access control list on API keys. Before any `vultr-cli` call works, add your current IP to the allowlist in the portal under Account → API → Access Control. Missing this is the most common cause of `403 Forbidden` errors.
- **One API key per account**: Vultr allows only one API key per account. Use Sub-Accounts or ACL scoping to limit access; the key itself grants full account access with no per-product scoping.
- **Versioned CLI release assets**: The GitHub release tarballs embed the version in the filename (e.g. `vultr-cli_v3.10.0_linux_amd64.tar.gz`). Always pin a version when scripting installs — the "latest" tarball URL pattern changes with each release.
- **Stopped instances still bill**: Powering off a Vultr instance does NOT stop billing. You must `vultr-cli instance delete <id>` to fully destroy it and end charges.
- **Object storage is S3-compatible**: Vultr Object Storage exposes an S3-compatible API. Standard S3 tools (`s3cmd`, AWS SDK, etc.) work with it. See the S3 compatibility matrix: https://docs.vultr.com/products/cloud-storage/object-storage/s3-compatibility-matrix
- **No FaaS / serverless functions**: Vultr does not offer a Functions-as-a-Service product. Compute workloads run on Cloud Compute, High Frequency, Bare Metal, or Kubernetes — plan accordingly.
- **Regions and plan IDs**: Use `vultr-cli regions list`, `vultr-cli plans list`, `vultr-cli os list` to discover the short identifiers (e.g. `ewr`, `vc2-1c-1gb`) required by `instance create` and similar commands.
