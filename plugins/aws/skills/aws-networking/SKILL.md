---
name: aws-networking
description: "Use when the user needs to manage AWS networking — VPCs, subnets, security groups, route tables, Elastic IPs, and Application/Network load balancers."
---

# AWS Networking

All commands are `aws ec2 ...` (for VPCs/subnets/SGs/IPs) or `aws elbv2 ...` (for load balancers). Add `--region`/`--profile` as needed. See the `aws-setup` skill for auth.

## VPCs

```bash
# Create a VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-vpc}]'

# List VPCs
aws ec2 describe-vpcs \
  --query 'Vpcs[].{id:VpcId,cidr:CidrBlock,default:IsDefault,name:Tags[?Key==`Name`]|[0].Value}' \
  --output table

# Delete a VPC (must remove subnets, IGWs, route tables first)
aws ec2 delete-vpc --vpc-id <vpc-id>
```

## Subnets

```bash
# Create a subnet
aws ec2 create-subnet \
  --vpc-id <vpc-id> \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-1a}]'

# List subnets
aws ec2 describe-subnets \
  --query 'Subnets[].{id:SubnetId,vpc:VpcId,cidr:CidrBlock,az:AvailabilityZone,public:MapPublicIpOnLaunch}' \
  --output table

# Enable auto-assign public IP on a subnet
aws ec2 modify-subnet-attribute --subnet-id <subnet-id> --map-public-ip-on-launch

# Delete
aws ec2 delete-subnet --subnet-id <subnet-id>
```

## Internet Gateway (required for public subnets)

```bash
aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-igw}]'
aws ec2 attach-internet-gateway --vpc-id <vpc-id> --internet-gateway-id <igw-id>

# Add a default route in the route table so traffic reaches the IGW
aws ec2 create-route --route-table-id <rtb-id> \
  --destination-cidr-block 0.0.0.0/0 --gateway-id <igw-id>
```

## Security Groups

```bash
# Create
aws ec2 create-security-group \
  --group-name web-sg --description "Web tier" --vpc-id <vpc-id>

# Add ingress rules
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 22 --cidr <your-ip>/32

# Revoke an ingress rule
aws ec2 revoke-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 22 --cidr <your-ip>/32

# List security groups
aws ec2 describe-security-groups \
  --query 'SecurityGroups[].{id:GroupId,name:GroupName,vpc:VpcId}' --output table

# Delete (detach from all instances first)
aws ec2 delete-security-group --group-id <sg-id>
```

## Elastic IPs

Elastic IPs bill (~$0.005/hr) while allocated but not associated with a running instance.

```bash
# Allocate
aws ec2 allocate-address --domain vpc

# Associate with an instance
aws ec2 associate-address --instance-id <id> --allocation-id <eipalloc-id>

# Disassociate
aws ec2 disassociate-address --association-id <eipassoc-id>

# Release (stops billing)
aws ec2 release-address --allocation-id <eipalloc-id>

# List all Elastic IPs and their association status
aws ec2 describe-addresses \
  --query 'Addresses[].{ip:PublicIp,alloc:AllocationId,assoc:AssociationId,instance:InstanceId}' \
  --output table
```

## Load Balancers (ELBv2)

```bash
# Create an Application Load Balancer (internet-facing)
aws elbv2 create-load-balancer \
  --name my-alb \
  --type application \
  --subnets <subnet-id-1> <subnet-id-2> \
  --security-groups <sg-id>

# Create a target group
aws elbv2 create-target-group \
  --name my-tg \
  --protocol HTTP --port 80 \
  --vpc-id <vpc-id> \
  --target-type instance

# Register instances in the target group
aws elbv2 register-targets \
  --target-group-arn <tg-arn> \
  --targets Id=<instance-id>

# Create an HTTP listener (forwards to target group)
aws elbv2 create-listener \
  --load-balancer-arn <lb-arn> \
  --protocol HTTP --port 80 \
  --default-actions Type=forward,TargetGroupArn=<tg-arn>

# List load balancers
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[].{name:LoadBalancerName,dns:DNSName,state:State.Code}' \
  --output table

# Delete (removes listener + LB; target group deleted separately)
aws elbv2 delete-load-balancer --load-balancer-arn <lb-arn>
aws elbv2 delete-target-group --target-group-arn <tg-arn>
```

## Beyond the basics

Use `aws ec2 help` and `aws elbv2 help` for the full operation list. Related skills: `aws-compute` for launching instances into these subnets/SGs, `aws-security` for ACM certs to attach HTTPS listeners, and `aws-dns` for pointing a domain at your load balancer.
