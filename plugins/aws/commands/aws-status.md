---
name: aws-status
description: Show an overview of AWS resources in the current account and region
---

Show a concise overview of the active AWS account's infrastructure.

## Steps

1. Confirm the active identity and region:
   ```bash
   aws sts get-caller-identity --output table
   aws configure get region
   ```

2. List core resources (skip any that error due to missing permissions or that return empty):
   - EC2 instances:
     ```bash
     aws ec2 describe-instances \
       --query 'Reservations[].Instances[].{id:InstanceId,name:Tags[?Key==`Name`]|[0].Value,state:State.Name,type:InstanceType,ip:PublicIpAddress}' \
       --output table
     ```
   - EBS volumes: `aws ec2 describe-volumes --query 'Volumes[].{id:VolumeId,size:Size,state:State,attached:Attachments[0].InstanceId}' --output table`
   - Elastic IPs: `aws ec2 describe-addresses --query 'Addresses[].{ip:PublicIp,instance:InstanceId}' --output table`
   - Key pairs: `aws ec2 describe-key-pairs --query 'KeyPairs[].KeyName' --output text`
   - Security groups: `aws ec2 describe-security-groups --query 'SecurityGroups[].{id:GroupId,name:GroupName}' --output table`
   - Load balancers: `aws elbv2 describe-load-balancers --query 'LoadBalancers[].{name:LoadBalancerName,dns:DNSName,state:State.Code}' --output table`

3. Present a concise summary highlighting:
   - Instance counts by state (skip states with zero)
   - Stopped instances still incurring EBS cost
   - Unattached (available) volumes
   - Unassociated Elastic IPs (these bill while idle)
   - Anything notable or in an error/pending state

Run the list commands and summarize. If credentials are missing or expired, point the user to the `aws-setup` skill (`aws configure` / `aws sso login`).
