#!/bin/bash

# vultr safety hook - warns Claude about destructive vultr-cli operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is a `vultr-cli` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])vultr-cli[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (verb appears as a `vultr-cli <group> <verb>` subcommand).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]destroy([[:space:]]|$)"
  "[[:space:]]stop([[:space:]]|$)"
  "[[:space:]]restart([[:space:]]|$)"
  "[[:space:]]reinstall([[:space:]]|$)"
  "[[:space:]]halt([[:space:]]|$)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|destroy|stop|restart|reinstall|halt)" | head -1)
    echo "WARN: This vultr-cli command performs a destructive operation ($ACTION). Ensure the user is aware this will modify or remove cloud resources. Note: a stopped Vultr instance still bills — only 'delete' stops charges."
    exit 0
  fi
done

exit 0
