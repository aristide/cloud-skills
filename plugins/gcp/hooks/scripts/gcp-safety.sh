#!/bin/bash

# gcp safety hook - warns Claude about destructive gcloud operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is a `gcloud`, `gsutil`, or `bq` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])(gcloud|gsutil|bq)[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (verb appears as a `gcloud ... <verb>` subcommand).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]remove-[a-z-]+"
  "[[:space:]]stop([[:space:]]|$)"
  "[[:space:]]reset([[:space:]]|$)"
  "[[:space:]]suspend([[:space:]]|$)"
  "[[:space:]]detach-[a-z-]+"
  "gsutil[[:space:]]+rm"
  "gsutil[[:space:]]+rb"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|remove-[a-z-]+|stop|reset|suspend|detach-[a-z-]+|rm|rb)" | head -1)
    echo "WARN: This gcloud command performs a destructive operation ($ACTION). Ensure the user is aware this will modify or remove cloud resources, and that the correct --project/--zone is targeted. Note: deleting an instance also deletes its boot disk by default."
    exit 0
  fi
done

exit 0
