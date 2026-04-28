#!/bin/bash
HOOK_NAME="$1"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$REPO_DIR/hooks-config.json"

IS_ENABLE=$(jq -r --arg n "$HOOK_NAME" '.hooks[] | select(.name == $n) | .isEnable' "$CONFIG")
[ "$IS_ENABLE" != "true" ] && exit 0

VOLUME=$(jq -r '.volume // 100' "$CONFIG")
SOUND=$(jq -r --arg n "$HOOK_NAME" '.hooks[] | select(.name == $n) | .soundPath' "$CONFIG")
PLAYER=$(jq -r '.player // "auto"' "$CONFIG")

play_sound() {
  local file="$REPO_DIR/sounds/$SOUND"
  case "$1" in
    paplay) paplay --volume="$((VOLUME * 65536 / 100))" "$file" & ;;
    mpv)    mpv --volume="$VOLUME" --no-terminal "$file" & ;;
    ffplay) ffplay -nodisp -autoexit -volume "$VOLUME" "$file" 2>/dev/null & ;;
    aplay)  aplay "$file" & ;;
  esac
}

if [ "$PLAYER" = "auto" ]; then
  for cmd in paplay mpv ffplay aplay; do
    command -v "$cmd" &>/dev/null && play_sound "$cmd" && exit 0
  done
  echo "[ffxiv-hooks] No audio player found. Install paplay, mpv, ffplay, or aplay." >&2
else
  play_sound "$PLAYER"
fi
