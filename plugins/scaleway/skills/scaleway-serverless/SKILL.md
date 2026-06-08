---
name: scaleway-serverless
description: "Use when the user needs to manage Scaleway Serverless Functions — create namespaces, create and deploy functions (FaaS), upload code archives, list, update, invoke, and delete functions."
---

# Scaleway Serverless Functions

All commands are `scw function ...`. Serverless Functions is a **regional** FaaS product — functions are grouped into namespaces and executed on demand with no server management. Confirm exact flags with `scw function --help`.

## Namespaces

Namespaces group related functions and share environment variables and secrets.

```bash
# List namespaces
scw function namespace list region=fr-par

# Create a namespace
scw function namespace create \
  name=my-functions \
  region=fr-par

# Create with shared environment variables
scw function namespace create \
  name=my-functions \
  environment-variables.ENV=production \
  region=fr-par

# Get details
scw function namespace get <namespace-id> region=fr-par

# Update (e.g. add an env var)
scw function namespace update <namespace-id> \
  environment-variables.LOG_LEVEL=debug \
  region=fr-par

# Delete a namespace (removes all functions inside it)
scw function namespace delete <namespace-id> region=fr-par
```

## Functions

### Create a Function

```bash
scw function function create \
  name=my-func \
  namespace-id=<namespace-id> \
  runtime=node22 \
  handler=handler.handle \
  region=fr-par
```

Common arguments:
- `runtime=<runtime>` — e.g. `node22`, `node20`, `python312`, `python311`, `go122`, `go121`, `php83`, `rust165` (list with `scw function runtime list region=fr-par`)
- `handler=<handler>` — Entry-point in the format `<file>.<function>` (e.g. `handler.handle`)
- `memory-limit=<mb>` — RAM in MB (e.g. 128, 256, 512, 1024)
- `min-scale=0` — Scale to zero when idle
- `max-scale=<n>` — Maximum concurrent executions
- `timeout=<duration>` — Max execution time (e.g. `300s`)
- `privacy=public|private` — Whether the endpoint requires authentication
- `environment-variables.KEY=value` — Runtime environment variables
- `secret-environment-variables.0.key=KEY` + `.0.value=<val>` — Secrets (not stored in plaintext)

### Upload Code

Functions are deployed from a ZIP archive. Get the upload URL, upload with `curl`, then deploy:

```bash
# Get the upload URL for the function
scw function function get-upload-url <function-id> region=fr-par
# → returns an upload URL valid for a short period

# Upload the zip (replace <upload-url> with the URL returned above)
curl -X PUT "<upload-url>" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @my-function.zip
```

### Deploy (activate the uploaded code)

```bash
scw function function deploy <function-id> region=fr-par
```

You can combine create + deploy using the `scw function deploy` shortcut:

```bash
scw function deploy \
  name=my-func \
  namespace-id=<namespace-id> \
  runtime=node22 \
  zip-file=./my-function.zip \
  region=fr-par
```

### List and Inspect

```bash
scw function function list namespace-id=<namespace-id> region=fr-par
scw function function list -o table=ID,Name,Status,Runtime,DomainName region=fr-par

scw function function get <function-id> region=fr-par
# The DomainName field in the response is the HTTPS invocation endpoint
```

### Update a Function

```bash
scw function function update <function-id> \
  memory-limit=512 \
  environment-variables.NEW_VAR=value \
  region=fr-par
```

After updating, re-deploy to apply changes:

```bash
scw function function deploy <function-id> region=fr-par
```

### List Available Runtimes

```bash
scw function runtime list region=fr-par
```

### Delete a Function

```bash
scw function function delete <function-id> region=fr-par
```

## Invoking Functions

Once deployed, functions are invoked over HTTPS. The endpoint is in the `domain-name` field:

```bash
# Get the endpoint
endpoint=$(scw function function get <function-id> region=fr-par -o json | jq -r '.domain_name')

# Invoke with curl
curl "https://$endpoint"

# POST with a JSON payload
curl -X POST "https://$endpoint" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'

# For private functions, pass the Scaleway token
curl "https://$endpoint" \
  -H "X-Auth-Token: $SCW_SECRET_KEY"
```

## Triggers (Cron / HTTP)

```bash
# List triggers
scw function trigger list region=fr-par

# Create a cron trigger
scw function trigger create \
  function-id=<function-id> \
  name=every-hour \
  type=schedule \
  schedule-config.schedule="0 * * * *" \
  schedule-config.timezone="Europe/Paris" \
  region=fr-par

# Delete a trigger
scw function trigger delete <trigger-id> region=fr-par
```

## Beyond the basics

Use `scw function --help` for the full argument list. For workloads that need a persistent HTTP server or a Docker image, see Serverless Containers (`scaleway-containers`). For orchestrating containers at scale, see Kubernetes Kapsule (`scaleway-kubernetes`).
