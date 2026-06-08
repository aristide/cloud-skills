---
name: aws-security
description: "Use when the user needs to manage AWS security — EC2 key pairs, ACM TLS certificates, IAM users/roles/policies, and resource tags."
---

# AWS Security

Commands span several services: `aws ec2 ...` for key pairs and tags, `aws acm ...` for certificates, `aws iam ...` for identity. Add `--region`/`--profile` as needed. See the `aws-setup` skill for auth.

## EC2 Key Pairs

Key pairs let you SSH into EC2 instances. The private key is shown **only once** at creation — save it immediately.

```bash
# Create a key pair and save the private key
aws ec2 create-key-pair \
  --key-name my-key \
  --query 'KeyMaterial' \
  --output text > my-key.pem
chmod 400 my-key.pem

# Import an existing public key (preferred when you already have an SSH key)
aws ec2 import-key-pair \
  --key-name my-key \
  --public-key-material fileb://~/.ssh/id_ed25519.pub

# List key pairs
aws ec2 describe-key-pairs \
  --query 'KeyPairs[].{name:KeyName,fingerprint:KeyFingerprint}' --output table

# Delete a key pair (does not affect existing instances)
aws ec2 delete-key-pair --key-name my-key
```

## ACM TLS/SSL Certificates

ACM certificates are free and auto-renewed when used with ALB, CloudFront, or API Gateway. They cannot be exported for use on EC2 directly.

```bash
# Request a public certificate (DNS validation recommended)
aws acm request-certificate \
  --domain-name example.com \
  --subject-alternative-names "*.example.com" \
  --validation-method DNS \
  --region us-east-1

# List certificates and their status
aws acm list-certificates \
  --query 'CertificateSummaryList[].{arn:CertificateArn,domain:DomainName,status:Status}' \
  --output table

# Inspect a certificate (includes DNS validation CNAME records to add)
aws acm describe-certificate --certificate-arn <cert-arn> \
  --query 'Certificate.DomainValidationOptions'

# Delete a certificate (must be detached from all resources first)
aws acm delete-certificate --certificate-arn <cert-arn>
```

After requesting, add the CNAME record shown by `describe-certificate` to your DNS zone (see `aws-dns`). ACM auto-validates once the record is live.

## IAM Basics

IAM is global (not region-specific). Follow least-privilege: prefer roles for services and federated access for humans.

```bash
# List users
aws iam list-users \
  --query 'Users[].{name:UserName,created:CreateDate}' --output table

# Create a role with a trust policy (e.g. for EC2 instances)
aws iam create-role \
  --role-name my-ec2-role \
  --assume-role-policy-document file://trust-policy.json

# Example trust policy (trust-policy.json):
# {
#   "Version": "2012-10-17",
#   "Statement": [{ "Effect": "Allow",
#     "Principal": {"Service": "ec2.amazonaws.com"},
#     "Action": "sts:AssumeRole" }]
# }

# Attach an AWS managed policy to the role
aws iam attach-role-policy \
  --role-name my-ec2-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# List policies attached to a role
aws iam list-attached-role-policies --role-name my-ec2-role \
  --query 'AttachedPolicies[].{name:PolicyName,arn:PolicyArn}' --output table

# Create an instance profile so EC2 can use the role
aws iam create-instance-profile --instance-profile-name my-ec2-profile
aws iam add-role-to-instance-profile \
  --instance-profile-name my-ec2-profile \
  --role-name my-ec2-role
```

## Tags

Tags are key/value metadata used for cost allocation, filtering, and automation. Most resources accept up to 50 tags.

```bash
# Tag any resource (EC2, volumes, snapshots, etc.)
aws ec2 create-tags \
  --resources <resource-id> \
  --tags Key=env,Value=prod Key=team,Value=platform

# Remove a tag
aws ec2 delete-tags --resources <resource-id> --tags Key=env

# Filter resources by tag
aws ec2 describe-instances \
  --filters "Name=tag:env,Values=prod" \
  --query 'Reservations[].Instances[].InstanceId' --output text
```

## Beyond the basics

Use `aws iam help`, `aws acm help`, and `aws ec2 help` for full operation lists. Related: `aws-networking` for security groups (network-layer firewall), `aws-compute` for attaching instance profiles at launch, `aws-dns` for adding ACM validation records.
