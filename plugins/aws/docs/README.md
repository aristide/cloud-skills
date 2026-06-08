# AWS — Reference & Documentation

Curated links to the official AWS documentation for the `aws` CLI (AWS CLI v2). The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't go into.

## CLI

- [CLI reference (all commands)](https://docs.aws.amazon.com/cli/latest/reference/) — per-service, per-command flag listings for the full AWS CLI v2 surface
- [Install / upgrade AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) — Linux, macOS, and Windows install instructions
- [Authentication & configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html) — credential types, precedence order, and recommended auth paths
- [Configuration & credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) — `~/.aws/config` and `~/.aws/credentials` format, profiles, and all supported keys
- [Output formatting (`--output`)](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html) — json, yaml, yaml-stream, text, table, off
- [Filtering output (`--query` / JMESPath)](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html) — server-side filters and client-side `--query` JMESPath expressions
- [Pagination (`--no-paginate`, `--page-size`, `--max-items`)](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-pagination.html) — controlling multi-page responses
- [IAM Identity Center (SSO) configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) — `aws configure sso` and short-lived credential refresh

## API

- [AWS service API reference index](https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html) — endpoints and quotas for every AWS service; jump-off point to each service's REST API reference
- [AWS documentation home](https://docs.aws.amazon.com/) — top-level index for all service developer guides and API references

## Platform

- [AWS Management Console](https://aws.amazon.com/console/) — browser-based portal for all AWS services
- [Regions & Availability Zones](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) — current region list, AZ counts, and local/outpost availability
- [AWS Pricing](https://aws.amazon.com/pricing/) — per-service pricing pages and pricing calculator
- [AWS Health Dashboard (service health)](https://health.aws.amazon.com/health/status) — real-time and historical status for all AWS services across all regions
- [Service Quotas](https://docs.aws.amazon.com/servicequotas/latest/userguide/intro.html) — view default limits and request increases for any AWS service quota

## Concepts & gotchas

- **Profiles & credential precedence** — the CLI resolves credentials in this order: command-line options → environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) → `~/.aws/credentials` → `~/.aws/config` → instance/container metadata. Use `--profile` or `AWS_PROFILE` to switch between named profiles without touching the default. See [Authentication & configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html).

- **IAM Identity Center / SSO** — the preferred auth method for human operators. Run `aws configure sso` once to write a profile, then `aws sso login --profile <name>` to refresh short-lived credentials. The token is cached in `~/.aws/sso/cache/`; it auto-renews during a session but must be explicitly re-fetched after it expires. See [IAM Identity Center (SSO) configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html).

- **`--query` uses JMESPath** — all client-side filtering is JMESPath syntax, not jq. Backticks delimit literal values (`` `running` ``), not quotes. With `--output text`, the query is applied *per page*, so combine it with `--output json` for reliable multi-page results. See [Filtering output](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html).

- **Pagination** — most list/describe commands auto-paginate (all pages returned). Use `--no-paginate` to get only the first page, `--page-size N` to reduce per-request item count (useful to avoid timeouts), and `--max-items N` + `--starting-token` for manual paging. See [Pagination](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-pagination.html).

- **Region is not global** — every API call targets a specific region. Resolution order: `--region` flag → `AWS_REGION` / `AWS_DEFAULT_REGION` env vars → profile's `region` setting → error. Always set a region explicitly in scripts. Use `aws ec2 describe-regions --output text --query 'Regions[].RegionName'` to list currently enabled regions.

- **`--dry-run` (EC2 only)** — validates IAM permissions for an EC2 action without executing it. Returns `DryRunOperation` on success, `UnauthorizedOperation` on failure. Not available outside EC2.

- **ARN format** — `arn:partition:service:region:account-id:resource`. The partition is `aws` for standard, `aws-cn` for China, `aws-us-gov` for GovCloud. Region and account-id fields are empty for global services (IAM, S3 bucket names, CloudFront).
