# Documentation

Welcome to the documentation for **Google Cloud (`gcloud` CLI)**. This plugin's skills cover everyday commands; the links below point to the official Google Cloud docs, organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://cloud.google.com/sdk/docs/quickstart)** — step-by-step introductions to get started
- **[Guides](https://cloud.google.com/sdk/docs)** — task-oriented how-to articles
- **[Reference](https://cloud.google.com/sdk/gcloud/reference)** — the full `gcloud` command reference. See also: [API](https://cloud.google.com/apis/docs/overview) · [regions](https://cloud.google.com/about/locations) · [pricing](https://cloud.google.com/pricing)

## Getting help

- 🖥️ [Console / control panel](https://console.cloud.google.com)
- 📡 [Service status](https://status.cloud.google.com)
- 🐛 [Issues / support](https://cloud.google.com/support)

## Concepts & gotchas

- **Projects are the billing and API boundary.** Every resource lives inside a project. Set a default with `gcloud config set project <project-id>` or pass `--project` per command. Resource Manager docs: [Create projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

- **APIs must be explicitly enabled per project.** Calling an API that isn't enabled returns a 403. Enable it first: `gcloud services enable compute.googleapis.com`. List what's on with `gcloud services list --enabled`.

- **Two separate credential sets.** `gcloud auth login` sets credentials for `gcloud` commands; `gcloud auth application-default login` sets Application Default Credentials used by client libraries, Terraform, and any code that calls ADC. Both are often needed.

- **`gcloud storage` replaces `gsutil`.** `gsutil` is no longer recommended for Cloud Storage; `gcloud storage` is faster (up to 94 % faster on large downloads) and is the current standard. See the official [transition guide](https://cloud.google.com/storage/docs/gsutil-transition-to-gcloud).

- **Zones vs. regions.** A region (e.g. `europe-west1`) is a geographic area; a zone (e.g. `europe-west1-b`) is an isolated data-centre location within a region. Most Compute Engine resources are zonal; many managed services are regional. Set defaults with `gcloud config set compute/region` and `gcloud config set compute/zone`.

- **Named configurations for multiple environments.** Use `gcloud config configurations create <name>` to maintain separate account + project + region bundles for prod, staging, etc., and switch with `gcloud config configurations activate <name>`.

- **Output filtering is server-side.** `--filter` is evaluated by the API (not locally), so it reduces network traffic. Combine with `--format='value(...)'` to produce clean output for scripting without `jq`.
