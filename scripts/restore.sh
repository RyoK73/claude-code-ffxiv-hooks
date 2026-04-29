#!/bin/bash
case "${1:-}" in
  --global|-g)
    TARGET_DIR="$HOME/.claude" ;;
  --local|-l|"")
    TARGET_DIR="$(realpath -m "${2:-${PWD}}")/.claude" ;;
  *)
    echo "Usage: restore.sh [--local|-l [PATH] (default) | --global|-g]"
    exit 1 ;;
esac

TARGET="$TARGET_DIR/settings.json"
BACKUP_DIR="$TARGET_DIR/settings_backups"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "No backups found at $BACKUP_DIR"
  exit 1
fi

mapfile -t BACKUPS < <(ls -t "$BACKUP_DIR"/settings.*.json 2>/dev/null)

if [ ${#BACKUPS[@]} -eq 0 ]; then
  echo "No backups found."
  exit 1
fi

echo "Available backups:"
for i in "${!BACKUPS[@]}"; do
  echo "  $((i + 1)). ${BACKUPS[$i]##*/}"
done
echo ""
read -rp "Select backup to restore [1 = latest]: " CHOICE
CHOICE=${CHOICE:-1}

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt ${#BACKUPS[@]} ]; then
  echo "Invalid selection."
  exit 1
fi

SELECTED="${BACKUPS[$((CHOICE - 1))]}"
cp "$SELECTED" "$TARGET"
echo "Restored: ${SELECTED##*/} → $TARGET"
