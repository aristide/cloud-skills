---
name: gcp-serverless
description: "Use when the user needs to manage Google Cloud Functions — deploy, list, invoke, view logs, and delete serverless functions (1st and 2nd gen)."
---

# Google Cloud Functions

Cloud Functions is GCP's FaaS (Function-as-a-Service) offering. Enable the API: `gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com`.

**Gen1 vs Gen2:** Gen2 (recommended for new workloads) is built on Cloud Run and supports longer timeouts, larger instances, and concurrency. The generation flag varies by subcommand: `deploy` and `logs read` use `--gen2`; `describe` and `list` use `--v2`. `call` and `delete` detect the generation automatically from the function's metadata.

## Deploy a Function

### HTTP trigger (Gen1)

```bash
gcloud functions deploy my-function \
  --runtime nodejs20 \
  --trigger-http \
  --entry-point helloHttp \
  --source ./my-function-dir \
  --region us-central1 \
  --allow-unauthenticated
```

### HTTP trigger (Gen2)

```bash
gcloud functions deploy my-function \
  --gen2 \
  --runtime python312 \
  --trigger-http \
  --entry-point hello_http \
  --source ./my-function-dir \
  --region us-central1 \
  --allow-unauthenticated
```

### Pub/Sub trigger

```bash
gcloud functions deploy my-pubsub-function \
  --gen2 \
  --runtime nodejs20 \
  --trigger-topic my-topic \
  --entry-point processPubSub \
  --source ./my-function-dir \
  --region us-central1
```

### Cloud Storage trigger

```bash
gcloud functions deploy my-gcs-function \
  --gen2 \
  --runtime python312 \
  --trigger-bucket my-bucket \
  --entry-point process_file \
  --source ./my-function-dir \
  --region us-central1
```

### Common deploy flags

```bash
#   --memory 256MB / 512MB / 1GB / 2GB / 4GB / 8GB / 16GB / 32GB
#   --timeout 60s                    max 540s (Gen1) or 3600s (Gen2)
#   --min-instances 0                keep warm to reduce cold starts (Gen2)
#   --max-instances 10
#   --set-env-vars KEY=VALUE,KEY2=VALUE2
#   --service-account SA_EMAIL
#   --runtime-env-vars GOOGLE_CLOUD_PROJECT=PROJECT_ID
#   --concurrency 80                 Gen2 only (concurrent requests per instance)
```

## List and Describe

```bash
gcloud functions list --region us-central1
gcloud functions list \
  --format='table(name,status,trigger,runtime,updateTime)'

gcloud functions describe my-function --region us-central1

# Gen2 function info
gcloud functions describe my-function --v2 --region us-central1
```

## Invoke (Call) a Function

```bash
# HTTP function — prints response body (works for Gen1 and Gen2)
gcloud functions call my-function \
  --region us-central1 \
  --data '{"name":"World"}'
```

For direct HTTPS invocation:

```bash
# Get the URL
gcloud functions describe my-function --region us-central1 --format='get(serviceConfig.uri)'

# Call via curl (authenticated)
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  https://REGION-PROJECT_ID.cloudfunctions.net/my-function \
  -d '{"name":"World"}'
```

## View Logs

```bash
# Recent logs (Gen1 and Gen2)
gcloud functions logs read my-function --region us-central1

# Fetch more entries (max 1000)
gcloud functions logs read my-function --region us-central1 --limit 50

# Gen2 — logs are also available via Cloud Logging (richer filtering)
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.function_name=my-function" \
  --limit 50 --format='table(timestamp,textPayload)'
```

## Update a Function

Redeploy with updated flags — `gcloud functions deploy` acts as create-or-update:

```bash
gcloud functions deploy my-function \
  --gen2 \
  --region us-central1 \
  --set-env-vars NEW_VAR=value \
  --memory 1GB
```

## Delete a Function

```bash
gcloud functions delete my-function --region us-central1
```

## List Available Runtimes

```bash
gcloud functions runtimes list --region us-central1
```

Common runtimes: `nodejs20`, `nodejs22`, `python312`, `python311`, `go123`, `java21`, `ruby33`, `dotnet8`.

## Beyond the basics

Run `gcloud functions --help` for the full command tree. For more complex event-driven architectures, consider **Eventarc** (`gcloud eventarc triggers create`) which provides a unified trigger model for Gen2 functions and Cloud Run. **Cloud Scheduler** (`gcloud scheduler jobs create http`) can invoke HTTP functions on a cron schedule.
