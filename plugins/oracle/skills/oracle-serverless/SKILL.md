---
name: oracle-serverless
description: "Use when the user needs to manage Oracle Cloud Infrastructure (OCI) serverless functions — create applications, deploy functions, invoke them, view logs, and delete them."
---

# Oracle Cloud Infrastructure Serverless Functions

OCI Functions is built on the open-source Fn Project. Management (applications, function metadata) uses `oci fn ...`. Deploying function code uses the `fn` CLI (Fn Project). Both are typically needed. See the `oracle-setup` skill for auth and OCIDs.

## Prerequisites

```bash
# Install the Fn Project CLI (used for building and deploying)
curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh

# Configure Fn CLI to target OCI
fn create context <context-name> --provider oracle
fn use context <context-name>
fn update context oracle.compartment-id <compartment-ocid>
fn update context api-url https://functions.<region>.oci.oraclecloud.com
fn update context registry <region-key>.ocir.io/<namespace>/<repo-prefix>
```

The `fn` CLI uses the same OCI config (`~/.oci/config`) as the `oci` CLI.

## Applications

An application is a logical grouping for functions; it holds shared configuration and the subnet where functions run.

```bash
oci fn application create \
  --compartment-id <compartment-ocid> \
  --display-name my-app \
  --subnet-ids '["<subnet-ocid>"]' \
  --config '{"ENV":"prod","LOG_LEVEL":"info"}'

oci fn application list --compartment-id <compartment-ocid> --output table
oci fn application get --application-id <app-ocid>

# Update config
oci fn application update \
  --application-id <app-ocid> \
  --config '{"ENV":"prod","LOG_LEVEL":"debug"}'

oci fn application delete --application-id <app-ocid>
```

## Deploying Functions

Use the `fn` CLI in your function's source directory (which contains a `func.yaml`):

```bash
# Initialise a new function scaffold
fn init --runtime python3.9 my-function
cd my-function

# Deploy to an application (builds image, pushes to OCIR, registers function)
fn deploy --app my-app

# Deploy without building (use an existing image)
fn deploy --app my-app --no-bump
```

`fn deploy` builds a Docker image, pushes it to OCIR, and registers/updates the function in the application.

## Listing and Inspecting Functions

```bash
oci fn function list \
  --application-id <app-ocid> \
  --output table

oci fn function get --function-id <function-ocid>

# Update function settings (memory, timeout, config)
oci fn function update \
  --function-id <function-ocid> \
  --memory-in-mbs 256 \
  --timeout-in-seconds 120 \
  --config '{"KEY":"value"}'

oci fn function delete --function-id <function-ocid>
```

## Invoking Functions

```bash
# Invoke via oci CLI (synchronous, response written to a file)
oci fn function invoke \
  --function-id <function-ocid> \
  --file "-" \
  --body '{"name":"world"}'

# Invoke via fn CLI (simpler, shows response inline)
fn invoke my-app my-function <<< '{"name":"world"}'

# Invoke with a file as input body
oci fn function invoke \
  --function-id <function-ocid> \
  --file response.json \
  --body "$(cat input.json)"
```

## Viewing Logs

OCI Functions integrates with the OCI Logging service. Enable logs on the application first:

```bash
# Enable logging on an application (requires a log group OCID)
oci fn application update \
  --application-id <app-ocid> \
  --syslog-url "tcp://logging.ingest.<region>.oci.oraclecloud.com:6000"
```

Then query logs via the Logging service:

```bash
oci logging-search search-logs \
  --search-query 'search "<log-group-ocid>/<log-ocid>" | sort by datetime desc' \
  --time-start 2024-01-01T00:00:00Z \
  --time-end 2024-12-31T23:59:59Z
```

Or use the `fn` CLI for local testing logs:

```bash
fn invoke my-app my-function  # prints logs to stderr during local testing
```

## Local Development and Testing

```bash
# Start the local Fn server for testing without OCI
fn start

# Run function locally
fn invoke my-app my-function

# List local functions
fn list functions my-app
```

## Beyond the basics

Run `oci fn --help` and `fn --help` for the full surface. OCI Functions can be triggered by OCI Events, API Gateway, Notifications, and Connector Hub — none of those require code changes, just service-side wiring. For high-throughput or long-running work, consider the `oracle-containers` skill (Container Instances) or `oracle-kubernetes` (OKE) instead.
