---
name: aws-cleanup
description: Find orphaned/idle AWS resources that still bill and help clean them up
---

Find AWS resources that are likely wasting money, and help the user remove them — carefully.

## Steps

1. Confirm the active identity and region:
   ```bash
   aws sts get-caller-identity --output table
   aws configure get region
   ```
   If credentials are missing or expired, stop and help the user authenticate (see `aws-setup`).

2. Scan for common sources of idle spend. Run each command and collect the results:

   - **Stopped EC2 instances** — still billed for EBS storage; no compute charge, but often forgotten:
     ```bash
     aws ec2 describe-instances \
       --filters "Name=instance-state-name,Values=stopped" \
       --query 'Reservations[].Instances[].{id:InstanceId,name:Tags[?Key==`Name`]|[0].Value,type:InstanceType,stopped:StateTransitionReason}' \
       --output table
     ```

   - **Unattached EBS volumes** — billed by GB provisioned regardless of use:
     ```bash
     aws ec2 describe-volumes \
       --filters "Name=status,Values=available" \
       --query 'Volumes[].{id:VolumeId,size:Size,type:VolumeType,az:AvailabilityZone,name:Tags[?Key==`Name`]|[0].Value}' \
       --output table
     ```

   - **Unassociated Elastic IPs** — billed ~$0.005/hr while not attached to a running instance:
     ```bash
     aws ec2 describe-addresses \
       --query 'Addresses[?AssociationId==null].{ip:PublicIp,alloc:AllocationId}' \
       --output table
     ```

   - **Old EBS snapshots** — incremental, but unused backups accumulate cost over time:
     ```bash
     aws ec2 describe-snapshots --owner-ids self \
       --query 'Snapshots[].{id:SnapshotId,vol:VolumeId,size:VolumeSize,date:StartTime,desc:Description}' \
       --output table
     ```

   - **Empty / idle load balancers** — billed per hour even with no traffic:
     ```bash
     aws elbv2 describe-load-balancers \
       --query 'LoadBalancers[].{name:LoadBalancerName,arn:LoadBalancerArn,state:State.Code,dns:DNSName}' \
       --output table
     ```

   - **Unused ECR images** — each repository bills for stored image layers:
     ```bash
     aws ecr describe-repositories \
       --query 'repositories[].{name:repositoryName,uri:repositoryUri}' --output table
     ```

3. Present the findings grouped by resource type. For each item include its ID, size/cost driver, and the reason it looks wasteful (e.g. "vol-0abc — 100 GB gp3, detached for 14 days"). Do **not** delete anything yet.

4. Ask the user which categories or specific resources to remove. Only after explicit per-category confirmation, run the deletes and echo each command:

   ```bash
   # Terminate a stopped instance
   aws ec2 terminate-instances --instance-ids <id>

   # Delete an unattached EBS volume
   aws ec2 delete-volume --volume-id <vol-id>

   # Release an unassociated Elastic IP
   aws ec2 release-address --allocation-id <eipalloc-id>

   # Delete an old snapshot
   aws ec2 delete-snapshot --snapshot-id <snap-id>

   # Delete a load balancer (remove listeners first)
   aws elbv2 delete-load-balancer --load-balancer-arn <lb-arn>

   # Delete an ECR repository and all images
   aws ecr delete-repository --repository-name <name> --force
   ```

5. After cleanup, re-run the scan commands to confirm resources are gone and summarize estimated monthly savings.

Never delete in bulk without per-category confirmation. When unsure whether something is truly orphaned (e.g. a snapshot referenced by an AMI, or an EIP used by a NAT gateway), flag it for the user rather than removing it.
