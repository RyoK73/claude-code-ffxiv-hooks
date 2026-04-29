#!/bin/bash
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "${1:-}" in
  --global|-g)
    TARGET_DIR="$HOME/.claude"
    COPY_SCRIPTS=false ;;
  --local|-l|"")
    TARGET_DIR="$(realpath -m "${2:-${PWD}}")/.claude"
    COPY_SCRIPTS=true ;;
  *)
    echo "Usage: install.sh [--local|-l [PATH] (default) | --global|-g]"
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

CONFIG="$REPO_DIR/hooks-config.json"

if [ ! -f "$CONFIG" ]; then
  echo "Error: hooks-config.json not found at $CONFIG" >&2
  exit 1
fi

# --local: copy scripts into TARGET_DIR so hook commands stay within the
# project root and are not blocked by Claude Code's path restrictions.
if [ "$COPY_SCRIPTS" = "true" ]; then
  sed "s|REPO_DIR=.*|REPO_DIR=\"$REPO_DIR\"|" "$REPO_DIR/scripts/play.sh" > "$TARGET_DIR/play.sh"
  chmod +x "$TARGET_DIR/play.sh"

  cat > "$TARGET_DIR/play_bash_result.sh" << PLAY_BASH_EOF
#!/bin/bash
INPUT=\$(cat)
EXIT_CODE=\$(printf '%s' "\$INPUT" | jq -r '.tool_response.exit_code // 0')

if [ "\$EXIT_CODE" = "0" ]; then
  exec "$TARGET_DIR/play.sh" "PostToolUse_Bash_Success"
else
  exec "$TARGET_DIR/play.sh" "PostToolUse_Bash_Failure"
fi
PLAY_BASH_EOF
  chmod +x "$TARGET_DIR/play_bash_result.sh"
  SCRIPT_DIR="$TARGET_DIR"
else
  SCRIPT_DIR="$REPO_DIR/scripts"
fi

NEW_HOOKS=$(jq -n \
  --arg scripts "$SCRIPT_DIR" \
  --slurpfile cfg "$CONFIG" \
  '
  ($cfg[0].hooks) as $hooks |

  (
    $hooks
    | map(select(.hookEvent != "PostToolUse"))
    | map({
        key: .hookEvent,
        value: [{ hooks: [{ type: "command", command: ($scripts + "/play.sh " + .name) }] }]
      })
    | from_entries
  ) as $simple |

  (
    $hooks
    | map(select(.hookEvent == "PostToolUse"))
    | unique_by(.matcher)
    | map({
        matcher: .matcher,
        hooks: [{
          type: "command",
          command: (
            if .script != null
            then $scripts + "/" + .script
            else $scripts + "/play.sh " + .name
            end
          )
        }]
      })
  ) as $posttooluse |

  $simple
  + (if ($posttooluse | length) > 0
     then { PostToolUse: $posttooluse }
     else {}
     end)
  ')

if [ -f "$TARGET" ]; then
  jq --argjson h "$NEW_HOOKS" '.hooks = ((.hooks // {}) + $h)' "$TARGET" > /tmp/claude_merged.json
  mv /tmp/claude_merged.json "$TARGET"
else
  jq -n --argjson h "$NEW_HOOKS" '{hooks: $h}' > "$TARGET"
fi

echo "Installed to $TARGET"
