---
name: oracle-containers
description: "Use when the user needs to run containers on Oracle Cloud Infrastructure (OCI) without managing Kubernetes — Container Instances (serverless containers) and the OCI Container Registry (OCIR)."
---

# Oracle Cloud Infrastructure Containers

OCI offers two container primitives without Kubernetes: **Container Instances** (run containers directly, serverless) via `oci container-instances ...`, and **OCI Container Registry (OCIR)** for storing Docker images via `oci artifacts container ...`. See the `oracle-setup` skill for auth and OCIDs.

## Container Instances

Container Instances are serverless — no VMs to manage. They bill per vCPU/memory-second while running.

### Create a Container Instance

```bash
oci container-instances container-instance create \
  --compartment-id <compartment-ocid> \
  --availability-domain <AD-name> \
  --display-name my-app \
  --shape CI.Standard.E4.Flex \
  --shape-config '{"ocpus":1,"memoryInGBs":4}' \
  --vnics '[{"subnetId":"<subnet-ocid>"}]' \
  --containers '[
    {
      "displayName": "app",
      "imageUrl": "<region>.ocir.io/<namespace>/my-image:latest",
      "environmentVariables": {"PORT": "8080"},
      "resourceConfig": {"vcpusLimit": 1.0, "memoryLimitInGBs": 4}
    }
  ]' \
  --wait-for-state ACTIVE
```

Key parameters:
- `--shape` — `CI.Standard.E4.Flex` (AMD) or `CI.Standard.A1.Flex` (Arm)
- `--vnics` — at least one VCN subnet; add `"isPublicIpAssigned": true` for a public IP
- `--containers` — JSON array; supports multiple sidecar containers per instance
- `--image-pull-secrets` — required for private OCIR repositories

### List and Inspect

```bash
oci container-instances container-instance list \
  --compartment-id <compartment-ocid> \
  --output table

oci container-instances container-instance get \
  --container-instance-id <ocid>

# List containers within an instance
oci container-instances container list \
  --compartment-id <compartment-ocid> \
  --container-instance-id <ocid>
```

### Start, Stop, and Delete

```bash
oci container-instances container-instance start \
  --container-instance-id <ocid> \
  --wait-for-state ACTIVE

oci container-instances container-instance stop \
  --container-instance-id <ocid> \
  --wait-for-state INACTIVE

oci container-instances container-instance delete \
  --container-instance-id <ocid>
```

A stopped container instance does not bill for compute, but attached storage may still bill.

### Retrieve Container Logs

```bash
oci container-instances container retrieve-logs \
  --container-id <container-ocid> \
  --file -
```

`--file -` writes to stdout; pass a filename instead to save to a file. Find `<container-ocid>` from `oci container-instances container list` above.

## OCI Container Registry (OCIR)

OCIR is a managed Docker-compatible registry. Each region has its own endpoint: `<region-key>.ocir.io` (e.g. `iad.ocir.io` for us-ashburn-1).

### Create and Manage Repositories

```bash
# Get your object storage namespace (used as registry username prefix)
NAMESPACE=$(oci os ns get --query 'data' --raw-output)

# Create a repository
oci artifacts container repository create \
  --compartment-id <compartment-ocid> \
  --display-name my-namespace/my-app \
  --is-public false

oci artifacts container repository list \
  --compartment-id <compartment-ocid> \
  --output table

oci artifacts container repository get \
  --repository-id <repo-ocid>

oci artifacts container repository delete \
  --repository-id <repo-ocid>
```

### Authenticate Docker to OCIR

```bash
# Generate an auth token for your IAM user (one-time setup)
oci iam auth-token create \
  --user-id <user-ocid> \
  --description "OCIR docker login"

# Login — username format: <namespace>/<iam-username>
docker login <region-key>.ocir.io \
  --username "$NAMESPACE/<iam-username>" \
  --password "<auth-token>"
```

Auth tokens are shown only at creation time. Store them securely (e.g. in a password manager or CI secret store).

### Push and Pull Images

```bash
# Tag a local image for OCIR
docker tag my-app:latest <region-key>.ocir.io/$NAMESPACE/my-app:latest

# Push
docker push <region-key>.ocir.io/$NAMESPACE/my-app:latest

# Pull
docker pull <region-key>.ocir.io/$NAMESPACE/my-app:latest
```

### List and Delete Images

```bash
oci artifacts container image list \
  --compartment-id <compartment-ocid> \
  --repository-name "$NAMESPACE/my-app" \
  --output table

oci artifacts container image delete \
  --image-id <image-ocid>
```

## Beyond the basics

Run `oci container-instances --help` and `oci artifacts container --help` for the full surface. Container Instances support volume mounts from Object Storage and config file injection. For more complex orchestration (auto-scaling, rolling deployments), consider the `oracle-kubernetes` skill. OCIR supports image scanning for vulnerabilities (`oci vulnerability-scanning`) and retention policies for automatic image cleanup.
