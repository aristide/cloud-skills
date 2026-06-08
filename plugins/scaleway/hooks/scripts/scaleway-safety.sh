#!/bin/bash

# scaleway safety hook - warns Claude about destructive Scaleway CLI operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is an `scw` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])scw[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (verb appears as an `scw ... <verb>` subcommand).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]terminate([[:space:]]|$)"
  "[[:space:]]stop([[:space:]]|$)"
  "[[:space:]]reboot([[:space:]]|$)"
  "[[:space:]]remove([[:space:]]|$)"
  "[[:space:]]detach([[:space:]]|$)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|terminate|stop|reboot|remove|detach)" | head -1)
    echo "WARN: This scw command performs a destructive operation ($ACTION). Ensure the user is aware this will modify or remove cloud resources, and that the correct profile/zone is targeted. Note: 'server delete' can orphan volumes/IPs that keep billing — 'terminate' or 'with-volumes=all with-ip=true' removes them too."
    exit 0
  fi
done

exit 0
