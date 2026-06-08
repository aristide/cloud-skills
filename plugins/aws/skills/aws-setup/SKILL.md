---
name: aws-setup
description: "Use when the user needs to install, configure, or authenticate the AWS CLI (aws), manage profiles, regions, SSO, credentials, or control output format (JSON/text/table) for AWS commands."
---

# AWS CLI Setup and Configuration

The AWS CLI binary is `aws` (v2 is current). Verify with `aws --version`.

## Installation

### macOS

```bash
brew install awscli
```

### Linux

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip && sudo ./aws/install
```

### Windows

```powershell
winget install Amazon.AWSCLI
```

## Authentication

Credentials and config live in `~/.aws/credentials` and `~/.aws/config`.

### Static credentials (access key)

```bash
aws configure
```

Prompts for Access Key ID, Secret Access Key, default region, and output format. Stored under the `default` profile.

### Named profiles

```bash
aws configure --profile prod
aws ec2 describe-instances --profile prod
```

Select a profile for a whole shell session with `export AWS_PROFILE=prod`.

### IAM Identity Center (SSO)

```bash
aws configure sso          # one-time setup of an SSO profile
aws sso login --profile prod   # refresh short-lived credentials
```

### Verify identity

```bash
aws sts get-caller-identity
```

Confirms which account and IAM principal the current credentials resolve to.

## Region

Resolution order: `--region` flag → `AWS_REGION` env var → profile's `region` → unset (error).

```bash
aws configure set region eu-central-1 --profile prod
export AWS_REGION=eu-central-1
aws ec2 describe-instances --region eu-central-1
```

List regions:

```bash
aws ec2 describe-regions --query 'Regions[].RegionName' --output text
```

## Output Format

`--output` accepts `json` (default), `text`, `table`, `yaml`. Set a default:

```bash
aws configure set output json
```

### Server-side filtering with --query (JMESPath)

Prefer `--query` to trim responses before they reach the client:

```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].{id:InstanceId,state:State.Name,type:InstanceType}' \
  --output table
```

### Client-side filtering with jq

```bash
aws ec2 describe-instances --output json | jq '.Reservations[].Instances[].InstanceId'
```

### Resource-side filtering with --filters

```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
```

## Useful Globals

| Flag | Description |
|------|-------------|
| `--profile <name>` | Use a named profile |
| `--region <region>` | Override the region |
| `--output <fmt>` | json \| text \| table \| yaml |
| `--query <expr>` | JMESPath expression to filter/shape output |
| `--no-cli-pager` | Disable the interactive pager (useful for scripting) |
| `--dry-run` | (EC2) validate permissions without performing the action |

## Official documentation

See [`../../docs/README.md`](../../docs/README.md) in this plugin for curated links to the official AWS CLI reference, API docs, pricing, regions, and service-health pages.
