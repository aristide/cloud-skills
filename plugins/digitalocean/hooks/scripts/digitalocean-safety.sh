#!/bin/bash

# digitalocean safety hook - warns Claude about destructive doctl operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is a `doctl` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])doctl[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (doctl uses `delete` and droplet-action verbs).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "power-off"
  "power-cycle"
  "[[:space:]]shutdown([[:space:]]|$)"
  "[[:space:]]reboot([[:space:]]|$)"
  "[[:space:]]resize([[:space:]]|$)"
  "[[:space:]]rebuild([[:space:]]|$)"
  "[[:space:]]remove([[:space:]]|$)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|power-off|power-cycle|shutdown|reboot|resize|rebuild|remove)" | head -1)
    echo "WARN: This doctl command performs a destructive operation ($ACTION). Ensure the user is aware this will modify or remove cloud resources, and that the correct --context/--region is targeted. Note: a powered-off Droplet still bills; only deleting it stops charges."
    exit 0
  fi
done

exit 0
