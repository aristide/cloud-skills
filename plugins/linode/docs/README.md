# Linode — Reference & Documentation

Curated links to the official Linode (Akamai Connected Cloud) documentation for the `linode-cli` CLI. The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't go into.

## CLI

- CLI reference (all commands): <https://techdocs.akamai.com/cloud-computing/docs/cli-1>
- Install / upgrade (getting started): <https://techdocs.akamai.com/cloud-computing/docs/getting-started-with-the-linode-cli>
- Authentication & configuration: <https://techdocs.akamai.com/cloud-computing/docs/getting-started-with-the-linode-cli>
- Output formatting / filtering: <https://techdocs.akamai.com/cloud-computing/docs/getting-started-with-the-linode-cli>
- Official GitHub repository (source, issues, releases): <https://github.com/linode/linode-cli>
- CLI command reference via API docs: <https://techdocs.akamai.com/linode-api/reference/cli>

## API

- REST API reference (Linode API v4): <https://techdocs.akamai.com/linode-api/reference/api>
- API authentication / personal access tokens: <https://techdocs.akamai.com/linode-api/reference/get-started>
- API rate limits: <https://techdocs.akamai.com/linode-api/reference/rate-limits>

## Platform

- Console / Cloud Manager: <https://cloud.linode.com>
- Personal Access Token management: <https://cloud.linode.com/profile/tokens>
- Regions & availability (choose a data center): <https://techdocs.akamai.com/cloud-computing/docs/how-to-choose-a-data-center>
- Pricing: <https://www.linode.com/pricing/>
- Service health / status: <https://status.linode.com>
- Billing model: <https://techdocs.akamai.com/cloud-computing/docs/understanding-how-billing-works>
- Object Storage quotas & limits: <https://techdocs.akamai.com/cloud-computing/docs/object-storage-product-limits>

## Concepts & gotchas

- **Personal Access Token (PAT) required**: generate one at <https://cloud.linode.com/profile/tokens> with the scopes you need (Read/Write) before running `linode-cli configure` or setting `LINODE_CLI_TOKEN`.
- **Hyphenated subcommands**: most resource groups use hyphenated names in the CLI (e.g. `linode-cli object-storage`, `linode-cli node-balancers`). Tab-complete or run `linode-cli --help` to discover the exact names.
- **Shut-down Linodes still bill**: a powered-off Linode continues to accrue charges because its resources (RAM, IP, storage) remain reserved on your account. Delete the Linode (not just power it off) to stop billing.
- **Object Storage is S3-compatible**: Linode Object Storage implements the S3 API, so tools such as `s3cmd`, `rclone`, and AWS SDKs work against it in addition to `linode-cli object-storage`.
- **Default region/type/image**: `linode-cli configure` saves a default region, plan type, and image to `~/.config/linode-cli`. These are used automatically when you omit those flags on `create` commands.
- **Multiple profiles**: the config file supports multiple named users; switch with `--as-user <username>` per command or edit the file directly.
- **API v4 underlies everything**: the CLI is auto-generated from the Linode OpenAPI spec — any endpoint not exposed in the CLI can be called directly via the REST API at <https://techdocs.akamai.com/linode-api/reference/api>.
