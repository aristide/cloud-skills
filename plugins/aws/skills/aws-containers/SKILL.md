---
name: aws-containers
description: "Use when the user needs to run containers on AWS without managing Kubernetes — ECS/Fargate services, ECR container registry, or App Runner."
---

# AWS Containers (ECS, ECR, App Runner)

AWS offers several ways to run containers without managing Kubernetes: **ECS/Fargate** for orchestrated services, **ECR** for private image storage, and **App Runner** for fully managed web services direct from source or image. See the `aws-setup` skill for auth.

## ECR — Container Registry

```bash
# Create a private repository
aws ecr create-repository \
  --repository-name my-app \
  --region us-east-1

# List repositories
aws ecr describe-repositories \
  --query 'repositories[].{name:repositoryName,uri:repositoryUri}' --output table

# Authenticate Docker to ECR (required before push/pull)
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push an image
docker build -t my-app .
docker tag my-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# Delete a repository (--force removes all images inside)
aws ecr delete-repository --repository-name my-app --force
```

## ECS — Clusters

```bash
# Create a cluster (Fargate clusters have no EC2 instances to manage)
aws ecs create-cluster \
  --cluster-name my-cluster \
  --capacity-providers FARGATE FARGATE_SPOT

# List clusters
aws ecs list-clusters --query 'clusterArns' --output table

# Delete
aws ecs delete-cluster --cluster my-cluster
```

## ECS — Task Definitions

A task definition is a versioned blueprint for your container(s).

```bash
# Register a Fargate task definition from a JSON file
aws ecs register-task-definition --cli-input-json file://task-def.json

# Minimal task-def.json example:
# {
#   "family": "my-app",
#   "networkMode": "awsvpc",
#   "requiresCompatibilities": ["FARGATE"],
#   "cpu": "256", "memory": "512",
#   "executionRoleArn": "arn:aws:iam::<account-id>:role/ecsTaskExecutionRole",
#   "containerDefinitions": [{
#     "name": "web",
#     "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest",
#     "portMappings": [{"containerPort": 80}],
#     "logConfiguration": {
#       "logDriver": "awslogs",
#       "options": {
#         "awslogs-group": "/ecs/my-app",
#         "awslogs-region": "us-east-1",
#         "awslogs-stream-prefix": "ecs"
#       }
#     }
#   }]
# }

# List task definitions
aws ecs list-task-definitions --query 'taskDefinitionArns' --output table
```

## ECS — Services

A service keeps a desired number of task replicas running and integrates with a load balancer.

```bash
# Create a Fargate service
aws ecs create-service \
  --cluster my-cluster \
  --service-name my-app-svc \
  --task-definition my-app:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration \
    "awsvpcConfiguration={subnets=[<subnet-1>,<subnet-2>],securityGroups=[<sg-id>],assignPublicIp=ENABLED}"

# Update to a new task definition revision (rolling deploy)
aws ecs update-service \
  --cluster my-cluster \
  --service my-app-svc \
  --task-definition my-app:2

# Scale the service
aws ecs update-service \
  --cluster my-cluster \
  --service my-app-svc \
  --desired-count 4

# List services and status
aws ecs list-services --cluster my-cluster
aws ecs describe-services --cluster my-cluster --services my-app-svc \
  --query 'services[].{status:status,running:runningCount,desired:desiredCount}' --output table

# Delete a service (set desired-count to 0 first, or use --force)
aws ecs delete-service --cluster my-cluster --service my-app-svc --force
```

## App Runner (simplest path for web services)

App Runner builds, deploys, and scales a web service directly from an ECR image or a source code repository. No VPC or task definition required.

```bash
# Create a service from an ECR image
aws apprunner create-service \
  --service-name my-app \
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest",
      "ImageRepositoryType": "ECR",
      "ImageConfiguration": {"Port": "80"}
    },
    "AutoDeploymentsEnabled": true
  }'

# List services
aws apprunner list-services \
  --query 'ServiceSummaryList[].{name:ServiceName,url:ServiceUrl,status:Status}' --output table

# Delete a service
aws apprunner delete-service --service-arn <service-arn>
```

## Beyond the basics

Use `aws ecs help`, `aws ecr help`, and `aws apprunner help` for full operation lists. Related: `aws-networking` for VPC/SG setup required by Fargate, `aws-kubernetes` for EKS if you need full Kubernetes, `aws-serverless` for event-driven function workloads.
