# Oracle Cloud Infrastructure — Reference & Documentation

Curated links to the official Oracle Cloud Infrastructure documentation for the `oci` CLI. The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't go into.

## CLI

- CLI reference (all commands): <https://docs.oracle.com/iaas/tools/oci-cli/latest/oci_cli_docs/>
- Install / upgrade: <https://docs.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm>
- Authentication & configuration (`oci setup config`, API keys, session tokens, instance principals): <https://docs.oracle.com/iaas/Content/API/SDKDocs/cliconfigure.htm>
- Session/token auth (`oci session authenticate`): <https://docs.oracle.com/iaas/Content/API/SDKDocs/clitoken.htm>
- Output formatting / filtering (`--output table`, `--query` JMESPath): <https://docs.oracle.com/iaas/Content/API/SDKDocs/cliusing.htm>
- GitHub source repository: <https://github.com/oracle/oci-cli>

## API

- REST API reference (all services, endpoints): <https://docs.oracle.com/iaas/api/>
- API authentication / required keys and OCIDs: <https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm>

## Platform

- Console / control panel: <https://cloud.oracle.com>
- Regions & availability domains: <https://docs.oracle.com/iaas/Content/General/Concepts/regions.htm>
- Pricing: <https://www.oracle.com/cloud/price-list/>
- Service health / status: <https://ocistatus.oraclecloud.com/>
- Quotas & limits (Limits by Service): <https://docs.oracle.com/en-us/iaas/Content/General/service-limits/default.htm>

## Concepts & gotchas

- **OCIDs everywhere.** Every OCI resource has an Oracle Cloud ID (OCID) of the form `ocid1.<resource-type>.<realm>.[region].<unique-id>`. You need the correct OCID to target any resource. Reference: <https://docs.oracle.com/iaas/Content/General/Concepts/identifiers.htm>

- **`--compartment-id` is required by almost every resource command.** OCI organises all resources inside compartments (including the root tenancy compartment). If you omit `--compartment-id` the CLI will error or return no results. Export it to an env var (`export C=ocid1.compartment...`) to avoid repeating it on every call.

- **Tenancy hierarchy.** The tenancy is the root compartment; all other compartments are nested inside it. IAM policies, quotas, and service limits all cascade through the hierarchy. Use `oci iam compartment list --compartment-id-in-subtree true --all` to enumerate all compartments.

- **JSON output + `--query` (JMESPath).** The default output is JSON. Use `--output table` for human-readable results, and `--query` to project or filter fields inline — e.g. `--query 'data[].{name:"display-name",state:"lifecycle-state"}'`. Pipe to `jq` for more complex transformations.

- **Terminating an instance keeps the boot volume by default (Console).** When you terminate an instance through the Console the boot volume is preserved unless you explicitly check "Permanently delete the attached boot volume". Via the CLI, pass `--preserve-boot-volume true` to keep the boot volume, or `--preserve-boot-volume false` to delete it. Reference: <https://docs.oracle.com/iaas/Content/Compute/Tasks/terminatinginstance.htm>

- **Auth methods.** Three common methods: (1) API key pair in `~/.oci/config` (default); (2) browser-based session token via `oci session authenticate` — good for MFA, token expires after 1 hour (max 24 h with refresh); (3) instance principals — no key file needed, add `--auth instance_principal` when running on an OCI VM with an appropriate IAM policy.

- **Billing model.** OCI uses a pay-as-you-go or Universal Credits model. Pricing is identical across all global commercial regions. Always Free and $300 free-trial credits are available for new accounts. Cost estimator: <https://www.oracle.com/cloud/costestimator.html>
