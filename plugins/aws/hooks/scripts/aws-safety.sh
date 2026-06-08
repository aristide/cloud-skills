#!/bin/bash

# aws safety hook - warns Claude about destructive AWS CLI operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is an `aws` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])aws[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (EC2 + common services).
DESTRUCTIVE_PATTERNS=(
  "terminate-instances"
  "stop-instances"
  "reboot-instances"
  "delete-"
  "deregister-"
  "detach-"
  "release-address"
  "revoke-security-group"
  "cancel-"
  "s3[[:space:]]+rm"
  "s3[[:space:]]+rb"
  "delete-db-instance"
  "delete-bucket"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(terminate-instances|stop-instances|reboot-instances|delete-[a-z-]+|deregister-[a-z-]+|detach-[a-z-]+|release-address|revoke-security-group-[a-z]+|cancel-[a-z-]+|s3 rm|s3 rb)" | head -1)
    echo "WARN: This aws command performs a destructive operation ($ACTION). Ensure the user is aware this will modify or remove cloud resources, and that the correct --profile/--region is targeted."
    exit 0
  fi
done

exit 0
