# Documentation

Welcome to the documentation for **Vultr (`vultr-cli`)**. This documentation is organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://github.com/vultr/vultr-cli#readme)** — install `vultr-cli`, authenticate, and run your first commands against your Vultr account.
- **[Guides](https://docs.vultr.com/)** — task-focused how-to articles covering compute, storage, networking, databases, and more.
- **[Reference](https://docs.vultr.com/reference/vultr-cli)** — the full `vultr-cli` command reference. See also: [API](https://www.vultr.com/api/) · [regions](https://www.vultr.com/features/datacenter-regions/) · [pricing](https://www.vultr.com/pricing/)

## Getting help

- 🖥️ [Customer portal](https://console.vultr.com/)
- 📡 [Service status](https://status.vultr.com/)
- 🐛 [Issues / support](https://github.com/vultr/vultr-cli/issues)

## Concepts & gotchas

- **API key + IP allowlist**: Vultr enforces an IP-based access control list on API keys. Before any `vultr-cli` call works, add your current IP to the allowlist in the portal under Account → API → Access Control. Missing this is the most common cause of `403 Forbidden` errors.
- **One API key per account**: Vultr allows only one API key per account. Use Sub-Accounts or ACL scoping to limit access; the key itself grants full account access with no per-product scoping.
- **Versioned CLI release assets**: The GitHub release tarballs embed the version in the filename (e.g. `vultr-cli_v3.10.0_linux_amd64.tar.gz`). Always pin a version when scripting installs — the "latest" tarball URL pattern changes with each release.
- **Stopped instances still bill**: Powering off a Vultr instance does NOT stop billing. You must `vultr-cli instance delete <id>` to fully destroy it and end charges.
- **Object storage is S3-compatible**: Vultr Object Storage exposes an S3-compatible API. Standard S3 tools (`s3cmd`, AWS SDK, etc.) work with it. See the S3 compatibility matrix: https://docs.vultr.com/products/cloud-storage/object-storage/s3-compatibility-matrix
- **No FaaS / serverless functions**: Vultr does not offer a Functions-as-a-Service product. Compute workloads run on Cloud Compute, High Frequency, Bare Metal, or Kubernetes — plan accordingly.
- **Regions and plan IDs**: Use `vultr-cli regions list`, `vultr-cli plans list`, `vultr-cli os list` to discover the short identifiers (e.g. `ewr`, `vc2-1c-1gb`) required by `instance create` and similar commands.
