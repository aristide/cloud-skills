# Google Cloud — Reference & Documentation

Curated links to the official Google Cloud documentation for the `gcloud` CLI. The skills in this plugin cover the common commands and workflows; use these for deep lookups, full flag references, and concepts the skills don't go into.

## CLI

- [CLI reference (all commands)](https://cloud.google.com/sdk/gcloud/reference) — full `gcloud` command tree with every group, command, and flag
- [Install / upgrade the Google Cloud CLI](https://cloud.google.com/sdk/docs/install) — platform-specific quickstart (Linux, macOS, Windows, Docker)
- [Authenticate for the gcloud CLI](https://cloud.google.com/sdk/docs/authorizing) — `gcloud auth login`, service accounts, federated identities, and access tokens
- [Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials) — how SDKs, Terraform, and local apps find credentials automatically
- [Managing named configurations](https://cloud.google.com/sdk/docs/configurations) — bundle account + project + region/zone into named profiles for multiple environments
- [gcloud topic filters](https://cloud.google.com/sdk/gcloud/reference/topic/filters) — full filter expression syntax used by `--filter`
- [gcloud topic formats](https://cloud.google.com/sdk/gcloud/reference/topic/formats) — all `--format` values: `json`, `yaml`, `csv`, `table(...)`, `value(...)`, and format attributes

## API

- [Google Cloud APIs overview](https://cloud.google.com/apis/docs/overview) — REST API reference index; jump-off point for per-service API docs
- [Service account credentials](https://cloud.google.com/iam/docs/service-account-creds) — short-lived tokens, service account keys, and how services authenticate to Google APIs
- [Enable and disable services](https://cloud.google.com/service-usage/docs/enable-disable) — `gcloud services enable` counterpart in the console and REST API

## Platform

- [Console](https://console.cloud.google.com) — Google Cloud web console
- [Global locations — regions & zones](https://cloud.google.com/about/locations) — interactive map of all 43+ regions and 130+ zones, plus the region picker tool
- [Pricing overview](https://cloud.google.com/pricing) — per-product pricing pages
- [Pricing calculator](https://cloud.google.com/products/calculator) — estimate monthly costs for any combination of services
- [Google Cloud Service Health](https://status.cloud.google.com) — real-time and historical status for all GCP services across regions
- [View and manage quotas](https://cloud.google.com/docs/quota/view-manage) — see current quota values and request increases via console, gcloud, or the Cloud Quotas API

## Concepts & gotchas

- **Projects are the billing and API boundary.** Every resource lives inside a project. Set a default with `gcloud config set project <project-id>` or pass `--project` per command. Resource Manager docs: [Create projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

- **APIs must be explicitly enabled per project.** Calling an API that isn't enabled returns a 403. Enable it first: `gcloud services enable compute.googleapis.com`. List what's on with `gcloud services list --enabled`.

- **Two separate credential sets.** `gcloud auth login` sets credentials for `gcloud` commands; `gcloud auth application-default login` sets Application Default Credentials used by client libraries, Terraform, and any code that calls ADC. Both are often needed.

- **`gcloud storage` replaces `gsutil`.** `gsutil` is no longer recommended for Cloud Storage; `gcloud storage` is faster (up to 94 % faster on large downloads) and is the current standard. See the official [transition guide](https://cloud.google.com/storage/docs/gsutil-transition-to-gcloud).

- **Zones vs. regions.** A region (e.g. `europe-west1`) is a geographic area; a zone (e.g. `europe-west1-b`) is an isolated data-centre location within a region. Most Compute Engine resources are zonal; many managed services are regional. Set defaults with `gcloud config set compute/region` and `gcloud config set compute/zone`.

- **Named configurations for multiple environments.** Use `gcloud config configurations create <name>` to maintain separate account + project + region bundles for prod, staging, etc., and switch with `gcloud config configurations activate <name>`.

- **Output filtering is server-side.** `--filter` is evaluated by the API (not locally), so it reduces network traffic. Combine with `--format='value(...)'` to produce clean output for scripting without `jq`.
