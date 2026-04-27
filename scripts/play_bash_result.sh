#!/bin/bash
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INPUT=$(cat)
EXIT_CODE=$(printf '%s' "$INPUT" | jq -r '.tool_response.exit_code // 0')
if [ "$EXIT_CODE" = "0" ]; then
  paplay "$REPO_DIR/sounds/ffxiv_sounds/FFXIV_Confirm.mp3" &
else
  paplay "$REPO_DIR/sounds/ffxiv_sounds/FFXIV_Error.mp3" &
fi
