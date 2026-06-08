---
name: aws-deploy
description: Guided interactive deployment of an AWS EC2 instance with smart defaults
---

Guide the user through launching an AWS EC2 instance, asking only for what's needed and filling sensible defaults.

## Steps

1. Confirm authentication works and show the active identity and region:
   ```bash
   aws sts get-caller-identity --output table
   aws configure get region
   ```
   If credentials are missing or expired, stop and help the user authenticate (see the `aws-setup` skill).

2. Gather choices, offering defaults and listing options when useful:

   - **Region** — default to the configured region; to change, use `--region <region>` on all subsequent commands. List available regions with:
     ```bash
     aws ec2 describe-regions --query 'Regions[].RegionName' --output table
     ```

   - **Instance type** — default `t3.micro` (free-tier eligible); show common options:
     ```bash
     aws ec2 describe-instance-types \
       --instance-types t3.micro t3.small t3.medium m5.large \
       --query 'InstanceTypes[].{type:InstanceType,vcpu:VCpuInfo.DefaultVCpus,memMiB:MemoryInfo.SizeInMiB}' \
       --output table
     ```

   - **AMI / OS** — default to latest Amazon Linux 2023:
     ```bash
     aws ssm get-parameter \
       --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
       --query 'Parameter.Value' --output text
     ```
     Or latest Ubuntu 24.04 LTS:
     ```bash
     aws ec2 describe-images --owners 099720109477 \
       --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
       --query 'sort_by(Images,&CreationDate)[-1].ImageId' --output text
     ```

   - **SSH key pair** — list existing keys; offer to create or import one (see `aws-security`):
     ```bash
     aws ec2 describe-key-pairs --query 'KeyPairs[].KeyName' --output table
     ```

   - **VPC and subnet** — default to the default VPC and a public subnet in the first AZ:
     ```bash
     aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" \
       --query 'Vpcs[0].VpcId' --output text
     aws ec2 describe-subnets \
       --filters "Name=defaultForAz,Values=true" \
       --query 'Subnets[0].SubnetId' --output text
     ```

   - **Security group** — offer to create a minimal one (SSH + HTTP/HTTPS) or use an existing one:
     ```bash
     aws ec2 describe-security-groups \
       --query 'SecurityGroups[].{id:GroupId,name:GroupName}' --output table
     ```

   - **Name tag** — ask for a name; used as the `Name` tag on the instance.

3. Show the exact `aws ec2 run-instances` command you will run and ask for confirmation before executing:
   ```bash
   aws ec2 run-instances \
     --image-id <ami-id> \
     --instance-type <type> \
     --key-name <key-pair> \
     --security-group-ids <sg-id> \
     --subnet-id <subnet-id> \
     --count 1 \
     --associate-public-ip-address \
     --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=<name>}]'
   ```

4. After creation, wait for the instance to reach `running` state, then report the public IP and the ready-to-use SSH command:
   ```bash
   aws ec2 wait instance-running --instance-ids <instance-id>
   aws ec2 describe-instances --instance-ids <instance-id> \
     --query 'Reservations[0].Instances[0].[PublicIpAddress,PublicDnsName]' --output text
   ```
   SSH command: `ssh -i ~/.ssh/<key>.pem ec2-user@<public-ip>` (use `ubuntu` for Ubuntu AMIs).

5. Offer logical follow-ups:
   - Attach an EBS volume (`aws-storage`)
   - Open additional firewall ports (`aws-networking`)
   - Point a DNS record at the new instance (`aws-dns`)
   - Allocate and associate an Elastic IP for a stable address (`aws-networking`)

Keep it conversational — never destroy or overwrite anything as part of "deploy".
