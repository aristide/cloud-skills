#!/bin/bash

# __PROVIDER_DISPLAY__ safety hook - warns Claude about destructive __CLI__ operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is a `__CLI__` command.
# The pattern matches the binary as a standalone word at the start of a command segment.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])__CLI__[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns for this provider. EDIT THESE for the real CLI's verbs.
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]terminate([[:space:]]|$)"
  "[[:space:]]destroy([[:space:]]|$)"
  "[[:space:]]stop([[:space:]]|$)"
  "[[:space:]]remove([[:space:]]|$)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(delete|terminate|destroy|stop|remove)" | head -1)
    echo "WARN: This __CLI__ command performs a destructive operation ($ACTION). Ensure the user is aware this will modify or remove cloud resources, and that the correct account/region is targeted."
    exit 0
  fi
done

exit 0
