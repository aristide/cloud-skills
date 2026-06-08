#!/bin/bash

# linode safety hook - warns Claude about destructive linode-cli operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is a `linode-cli` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])linode-cli[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (verb appears as a `linode-cli <group> <verb>` subcommand).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]shutdown([[:space:]]|$)"
  "[[:space:]]reboot([[:space:]]|$)"
  "[[:space:]]rebuild([[:space:]]|$)"
  "[[:space:]]resize([[:space:]]|$)"
  "[[:space:]]rescue([[:space:]]|$)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|shutdown|reboot|rebuild|resize|rescue)" | head -1)
    EXTRA=""
    if echo "$COMMAND" | grep -qE "[[:space:]]rebuild([[:space:]]|$)"; then
      EXTRA=" 'rebuild' wipes all disks and reinstalls from an image."
    fi
    echo "WARN: This linode-cli command performs a destructive operation ($ACTION).${EXTRA} Ensure the user is aware this will modify or remove cloud resources. Note: a shut-down Linode still bills; only deleting it stops charges."
    exit 0
  fi
done

exit 0
