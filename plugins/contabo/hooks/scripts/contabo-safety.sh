#!/bin/bash

# contabo safety hook - warns Claude about destructive Contabo CLI operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is a `cntb` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])cntb[[:space:]]'; then
  exit 0
fi

# Destructive operation patterns (verb appears as a `cntb <verb> ...` subcommand).
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]cancel([[:space:]]|$)"
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]reinstall([[:space:]]|$)"
  "[[:space:]]stop([[:space:]]|$)"
  "[[:space:]]shutdown([[:space:]]|$)"
  "[[:space:]]restart([[:space:]]|$)"
  "[[:space:]]reset([[:space:]]|$)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oE "(cancel|delete|reinstall|stop|shutdown|restart|reset)" | head -1)
    EXTRA=""
    if echo "$COMMAND" | grep -qE "[[:space:]]cancel([[:space:]]|$)"; then
      EXTRA=" 'cntb cancel instance' ends the subscription/contract and is effectively irreversible."
    elif echo "$COMMAND" | grep -qE "[[:space:]]reinstall([[:space:]]|$)"; then
      EXTRA=" 'reinstall' wipes all data and redeploys the OS."
    fi
    echo "WARN: This cntb command performs a destructive operation ($ACTION).${EXTRA} Ensure the user is aware this will modify or remove cloud resources. Note: Contabo billing is subscription-based — stopping an instance does NOT stop billing."
    exit 0
  fi
done

exit 0
