---
name: digitalocean-serverless
description: "Use when the user needs to manage DigitalOcean Functions (serverless) — install the runtime, deploy function namespaces, list and invoke functions, view logs, and delete functions."
---

# DigitalOcean Serverless Functions

DigitalOcean Functions is the platform's FaaS product, built on Apache OpenWhisk. All commands are `doctl serverless ...`. See the `digitalocean-setup` skill for auth.

> **Note:** `doctl serverless` requires a sandbox runtime installed locally. Run `doctl serverless install` once before any other serverless command. The runtime is downloaded to `~/.config/doctl/sandbox/`.

## One-time Setup

```bash
# Install the serverless runtime (required once per machine)
doctl serverless install

# Connect to a namespace (each project lives in a namespace)
doctl serverless connect
```

## Namespaces

Functions are scoped to namespaces. A namespace is roughly a project boundary.

```bash
# List namespaces
doctl serverless namespaces list

# Create a namespace
doctl serverless namespaces create --label my-ns --region nyc1

# Delete a namespace
doctl serverless namespaces delete <namespace-id>
```

## Deploying Functions

Functions are deployed from a local project directory. Initialise a new project with `doctl serverless init`, then deploy the whole directory.

```bash
# Scaffold a new functions project
doctl serverless init my-project --language js

# Deploy all packages and functions in the project directory
doctl serverless deploy my-project

# Deploy only a specific package
doctl serverless deploy my-project --include packages/hello
```

The project directory contains a `project.yml` (or `project.json`) that describes packages, functions, runtimes, environment variables, and triggers.

## Listing Functions

```bash
# List all functions in the connected namespace
doctl serverless functions list

# List functions in a specific package
doctl serverless functions list /my-package
```

## Invoking Functions

```bash
# Invoke by name (package/function format)
doctl serverless functions invoke hello/world

# Pass parameters as JSON
doctl serverless functions invoke hello/world \
  --param name:Alice --param greeting:Hello

# Full JSON payload
doctl serverless functions invoke hello/world \
  --full                   # show full activation record (result + logs + timing)
```

## Logs

```bash
# Show recent activation logs for a function
doctl serverless activations logs hello/world

# List recent activations
doctl serverless activations list

# Get details of a specific activation
doctl serverless activations get <activation-id>
```

## Triggers (Scheduled Functions)

Triggers fire functions on a cron schedule.

```bash
# Create a cron trigger
doctl serverless triggers create my-trigger \
  --function hello/world \
  --cron "0 9 * * 1-5"

# List triggers
doctl serverless triggers list

# Delete a trigger
doctl serverless triggers delete my-trigger
```

## Delete Functions

```bash
# Delete a single function
doctl serverless functions delete hello/world

# Undeploy an entire package (deletes all functions in it)
doctl serverless undeploy my-package
```

## Beyond the basics

Run `doctl serverless --help` for the full surface, including `doctl serverless watch` (auto-redeploy on file save), environment variable management with `doctl serverless env`, and `doctl serverless status` to check runtime and namespace connectivity. For production workloads, pin function runtimes in `project.yml` and version-control the project directory.
