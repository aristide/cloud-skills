# OVHcloud Public Cloud — Reference & Documentation

Curated links to the official documentation for OVHcloud Public Cloud. This plugin uses the OpenStack client (`openstack` binary) for compute/network/storage operations, and the OVH API or Terraform `ovh` provider for platform-level resources (DNS, Managed Kubernetes, billing, dedicated servers) that are outside the OpenStack surface. Use these links for deep lookups, full flag references, and concepts the skills don't go into.

---

## OpenStack client (CLI)

- **Command reference (all commands):** https://docs.openstack.org/python-openstackclient/latest/cli/command-list.html
- **Install / upgrade (`python-openstackclient`):** https://docs.openstack.org/python-openstackclient/latest/
- **Authentication guide (password, token, application credentials, clouds.yaml):** https://docs.openstack.org/python-openstackclient/latest/cli/authentication.html
- **Configuration guide (global options, env vars, clouds.yaml, logging):** https://docs.openstack.org/python-openstackclient/latest/configuration/index.html
- **Manual page (synopsis, global flags, command structure):** https://docs.openstack.org/python-openstackclient/latest/cli/man/openstack.html

## OVHcloud guides for OpenStack / Public Cloud

- **Preparing the OpenStack API environment (install client, set OS_* vars, RC file):** https://docs.ovhcloud.com/en/guides/public-cloud/cross-functional/compute-prepare-openstack-api-environment
- **Getting started with the OpenStack Compute API (Nova):** https://docs.ovhcloud.com/en/guides/public-cloud/compute/starting-with-nova
- **Using service accounts (application credentials) to connect to OpenStack:** https://docs.ovhcloud.com/en/guides/manage-and-operate/iam/authenticate-api-openstack-with-service-account
- **All you need to know to get started with Public Cloud:** https://help.ovhcloud.com/csm/en-public-cloud-compute-essential-information?id=kb_article_view&sysparm_article=KB0050390
- **OpenStack tutorials index (RC file, tokens, vRack, Heat, etc.):** https://help.ovhcloud.com/csm/en-documentation-public-cloud-cross-functional-tutorials-openstack?id=kb_browse_cat&kb_id=574a8325551974502d4c6e78b7421938&kb_category=c627fe3c50f1325c476b993c97467c06

## OVH API & platform

- **OVH API console (interactive browser, EU endpoint):** https://api.eu.ovhcloud.com/console/
- **OVH API developer portal:** https://eu.api.ovh.com/
- **OVHcloud Control Panel (manager login):** https://www.ovhcloud.com/manager/
- **Public Cloud regions & product availability:** https://www.ovhcloud.com/en/public-cloud/regions-availability/
- **Public Cloud pricing:** https://www.ovhcloud.com/en/public-cloud/prices/
- **Service health & incidents:** https://www.status-ovhcloud.com/
- **How to increase Public Cloud quotas:** https://docs.ovhcloud.com/en/guides/public-cloud/cross-functional/increasing-public-cloud-quota

## Terraform OVH provider (DNS, Managed Kubernetes, and beyond)

Resources such as DNS zones and Managed Kubernetes clusters are managed through the OVH API or Terraform, not via the `openstack` CLI.

- **Terraform `ovh` provider (latest):** https://registry.terraform.io/providers/ovh/ovh/latest
- **Provider docs overview (authentication, all resources & data sources):** https://registry.terraform.io/providers/ovh/ovh/latest/docs
- **Managed Kubernetes (`ovh_cloud_project_kube`) resource:** https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube
- **OVHcloud Managed Kubernetes Service (MKS) guides:** https://help.ovhcloud.com/csm/en-documentation-public-cloud-containers-orchestration-managed-kubernetes-k8s?id=kb_browse_cat&kb_id=574a8325551974502d4c6e78b7421938&kb_category=f334d555f49801102d4ca4d466a7fdd2
- **DNS zone guides:** https://docs.ovhcloud.com/en/guides/web-cloud/domains/dns-zone-general-information

## Concepts & gotchas

- **OS_* RC file / application credentials:** Authentication to the OpenStack API is done by sourcing an `openrc.sh` file downloaded from the OVH Control Panel (Public Cloud → Users & Roles → Download RC file). For non-interactive/automation use, prefer application credentials (`openstack application credential create`) over raw passwords — they are scoped and revocable without changing the user's password. Credentials can also be stored in `~/.config/openstack/clouds.yaml` and selected with `--os-cloud <name>`.

- **Region codes:** OVH Public Cloud uses codes such as `GRA11` (Gravelines), `SBG5` (Strasbourg), `BHS5` (Beauharnois, Canada), `WAW1` (Warsaw), `DE1` (Frankfurt), `UK1` (London), `SGP1` (Singapore). Set the active region with `OS_REGION_NAME` or `--os-region-name`. List available regions for your project: `openstack region list`.

- **SHUTOFF instances still bill:** Stopping an instance (SHUTOFF state) via `openstack server stop` does **not** stop billing. OVHcloud bills by the hour for compute resources whether the instance is running or stopped. To stop billing entirely you must delete the instance (and separately snapshot it first if you want to restore it later). Only "flex" instances based on local storage are exempt.

- **DNS & Managed Kubernetes are via OVH API / Terraform, not `openstack`:** The `openstack` CLI only covers resources in the OpenStack surface (compute, block storage, object storage, networking within a project). OVHcloud-native services — DNS zones, Managed Kubernetes (MKS), Managed Databases, IP failover, dedicated servers, billing — are exposed through the OVH API (`api.eu.ovhcloud.com`) and are typically automated with the Terraform `ovh` provider.

- **No general FaaS:** OVHcloud Public Cloud does not offer a serverless functions-as-a-service (FaaS) product comparable to AWS Lambda or Google Cloud Functions. Serverless workloads should be handled with containers (Managed Kubernetes / Docker) or third-party FaaS platforms.

- **Auth URL:** The Keystone v3 endpoint for all OVH Public Cloud projects is `https://auth.cloud.ovh.net/v3/`. This is the value to use for `OS_AUTH_URL`.

- **`openstack` version:** Install via pip (`pip install python-openstackclient`). Verify with `openstack --version`. OVHcloud's OpenStack deployment tracks standard upstream releases; no OVH-specific fork is needed.
