#!/bin/bash
HOOK_NAME="$1"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$REPO_DIR/hooks-config.json"

IS_ENABLE=$(jq -r --arg n "$HOOK_NAME" '.hooks[] | select(.name == $n) | .isEnable' "$CONFIG")
[ "$IS_ENABLE" != "true" ] && exit 0

VOLUME=$(jq -r '.volume // 100' "$CONFIG")
PLAYER=$(jq -r '.player // "auto"' "$CONFIG")

# soundPaths (配列) があればそれを使い、なければ soundPath (文字列) を単要素配列として扱う
HAS_PATHS=$(jq -r --arg n "$HOOK_NAME" \
  '.hooks[] | select(.name == $n) | .soundPaths | if . then "yes" else "no" end' "$CONFIG")

if [ "$HAS_PATHS" = "yes" ]; then
  mapfile -t SOUND_LIST < <(jq -r --arg n "$HOOK_NAME" \
    '.hooks[] | select(.name == $n) | .soundPaths[]' "$CONFIG")
else
  SINGLE=$(jq -r --arg n "$HOOK_NAME" \
    '.hooks[] | select(.name == $n) | .soundPath // empty' "$CONFIG")
  [ -z "$SINGLE" ] && exit 0
  SOUND_LIST=("$SINGLE")
fi

[ ${#SOUND_LIST[@]} -eq 0 ] && exit 0

resolve_player() {
  if [ "$PLAYER" = "auto" ]; then
    for cmd in paplay mpv ffplay aplay; do
      command -v "$cmd" &>/dev/null && echo "$cmd" && return
    done
    echo ""
  else
    echo "$PLAYER"
  fi
}

RESOLVED_PLAYER=$(resolve_player)

if [ -z "$RESOLVED_PLAYER" ]; then
  echo "[ffxiv-hooks] No audio player found. Install paplay, mpv, ffplay, or aplay." >&2
  exit 1
fi

play_sound() {
  local file="$REPO_DIR/sounds/$1"
  if [ ! -f "$file" ]; then
    echo "[ffxiv-hooks] Sound file not found: $file" >&2
    return 1
  fi
  case "$2" in
    paplay) paplay --volume="$((VOLUME * 65536 / 100))" "$file" ;;
    mpv)    mpv --volume="$VOLUME" --no-terminal "$file" ;;
    ffplay) ffplay -nodisp -autoexit -volume "$VOLUME" "$file" 2>/dev/null ;;
    aplay)  aplay "$file" ;;
  esac
}

(
  for sound in "${SOUND_LIST[@]}"; do
    play_sound "$sound" "$RESOLVED_PLAYER"
  done
) &
