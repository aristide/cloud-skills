---
name: gcp-containers
description: "Use when the user needs to run containers on Google Cloud without managing Kubernetes — deploy and manage Cloud Run services, and manage Artifact Registry repositories for container images."
---

# Google Cloud Containers (Cloud Run + Artifact Registry)

GCP's serverless container surface is **Cloud Run** (HTTP-driven containers, no cluster to manage). Container images are stored in **Artifact Registry**. Enable the APIs: `gcloud services enable run.googleapis.com artifactregistry.googleapis.com`.

## Cloud Run

### Deploy a service

```bash
# Deploy from a public image
gcloud run deploy my-service \
  --image gcr.io/google-samples/hello-app:1.0 \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated

# Deploy from Artifact Registry
gcloud run deploy my-service \
  --image us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-app:latest \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated

# Key flags:
#   --port 8080                          container listens on this port
#   --memory 512Mi / --cpu 1             resource limits
#   --min-instances 0 / --max-instances 10
#   --concurrency 80                     requests per container instance
#   --set-env-vars KEY=VALUE,KEY2=VALUE2
#   --service-account SA_EMAIL           identity for the service
#   --no-allow-unauthenticated           require auth (IAM)
#   --timeout 300                        request timeout in seconds
```

### List and describe services

```bash
gcloud run services list --region us-central1
gcloud run services list \
  --format='table(metadata.name,status.url,status.conditions[0].status)'

gcloud run services describe my-service --region us-central1
```

### Update a running service

```bash
# Update env vars or image without redeploying from source
gcloud run services update my-service \
  --region us-central1 \
  --image us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-app:v2 \
  --set-env-vars DB_HOST=10.0.0.1

# Scale to zero when idle (default behaviour; set min-instances to keep warm)
gcloud run services update my-service --region us-central1 --min-instances 0
```

### Traffic splitting (canary / rollback)

```bash
# List revisions
gcloud run revisions list --service my-service --region us-central1

# Send 10% to the latest revision, 90% to the previous
gcloud run services update-traffic my-service \
  --region us-central1 \
  --to-revisions LATEST=10,my-service-00002-xyz=90

# Roll back to a specific revision (100%)
gcloud run services update-traffic my-service \
  --region us-central1 \
  --to-revisions my-service-00002-xyz=100
```

### View logs

```bash
gcloud run services logs read my-service --region us-central1
gcloud run services logs tail my-service --region us-central1
```

### Delete a service

```bash
gcloud run services delete my-service --region us-central1
```

## Artifact Registry

Artifact Registry stores Docker images, Helm charts, and more. It replaces the older Container Registry (`gcr.io`).

### Create a repository

```bash
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="My Docker repo"

gcloud artifacts repositories list
gcloud artifacts repositories describe my-repo --location us-central1
gcloud artifacts repositories delete my-repo --location us-central1
```

### Authenticate Docker

```bash
# Configure Docker to use gcloud credentials for the registry
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### Push and pull images

```bash
# Tag and push a local image
docker tag my-app:latest us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-app:latest
docker push us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-app:latest

# List images in a repository
gcloud artifacts docker images list us-central1-docker.pkg.dev/PROJECT_ID/my-repo
```

## Beyond the basics

Run `gcloud run --help` or `gcloud artifacts --help` for the full flag set. Cloud Run also supports **Jobs** (`gcloud run jobs create/execute`) for batch workloads, **VPC connectors** for private networking, and **Cloud Run for Anthos** for on-prem/hybrid deployments.
