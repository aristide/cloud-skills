# Azure — Reference & Documentation

Curated links to the official Azure documentation for the `az` CLI. The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't go into.

## CLI

- [CLI reference (all commands)](https://learn.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest)
- [Azure CLI documentation hub](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
- [Install / upgrade](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Authentication & configuration overview (`az login`)](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest)
- [Sign in interactively](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively?view=azure-cli-latest)
- [Sign in with a service principal](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-service-principal?view=azure-cli-latest)
- [Output formats (`--output` / `-o`)](https://learn.microsoft.com/en-us/cli/azure/format-output-azure-cli?view=azure-cli-latest)
- [Query command output (`--query` / JMESPath)](https://learn.microsoft.com/en-us/cli/azure/use-azure-cli-successfully-query?view=azure-cli-latest)
- [Extensions overview (`az extension`)](https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview?view=azure-cli-latest)

## API

- [Azure REST API reference](https://learn.microsoft.com/en-us/rest/api/azure/)
- [Azure REST API — getting started & authentication](https://learn.microsoft.com/en-us/rest/api/gettingstarted/)
- [Use the Azure REST API with Azure CLI (`az rest`)](https://learn.microsoft.com/en-us/cli/azure/use-azure-cli-rest-command?view=azure-cli-latest)

## Platform

- [Azure portal](https://portal.azure.com)
- [Azure global infrastructure — geographies & regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/)
- [Products available by region](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/)
- [Pricing overview](https://azure.microsoft.com/en-us/pricing/)
- [Pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [Azure status (global service health)](https://azure.status.microsoft/en-us/status)
- [Azure subscription and service limits, quotas, and constraints](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits)
- [Azure Quotas overview](https://learn.microsoft.com/en-us/azure/quotas/quotas-overview)

## Concepts & gotchas

- **Subscriptions and tenants** — A Microsoft Entra tenant can contain many subscriptions. All `az` commands target the *active* subscription (`az account show`); switch with `az account set --subscription <name-or-id>`. Automation should pin a subscription explicitly rather than relying on the CLI default.

- **Resource groups** — Every Azure resource belongs to exactly one resource group in one region. Deleting a resource group (`az group delete`) removes *all* resources inside it — there is no soft-delete on the group itself.

- **Deallocate vs. stop (VMs)** — Shutting down a VM from inside the OS leaves it in a *stopped* state that still incurs compute charges. Use `az vm deallocate` to release the underlying hardware and stop billing for compute. Storage charges continue regardless.

- **`az` extensions** — Many newer or preview services live in optional extensions (`az extension add --name <name>`) rather than the core CLI binary. Extensions must be updated separately with `az extension update --name <name>`. Run `az extension list-available --output table` to browse what is available.

- **`--output` and `--query` defaults** — The default output format is `json`. Set a persistent default with `az configure --defaults output=table`. Use `--query` with a [JMESPath](https://jmespath.org) expression for server-side filtering — this reduces payload size and is faster than piping to `jq`.

- **`az configure` defaults** — Avoid repeating `--resource-group` and `--location` by setting `az configure --defaults group=<rg> location=<region>`. These defaults are stored in `~/.azure/config` and apply to the local profile only.

- **Idempotency and `--no-wait`** — Long-running operations (VM creation, deployments) can be started asynchronously with `--no-wait`. Poll status later with `az <resource> show` or `az deployment operation list`. ARM deployment operations are idempotent by design; re-running the same template is safe.
