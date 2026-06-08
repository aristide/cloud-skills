#!/bin/bash

# azure safety hook - warns Claude about destructive Azure CLI operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is an `az` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])az[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (verb appears as an `az ... <verb>` subcommand).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]remove([[:space:]]|$)"
  "[[:space:]]deallocate([[:space:]]|$)"
  "[[:space:]]stop([[:space:]]|$)"
  "[[:space:]]restart([[:space:]]|$)"
  "[[:space:]]purge([[:space:]]|$)"
  "group[[:space:]]+delete"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|remove|deallocate|stop|restart|purge)" | head -1)
    EXTRA=""
    if echo "$COMMAND" | grep -qE "group[[:space:]]+delete"; then
      EXTRA=" 'az group delete' removes EVERY resource in the group."
    fi
    echo "WARN: This az command performs a destructive operation ($ACTION).${EXTRA} Ensure the user is aware this will modify or remove cloud resources, and that the correct --subscription/--resource-group is targeted."
    exit 0
  fi
done

exit 0
