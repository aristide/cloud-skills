# Documentation

Welcome to the documentation for **Oracle Cloud Infrastructure (`oci` CLI)**. This documentation is written and organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://docs.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm)** — install and configure the `oci` CLI from scratch (Quickstart: install, authenticate, run your first command).
- **[Guides](https://docs.oracle.com/iaas/)** — task-oriented how-to guides across all OCI services (compute, networking, storage, IAM, and more).
- **[Reference](https://docs.oracle.com/iaas/tools/oci-cli/latest/oci_cli_docs/)** — the full `oci` command reference. See also: [API](https://docs.oracle.com/iaas/api/) · [regions](https://docs.oracle.com/iaas/Content/General/Concepts/regions.htm) · [pricing](https://www.oracle.com/cloud/price-list/)

## Getting help

- 🖥️ [Console](https://cloud.oracle.com)
- 📡 [Service status](https://ocistatus.oraclecloud.com/)
- 🐛 [Issues / support](https://github.com/oracle/oci-cli/issues)

## Concepts & gotchas

- **OCIDs everywhere.** Every OCI resource has an Oracle Cloud ID (OCID) of the form `ocid1.<resource-type>.<realm>.[region][.future-use].<unique-id>`. You need the correct OCID to target any resource. Reference: <https://docs.oracle.com/iaas/Content/General/Concepts/identifiers.htm>

- **`--compartment-id` is required by almost every resource command.** OCI organises all resources inside compartments (including the root tenancy compartment). If you omit `--compartment-id` the CLI will error or return no results. Export it to an env var (`export C=ocid1.compartment...`) to avoid repeating it on every call.

- **Tenancy hierarchy.** The tenancy is the root compartment; all other compartments are nested inside it. IAM policies, quotas, and service limits all cascade through the hierarchy. Use `oci iam compartment list --compartment-id-in-subtree true --all` to enumerate all compartments.

- **JSON output + `--query` (JMESPath).** The default output is JSON. Use `--output table` for human-readable results, and `--query` to project or filter fields inline — e.g. `--query 'data[].{name:"display-name",state:"lifecycle-state"}'`. Pipe to `jq` for more complex transformations.

- **Boot volume default differs between Console and CLI.** When you terminate an instance through the Console the boot volume is **preserved** unless you explicitly check "Permanently delete the attached boot volume". Via the CLI the default is the opposite: `--preserve-boot-volume` defaults to `false`, meaning the boot volume is **deleted** unless you pass `--preserve-boot-volume true`. Reference: <https://docs.oracle.com/iaas/Content/Compute/Tasks/terminatinginstance.htm>

- **Auth methods.** Three common methods: (1) API key pair in `~/.oci/config` (default); (2) browser-based session token via `oci session authenticate` — good for MFA, token expires after 1 hour (max 24 h with refresh); (3) instance principals — no key file needed, add `--auth instance_principal` when running on an OCI VM with an appropriate IAM policy.

- **Billing model.** OCI uses a pay-as-you-go or Universal Credits model. Pricing is identical across all global commercial regions. Always Free and $300 free-trial credits are available for new accounts. Cost estimator: <https://www.oracle.com/cloud/costestimator.html>
