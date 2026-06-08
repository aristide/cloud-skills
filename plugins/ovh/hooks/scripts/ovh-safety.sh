#!/bin/bash

# ovh (OpenStack) safety hook - warns Claude about destructive openstack operations.
# OVH Public Cloud is OpenStack-based, so this matches the `openstack` client.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is an `openstack` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])openstack[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (verb appears as an `openstack <noun> <verb>` subcommand).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]remove([[:space:]]|$)"
  "[[:space:]]stop([[:space:]]|$)"
  "[[:space:]]reboot([[:space:]]|$)"
  "[[:space:]]rebuild([[:space:]]|$)"
  "[[:space:]]resize([[:space:]]|$)"
  "[[:space:]]shelve([[:space:]]|$)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|remove|stop|reboot|rebuild|resize|shelve)" | head -1)
    echo "WARN: This openstack command performs a destructive operation ($ACTION) on OVH Public Cloud. Ensure the user is aware this will modify or remove cloud resources, and that the correct OS_REGION_NAME/project is targeted. Note: a stopped (SHUTOFF) instance still bills; only deleting it stops charges."
    exit 0
  fi
done

exit 0
