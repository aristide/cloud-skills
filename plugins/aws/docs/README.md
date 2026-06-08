# Documentation

Welcome to the documentation for **AWS (`aws` CLI)**. This plugin's skills cover everyday commands; the links below point to the official AWS docs, organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)** — step-by-step introductions to get started
- **[Guides](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-using.html)** — task-oriented how-to articles
- **[Reference](https://docs.aws.amazon.com/cli/latest/reference/)** — the full `aws` command reference. See also: [API](https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html) · [regions](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) · [pricing](https://aws.amazon.com/pricing/)

## Getting help

- 🖥️ [Console / control panel](https://aws.amazon.com/console/)
- 📡 [Service status](https://health.aws.amazon.com/health/status)
- 🐛 [Issues / support](https://console.aws.amazon.com/support/home)

## Concepts & gotchas

- **Profiles & credential precedence** — the CLI resolves credentials in this order: command-line options → environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) → `~/.aws/credentials` → `~/.aws/config` → instance/container metadata. Use `--profile` or `AWS_PROFILE` to switch between named profiles without touching the default. See [Authentication & configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html).

- **IAM Identity Center / SSO** — the preferred auth method for human operators. Run `aws configure sso` once to write a profile, then `aws sso login --profile <name>` to refresh short-lived credentials. The token is cached in `~/.aws/sso/cache/`; it auto-renews during a session but must be explicitly re-fetched after it expires. See [IAM Identity Center (SSO) configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html).

- **`--query` uses JMESPath** — all client-side filtering is JMESPath syntax, not jq. Backticks delimit literal values (`` `running` ``), not quotes. With `--output text`, the query is applied *per page*, so combine it with `--output json` for reliable multi-page results. See [Filtering output](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html).

- **Pagination** — most list/describe commands auto-paginate (all pages returned). Use `--no-paginate` to get only the first page, `--page-size N` to reduce per-request item count (useful to avoid timeouts), and `--max-items N` + `--starting-token` for manual paging. See [Pagination](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-pagination.html).

- **Region is not global** — every API call targets a specific region. Resolution order: `--region` flag → `AWS_REGION` / `AWS_DEFAULT_REGION` env vars → profile's `region` setting → error. Always set a region explicitly in scripts. Use `aws ec2 describe-regions --output text --query 'Regions[].RegionName'` to list currently enabled regions.

- **`--dry-run` (EC2 only)** — validates IAM permissions for an EC2 action without executing it. Returns `DryRunOperation` on success, `UnauthorizedOperation` on failure. Not available outside EC2.

- **ARN format** — `arn:partition:service:region:account-id:resource`. The partition is `aws` for standard, `aws-cn` for China, `aws-us-gov` for GovCloud. Region and account-id fields are empty for global services (IAM, S3 bucket names, CloudFront).
