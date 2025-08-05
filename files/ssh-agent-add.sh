#!/bin/bash

set -e

mkdir -p ~/.tmp/ssh-agent/

AGENTS_FILE=~/.tmp/ssh-agent/agents

# Maximum number of hours to keep ssh-agent cache file around
MAX_HOURS=8

if [ -f "$AGENTS_FILE" ]; then
  mtime=$(stat -c %Y "$AGENTS_FILE")
  now=$(date +%s)
  age=$(( (now - mtime) / 3600 ))

  if [ "$age" -gt "$MAX_HOURS" ]; then
    rm "$AGENTS_FILE"
    echo "Delete $AGENTS_FILE (older than $MAX_HOURS hours)."
  fi
fi

touch "$AGENTS_FILE"
chmod 600 "$AGENTS_FILE"

# Clean up dead agents and pick a live one, if any
NEW_AGENTS=""
SELECTED=""

while read -r sock pid; do
  if [ -S "$sock" ] && kill -0 "$pid" 2>/dev/null; then
    if [ -z "$SELECTED" ]; then
      SELECTED="$sock $pid"
    fi
  NEW_AGENTS+="$sock $pid"$'\n'
  fi
done < "$AGENTS_FILE"

echo -n "$NEW_AGENTS" > "$AGENTS_FILE"

if [ -n "$SELECTED" ]; then
  # Use existing agent
  export SSH_AUTH_SOCK="${SELECTED%% *}"
  export SSH_AGENT_PID="${SELECTED##* }"
else
  # Start a new agent
  eval "$(ssh-agent -s)" >/dev/null
  echo "$SSH_AUTH_SOCK $SSH_AGENT_PID" >> "$AGENTS_FILE"

  # Add key with lifetime is starting a new agent
  ssh-add -t 36000 ~/.ssh/id_rsa
fi

# Print for eval'ing
echo "export SSH_AUTH_SOCK='$SSH_AUTH_SOCK'"
echo "export SSH_AGENT_PID='$SSH_AGENT_PID'"
