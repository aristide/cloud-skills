---
name: aws-compute
description: "Use when the user needs to create, list, inspect, start, stop, reboot, or terminate AWS EC2 instances, manage key pairs, look up AMIs or instance types, or read console output."
---

# AWS EC2 Compute

All commands are `aws ec2 ...`. Add `--region`/`--profile` as needed (see the `aws-setup` skill). Most read commands support `--filters` and `--query`.

## Instance Lifecycle

### Launch an Instance

```bash
aws ec2 run-instances \
  --image-id <ami-id> \
  --instance-type <type> \
  --key-name <key-pair> \
  --security-group-ids <sg-id> \
  --subnet-id <subnet-id> \
  --count 1
```

Common flags:
- `--image-id <ami>` - AMI to boot (required)
- `--instance-type <type>` - e.g. `t3.micro`, `m5.large` (required)
- `--key-name <name>` - SSH key pair name for access
- `--security-group-ids <id>...` - Security groups (firewall)
- `--subnet-id <id>` - VPC subnet to place the instance in
- `--count <n>` - Number of instances (default 1)
- `--user-data file://<path>` - Cloud-init / bootstrap script
- `--block-device-mappings <json>` - Override root/extra volumes
- `--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web}]'` - Tag at launch
- `--associate-public-ip-address` / `--no-associate-public-ip-address`
- `--iam-instance-profile Name=<profile>` - Attach an instance role
- `--dry-run` - Validate permissions only

### List / Describe Instances

```bash
aws ec2 describe-instances
aws ec2 describe-instances --instance-ids <id>
aws ec2 describe-instances --filters "Name=tag:Name,Values=web-*"
```

Concise table:

```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].{id:InstanceId,name:Tags[?Key==`Name`]|[0].Value,state:State.Name,type:InstanceType,ip:PublicIpAddress}' \
  --output table
```

Just the running ones:

```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].InstanceId' --output text
```

### Instance status (health/reachability)

```bash
aws ec2 describe-instance-status --instance-ids <id>
```

## Power Management

```bash
aws ec2 start-instances --instance-ids <id>...
aws ec2 stop-instances --instance-ids <id>...
aws ec2 stop-instances --instance-ids <id> --hibernate   # if enabled
aws ec2 reboot-instances --instance-ids <id>...
```

`stop` releases the public IPv4 (unless an Elastic IP is attached) and stops compute billing; EBS storage still bills.

### Terminate (destroy)

```bash
aws ec2 terminate-instances --instance-ids <id>...
```

Irreversible. Deletes the instance and any volumes whose `DeleteOnTermination` is true. Protect critical instances:

```bash
aws ec2 modify-instance-attribute --instance-id <id> --disable-api-termination
```

## Access

### Get the public IP / DNS

```bash
aws ec2 describe-instances --instance-ids <id> \
  --query 'Reservations[].Instances[].[PublicIpAddress,PublicDnsName]' --output text
```

### SSH

EC2 has no built-in `ssh` subcommand — connect directly with the key pair:

```bash
ssh -i ~/.ssh/<key>.pem ec2-user@<public-ip>
```

Default users by AMI: `ec2-user` (Amazon Linux / RHEL), `ubuntu` (Ubuntu), `admin` (Debian).

### Session Manager (no SSH/key needed, requires SSM agent + role)

```bash
aws ssm start-session --target <instance-id>
```

### Console output (boot/troubleshooting)

```bash
aws ec2 get-console-output --instance-id <id> --output text
```

## Key Pairs

```bash
aws ec2 create-key-pair --key-name <name> --query 'KeyMaterial' --output text > <name>.pem
chmod 400 <name>.pem
aws ec2 describe-key-pairs
aws ec2 delete-key-pair --key-name <name>
```

Import an existing public key:

```bash
aws ec2 import-key-pair --key-name <name> --public-key-material fileb://~/.ssh/id_ed25519.pub
```

## Images (AMIs)

```bash
# Latest Amazon Linux 2023 AMI via SSM public parameter
aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query 'Parameters[0].Value' --output text

aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --query 'sort_by(Images,&CreationDate)[-1].ImageId' --output text
```

## Instance Types

```bash
aws ec2 describe-instance-types --instance-types t3.micro \
  --query 'InstanceTypes[].{type:InstanceType,vcpu:VCpuInfo.DefaultVCpus,mem:MemoryInfo.SizeInMiB}' \
  --output table
```

## Tags

```bash
aws ec2 create-tags --resources <id> --tags Key=env,Value=prod
aws ec2 delete-tags --resources <id> --tags Key=env
```

## Beyond Compute

For VPC/networking, EBS volumes, load balancers (ELBv2), IAM, S3, RDS, etc., use the same `aws <service> <operation>` pattern and `aws <service> help` for the full operation list. This skill focuses on core EC2 compute; broader coverage can be added as additional skills.
