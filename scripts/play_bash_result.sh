#!/bin/bash
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INPUT=$(cat)
EXIT_CODE=$(printf '%s' "$INPUT" | jq -r '.tool_response.exit_code // 0')

if [ "$EXIT_CODE" = "0" ]; then
  exec "$REPO_DIR/scripts/play.sh" "PostToolUse_Bash_Success"
else
  exec "$REPO_DIR/scripts/play.sh" "PostToolUse_Bash_Failure"
fi
