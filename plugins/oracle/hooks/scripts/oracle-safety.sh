#!/bin/bash

# oracle (OCI) safety hook - warns Claude about destructive oci operations.
# PreToolUse hook for Bash commands. Advisory only: always exits 0.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow silently unless this is an `oci` command.
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_-])oci[[:space:]]'; then
  exit 0
fi

# Destructive operations: terminate/delete subcommands, and power-off/reset via `--action`.
DESTRUCTIVE_PATTERNS=(
  "[[:space:]]terminate([[:space:]]|$)"
  "[[:space:]]delete([[:space:]]|$)"
  "[[:space:]]remove([[:space:]]|$)"
  "[[:space:]]detach([[:space:]]|$)"
  "--action[[:space:]=]+(STOP|RESET|SOFTRESET|SOFTSTOP)"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qEi "$PATTERN"; then
    ACTION=$(echo "$COMMAND" | grep -oEi "(terminate|delete|remove|detach|STOP|RESET|SOFTRESET|SOFTSTOP)" | head -1)
    echo "WARN: This oci command performs a destructive operation ($ACTION). Ensure the user is aware this will modify or remove cloud resources, and that the correct --profile/--region/--compartment-id is targeted. Note: terminating an instance keeps its boot volume billing unless --preserve-boot-volume false is set."
    exit 0
  fi
done

exit 0
