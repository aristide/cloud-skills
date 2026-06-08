---
name: aws-serverless
description: "Use when the user needs to manage AWS Lambda serverless functions — deploy, list, invoke, update code, read logs, and delete functions."
---

# AWS Serverless (Lambda)

All commands are `aws lambda ...` unless noted. Lambda bills per invocation and per GB-second of compute — there is no idle charge, but large zips stored in S3/ECR do count against storage. See the `aws-setup` skill for auth.

## Create a Function

Lambda runs code from a `.zip` archive or a container image. The execution role controls what AWS services the function can call.

```bash
# Package code into a zip first
zip function.zip index.js   # or: zip -r function.zip .

# Create from a zip (Node.js example)
aws lambda create-function \
  --function-name my-function \
  --runtime nodejs20.x \
  --handler index.handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::<account-id>:role/lambda-exec-role

# Create from a container image in ECR
aws lambda create-function \
  --function-name my-function \
  --package-type Image \
  --code ImageUri=<account-id>.dkr.ecr.us-east-1.amazonaws.com/my-fn:latest \
  --role arn:aws:iam::<account-id>:role/lambda-exec-role

# Common optional flags:
#   --timeout 30                        # seconds (default 3, max 900)
#   --memory-size 512                   # MB (default 128)
#   --environment "Variables={KEY=val}"
#   --description "My function"
```

The execution role must trust `lambda.amazonaws.com`. Attach `AWSLambdaBasicExecutionRole` as a minimum so the function can write CloudWatch logs.

## List and Describe

```bash
# List all functions
aws lambda list-functions \
  --query 'Functions[].{name:FunctionName,runtime:Runtime,memory:MemorySize,timeout:Timeout}' \
  --output table

# Describe one function
aws lambda get-function --function-name my-function \
  --query 'Configuration.{state:State,lastModified:LastModified,handler:Handler}'
```

## Invoke

```bash
# Synchronous invoke — response written to out.json
aws lambda invoke \
  --function-name my-function \
  --payload '{"key":"value"}' \
  --cli-binary-format raw-in-base64-out \
  out.json
cat out.json

# Asynchronous invoke (fire-and-forget)
aws lambda invoke \
  --function-name my-function \
  --invocation-type Event \
  --payload '{"key":"value"}' \
  --cli-binary-format raw-in-base64-out \
  out.json
```

## Update Function Code

```bash
# Update from a new zip
aws lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://function.zip

# Update from ECR image
aws lambda update-function-code \
  --function-name my-function \
  --image-uri <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-fn:v2

# Update configuration (environment, memory, timeout)
aws lambda update-function-configuration \
  --function-name my-function \
  --timeout 60 \
  --memory-size 1024 \
  --environment "Variables={STAGE=prod}"
```

## Logs (CloudWatch Logs)

Lambda automatically streams logs to CloudWatch Logs under `/aws/lambda/<function-name>`.

```bash
# Tail the most recent log stream
aws logs describe-log-streams \
  --log-group-name /aws/lambda/my-function \
  --order-by LastEventTime --descending \
  --query 'logStreams[0].logStreamName' --output text

# Read log events from that stream (replace <stream> with the value above)
aws logs get-log-events \
  --log-group-name /aws/lambda/my-function \
  --log-stream-name "<stream>" \
  --query 'events[].message' --output text

# Filter logs for errors across all streams
aws logs filter-log-events \
  --log-group-name /aws/lambda/my-function \
  --filter-pattern "ERROR"
```

## Function URLs (simple HTTPS endpoint, no API Gateway)

```bash
# Add a public function URL (no auth)
aws lambda create-function-url-config \
  --function-name my-function \
  --auth-type NONE

# Get the URL
aws lambda get-function-url-config --function-name my-function \
  --query 'FunctionUrl' --output text
```

## Delete a Function

```bash
aws lambda delete-function --function-name my-function

# Delete a specific version
aws lambda delete-function --function-name my-function --qualifier 3
```

## Beyond the basics

Use `aws lambda help` for the full operation list. For HTTP APIs backed by Lambda, see API Gateway (`aws apigatewayv2`). For event sources (SQS, S3, DynamoDB streams), use `aws lambda create-event-source-mapping`. Related: `aws-containers` for ECS/Fargate if you need longer-running or stateful workloads.
