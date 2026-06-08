# Documentation

Welcome to the documentation for **Azure (`az` CLI)**. This plugin's skills cover everyday commands; the links below point to the official Microsoft docs, organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)** — step-by-step introductions to get started
- **[Guides](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)** — task-oriented how-to articles
- **[Reference](https://learn.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest)** — the full `az` command reference. See also: [API](https://learn.microsoft.com/en-us/rest/api/azure/) · [regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/) · [pricing](https://azure.microsoft.com/en-us/pricing/)

## Getting help

- 🖥️ [Console / control panel](https://portal.azure.com)
- 📡 [Service status](https://azure.status.microsoft/en-us/status)
- 🐛 [Issues / support](https://github.com/Azure/azure-cli/issues)

## Concepts & gotchas

- **Subscriptions and tenants** — A Microsoft Entra tenant can contain many subscriptions. All `az` commands target the *active* subscription (`az account show`); switch with `az account set --subscription <name-or-id>`. Automation should pin a subscription explicitly rather than relying on the CLI default.

- **Resource groups** — Every Azure resource belongs to exactly one resource group in one region. Deleting a resource group (`az group delete`) removes *all* resources inside it — there is no soft-delete on the group itself.

- **Deallocate vs. stop (VMs)** — Shutting down a VM from inside the OS leaves it in a *stopped* state that still incurs compute charges. Use `az vm deallocate` to release the underlying hardware and stop billing for compute. Storage charges continue regardless.

- **`az` extensions** — Many newer or preview services live in optional extensions (`az extension add --name <name>`) rather than the core CLI binary. Extensions must be updated separately with `az extension update --name <name>`. Run `az extension list-available --output table` to browse what is available.

- **`--output` and `--query` defaults** — The default output format is `json`. Set a persistent default with `az configure --defaults output=table`. Use `--query` with a [JMESPath](https://jmespath.org) expression to filter and reshape the CLI output — filtering is applied **client-side** on the returned JSON before display, so it does not reduce network payload but produces cleaner output than piping to `jq`.

- **`az configure` defaults** — Avoid repeating `--resource-group` and `--location` by setting `az configure --defaults group=<rg> location=<region>`. These defaults are stored in `~/.azure/config` and apply to the local profile only.

- **Idempotency and `--no-wait`** — Long-running operations (VM creation, deployments) can be started asynchronously with `--no-wait`. Poll status later with `az <resource> show` or `az deployment operation list`. ARM deployment operations are idempotent by design; re-running the same template is safe.
