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

NEW_HOOKS=$(sed "s|__REPO_DIR__|$REPO_DIR|g" "$REPO_DIR/settings.json" | jq '.hooks')

if [ -f "$TARGET" ]; then
  jq --argjson h "$NEW_HOOKS" '.hooks = $h' "$TARGET" > /tmp/claude_merged.json
  mv /tmp/claude_merged.json "$TARGET"
else
  sed "s|__REPO_DIR__|$REPO_DIR|g" "$REPO_DIR/settings.json" > "$TARGET"
fi
echo "Installed to $TARGET"
