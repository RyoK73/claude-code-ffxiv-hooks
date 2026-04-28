#!/bin/bash
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "${1:-}" in
  --global|-g)
    TARGET_DIR="$HOME/.claude" ;;
  --local|-l|"")
    TARGET_DIR="${PWD}/.claude" ;;
  *)
    echo "Usage: install.sh [--local|-l (default) | --global|-g]"
    exit 1 ;;
esac

TARGET="$TARGET_DIR/settings.json"
mkdir -p "$TARGET_DIR"

if [ -f "$TARGET" ]; then
  BACKUP_DIR="$TARGET_DIR/settings_backups"
  mkdir -p "$BACKUP_DIR"
  cp "$TARGET" "$BACKUP_DIR/settings.$(date +%Y%m%d_%H%M%S).json"
  echo "Backup saved to $BACKUP_DIR"
  ls -t "$BACKUP_DIR"/settings.*.json | tail -n +6 | xargs rm -f 2>/dev/null
fi

NEW_HOOKS=$(jq -n \
  --arg repo "$REPO_DIR" \
  '{
    Stop: [{ hooks: [{ type: "command", command: ($repo + "/scripts/play.sh Stop") }] }],
    SubagentStop: [{ hooks: [{ type: "command", command: ($repo + "/scripts/play.sh SubagentStop") }] }],
    Notification: [{ hooks: [{ type: "command", command: ($repo + "/scripts/play.sh Notification") }] }],
    PostToolUse: [
      { matcher: "Bash", hooks: [{ type: "command", command: ($repo + "/scripts/play_bash_result.sh") }] },
      { matcher: "Edit|Write|MultiEdit", hooks: [{ type: "command", command: ($repo + "/scripts/play.sh PostToolUse_Edit") }] }
    ]
  }')

if [ -f "$TARGET" ]; then
  jq --argjson h "$NEW_HOOKS" '.hooks = ((.hooks // {}) + $h)' "$TARGET" > /tmp/claude_merged.json
  mv /tmp/claude_merged.json "$TARGET"
else
  jq -n --argjson h "$NEW_HOOKS" '{hooks: $h}' > "$TARGET"
fi

echo "Installed to $TARGET"
