# Documentation

Welcome to the documentation for **Linode (`linode-cli`)**.

This documentation is written and organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://techdocs.akamai.com/cloud-computing/docs/getting-started-with-the-linode-cli)** — step-by-step lessons that walk you through installing, configuring, and running your first commands with `linode-cli`.
- **[Guides](https://techdocs.akamai.com/cloud-computing/docs)** — task-oriented how-to articles covering individual Akamai Cloud Computing services and workflows.
- **[Reference](https://techdocs.akamai.com/cloud-computing/docs/cli-1)** — the full `linode-cli` command reference. See also: [API](https://techdocs.akamai.com/linode-api/reference/api) · [regions](https://techdocs.akamai.com/cloud-computing/docs/how-to-choose-a-data-center) · [pricing](https://www.akamai.com/cloud/pricing)

## Getting help

- 🖥️ [Cloud Manager console](https://cloud.linode.com)
- 📡 [Service status](https://status.linode.com)
- 🐛 [Issues / support](https://github.com/linode/linode-cli/issues)

## Concepts & gotchas

- **Personal Access Token (PAT) required**: generate one at <https://cloud.linode.com/profile/tokens> with the scopes you need (Read/Write) before running `linode-cli configure` or setting `LINODE_CLI_TOKEN`.
- **Hyphenated subcommands**: most resource groups use hyphenated names in the CLI (e.g. `linode-cli object-storage`, `linode-cli node-balancers`). Tab-complete or run `linode-cli --help` to discover the exact names.
- **Shut-down Linodes still bill**: a powered-off Linode continues to accrue charges because its resources (RAM, IP, storage) remain reserved on your account. Delete the Linode (not just power it off) to stop billing.
- **Object Storage is S3-compatible**: Linode Object Storage implements the S3 API, so tools such as `s3cmd`, `rclone`, and AWS SDKs work against it in addition to `linode-cli object-storage`.
- **Default region/type/image**: `linode-cli configure` saves a default region, plan type, and image to `~/.config/linode-cli`. These are used automatically when you omit those flags on `create` commands.
- **Multiple profiles**: the config file supports multiple named users; switch with `--as-user <username>` per command or edit the file directly.
- **API v4 underlies everything**: the CLI is auto-generated from the Linode OpenAPI spec — any endpoint not exposed in the CLI can be called directly via the REST API at <https://techdocs.akamai.com/linode-api/reference/api>.
