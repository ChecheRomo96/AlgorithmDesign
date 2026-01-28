#!/usr/bin/env bash
set -e

# Directorio base (por defecto scripts/)
SCRIPTS_ROOT="${1:-scripts}"

if [ ! -d "$SCRIPTS_ROOT" ]; then
  echo "No scripts directory found at '${SCRIPTS_ROOT}'."
  exit 1
fi

echo "Enabling executable bit for .sh scripts inside '${SCRIPTS_ROOT}'..."

FILES=$(find "$SCRIPTS_ROOT" -type f -name "*.sh")

if [ -z "$FILES" ]; then
  echo "No .sh files found."
  exit 0
fi

echo "$FILES" | xargs chmod +x

COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
echo "Enabled executable bit on $COUNT file(s):"
echo "$FILES"
