---
name: azure-serverless
description: "Use when the user needs to manage Azure serverless functions — create function apps, list and delete them, and publish function code using Azure Functions Core Tools."
---

# Azure Serverless Functions

Azure Functions is Azure's FaaS (Functions as a Service) platform. A **function app** is the deployment container for one or more functions; it requires a **storage account** (for state and deployment artifacts) and an **App Service plan** (or the serverless Consumption plan).

All management commands are `az functionapp ...`. Deploying code locally uses the Azure Functions Core Tools (`func`).

## Prerequisites

A function app needs a storage account. Create one if it doesn't already exist:

```bash
az storage account create \
  --resource-group <rg> \
  --name <storage-account-name> \
  --sku Standard_LRS \
  --location <region>
```

## Create a Function App

### Consumption plan (serverless — pay per execution)

```bash
az functionapp create \
  --resource-group <rg> \
  --name <functionapp-name> \
  --storage-account <storage-account-name> \
  --consumption-plan-location <region> \
  --runtime <runtime> \
  --runtime-version <version> \
  --functions-version 4
```

Common `--runtime` values: `python`, `node`, `dotnet`, `java`, `powershell`. Match `--runtime-version` to the runtime (e.g. `3.11` for Python, `20` for Node.js).

### Dedicated / Premium plan

```bash
# Create an App Service plan first
az appservice plan create \
  --resource-group <rg> \
  --name <plan-name> \
  --sku B1 \
  --is-linux \
  --location <region>

# Create the function app on that plan
az functionapp create \
  --resource-group <rg> \
  --name <functionapp-name> \
  --storage-account <storage-account-name> \
  --plan <plan-name> \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --os-type Linux
```

## List and Show Function Apps

```bash
az functionapp list -g <rg> -o table
az functionapp list \
  --query '[].{name:name,rg:resourceGroup,runtime:kind,state:state,url:defaultHostName}' \
  -o table
az functionapp show -g <rg> -n <functionapp-name>
```

## Application Settings (Environment Variables)

```bash
# Set one or more app settings
az functionapp config appsettings set \
  --resource-group <rg> \
  --name <functionapp-name> \
  --settings MY_KEY=value ANOTHER_KEY=value2

# List all settings
az functionapp config appsettings list -g <rg> -n <functionapp-name> -o table

# Delete a setting
az functionapp config appsettings delete \
  --resource-group <rg> \
  --name <functionapp-name> \
  --setting-names MY_KEY
```

## Start, Stop, Restart

```bash
az functionapp start   -g <rg> -n <functionapp-name>
az functionapp stop    -g <rg> -n <functionapp-name>
az functionapp restart -g <rg> -n <functionapp-name>
```

## View Logs

```bash
# Stream live logs via Azure Functions Core Tools
func azure functionapp logstream <functionapp-name>

# View deployment logs via the CLI
az functionapp log deployment list -g <rg> -n <functionapp-name>
az functionapp log deployment show -g <rg> -n <functionapp-name>
```

Note: `az functionapp log tail` does not exist. Use `func azure functionapp logstream` (Core Tools) to stream live execution logs. The `az functionapp log` group only exposes deployment logs.

## Delete a Function App

```bash
az functionapp delete -g <rg> -n <functionapp-name> --yes
```

Deleting the function app does **not** delete the storage account or App Service plan — delete those separately if no longer needed.

## Deploying Code with Core Tools

The [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools) (`func`) CLI is the standard way to develop and publish function code.

```bash
# Install (npm)
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Scaffold a new function project
func init MyFunctionApp --worker-runtime python

# Create a new function (e.g. HTTP trigger)
cd MyFunctionApp
func new --name HttpExample --template "HTTP trigger" --authlevel anonymous

# Run locally
func start

# Publish to Azure (authenticates via the logged-in az session)
func azure functionapp publish <functionapp-name>
```

`func azure functionapp publish` builds the deployment package locally and uploads it to the function app. Use `--build remote` for server-side builds.

## Beyond the basics

Run `az functionapp --help` for the full subcommand list. Advanced topics include deployment slots (`az functionapp deployment slot`), managed identity for Key Vault references (`az functionapp identity assign`), custom domains and TLS (`az functionapp config hostname`), and Durable Functions for stateful orchestrations.
