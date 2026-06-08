# Documentation

Welcome to the documentation for **OVHcloud Public Cloud (`openstack` client)**.

This documentation is written and organized following the [Diátaxis](https://diataxis.fr/) framework:

- **[Tutorials](https://docs.ovhcloud.com/en/guides/public-cloud/compute/starting-with-nova)** — getting started with OpenStack on OVH Public Cloud
- **[Guides](https://docs.ovhcloud.com/en/)** — task-oriented OVH Public Cloud how-tos
- **[Reference](https://docs.openstack.org/python-openstackclient/latest/cli/command-list.html)** — the OpenStack `openstack` command reference. See also: [OVH API](https://api.eu.ovhcloud.com/console/) · [regions](https://www.ovhcloud.com/en/public-cloud/regions-availability/) · [pricing](https://www.ovhcloud.com/en/public-cloud/prices/) · [Terraform OVH provider](https://registry.terraform.io/providers/ovh/ovh/latest/docs)

## Getting help

- 🖥️ [Control panel](https://www.ovhcloud.com/manager/)
- 📡 [Service status](https://www.status-ovhcloud.com/)
- 🐛 [Issues / support](https://help.ovhcloud.com/csm/en?id=csm_index)

## Concepts & gotchas

- **OS_* RC file / application credentials:** Authentication to the OpenStack API is done by sourcing an `openrc.sh` file downloaded from the OVH Control Panel (Public Cloud → Users & Roles → Download RC file). For non-interactive/automation use, prefer application credentials (`openstack application credential create`) over raw passwords — they are scoped and revocable without changing the user's password. Credentials can also be stored in `~/.config/openstack/clouds.yaml` and selected with `--os-cloud <name>`.

- **Region codes:** OVH Public Cloud uses codes such as `GRA11` (Gravelines), `SBG5` (Strasbourg), `BHS5` (Beauharnois, Canada), `WAW1` (Warsaw), `DE1` (Frankfurt), `UK1` (London), `SGP1` (Singapore). Set the active region with `OS_REGION_NAME` or `--os-region-name`. List available regions for your project: `openstack region list`.

- **SHUTOFF instances still bill:** Stopping an instance (SHUTOFF state) via `openstack server stop` does **not** stop billing. OVHcloud bills by the hour for compute resources whether the instance is running or stopped. To stop billing entirely you must delete the instance (and separately snapshot it first if you want to restore it later). Only "flex" instances based on local storage are exempt.

- **DNS & Managed Kubernetes are via OVH API / Terraform, not `openstack`:** The `openstack` CLI only covers resources in the OpenStack surface (compute, block storage, object storage, networking within a project). OVHcloud-native services — DNS zones, Managed Kubernetes (MKS), Managed Databases, IP failover, dedicated servers, billing — are exposed through the OVH API (`api.eu.ovhcloud.com`) and are typically automated with the Terraform `ovh` provider.

- **No general FaaS:** OVHcloud Public Cloud does not offer a serverless functions-as-a-service (FaaS) product comparable to AWS Lambda or Google Cloud Functions. Serverless workloads should be handled with containers (Managed Kubernetes / Docker) or third-party FaaS platforms.

- **Auth URL:** The Keystone v3 endpoint for all OVH Public Cloud projects is `https://auth.cloud.ovh.net/v3/`. This is the value to use for `OS_AUTH_URL`.

- **`openstack` version:** Install via pip (`pip install python-openstackclient`). Verify with `openstack --version`. OVHcloud's OpenStack deployment tracks standard upstream releases; no OVH-specific fork is needed.
