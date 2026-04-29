# claude-code-ffxiv-hooks

English | [日本語](./README.md)

Plays FINAL FANTASY XIV sound effects in response to Claude Code hook events.

## Overview

FFXIV SEs play when Claude Code completes various operations.

| Hook                                 | Default SE             | Trigger                                                                                                                                                |
| ------------------------------------ | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Stop`                               | Notification           | Claude completes a turn's response and **waits for user input**. Fires every turn.                                                                     |
| `SubagentStop`                       | Guildleve Complete     | A subagent finishes                                                                                                                                    |
| `Notification`                       | Linkshell Transmission | When Claude sends a notification. **Suppressed if the terminal has focus** — only fires when focus is away (e.g., you've stepped away from your desk). |
| `PermissionRequest`                  | Feature Unlocked       | When Claude **requests permission** to perform a tool call or action.                                                                                  |
| `PostToolUse` (Bash success)         | Confirm                | Shell command exits with 0                                                                                                                             |
| `PostToolUse` (Bash failure)         | Error                  | Shell command exits non-zero                                                                                                                           |
| `PostToolUse` (Edit/Write/MultiEdit) | Obtain Item            | When a **file edit/create tool** completes. Fires once per file — multiple edits in one turn trigger it multiple times.                                |

By default, **Stop, Notification, and PermissionRequest are enabled**. Toggle hooks in `hooks-config.json`.

## Requirements

- [Claude Code](https://claude.ai/code)
- `jq`
- `bash`
- One of the following audio players (checked in order):
    - `paplay` (recommended): bundled with PipeWire / PulseAudio
    - `mpv`: `sudo pacman -S mpv` / `sudo apt install mpv`
    - `ffplay`: `sudo pacman -S ffmpeg` / `sudo apt install ffmpeg`
    - `aplay`: bundled with ALSA (volume control not supported)

## Installation

Clone the repository:

```bash
git clone https://github.com/RyoK73/claude-code-ffxiv-hooks.git
cd claude-code-ffxiv-hooks
```

### Project-level install (specific project only)

Run from the root of the project you want to apply hooks to:

```bash
bash /path/to/claude-code-ffxiv-hooks/scripts/install.sh --local
```

Writes hooks to `.claude/settings.json`. Existing settings are automatically backed up.

### User-level install (all projects)

Run directly in a terminal to write to `~/.claude/settings.json`:

```bash
bash /path/to/claude-code-ffxiv-hooks/scripts/install.sh --global
```

## Configuration: hooks-config.json

Edit `hooks-config.json` in the repository root to change SE settings **without re-running install.sh**.

```json
{
    "player": "auto",
    "volume": 80,
    "hooks": [
        {
            "name": "Notification",
            "hookEvent": "Notification",
            "soundPath": "ffxiv_sounds/FFXIV_Incoming_Tell_1.mp3",
            "isEnable": true
        }
    ]
}
```

| Field                | Description                                                                 |
| -------------------- | --------------------------------------------------------------------------- |
| `player`             | `"auto"` / `"paplay"` / `"mpv"` / `"ffplay"` / `"aplay"`                    |
| `volume`             | Volume level (0–100). Not supported by `aplay`                              |
| `hooks[].name`       | Hook identifier                                                             |
| `hooks[].hookEvent`  | Claude Code hook event name this entry maps to                              |
| `hooks[].soundPath`  | Path relative to `sounds/` (single sound)                                   |
| `hooks[].soundPaths` | Array of paths to play in sequence. Takes precedence over `soundPath`       |
| `hooks[].isEnable`   | `true` to enable, `false` to disable                                        |
| `hooks[].matcher`    | (PostToolUse only) Tool name matcher pattern                                |
| `hooks[].script`     | (PostToolUse only) Custom script filename. Defaults to `play.sh` if omitted |

### Playing multiple sounds in sequence

Use `soundPaths` (array) to play multiple SEs in order for a single hook event.

```json
{
    "name": "Stop",
    "hookEvent": "Stop",
    "soundPaths": ["ffxiv_sounds/FFXIV_Fanfare.mp3", "ffxiv_sounds/FFXIV_Notification.mp3"],
    "isEnable": true
}
```

- Each sound plays to completion before the next starts (sequential playback)
- The hook command returns immediately — Claude Code is not blocked
- If both `soundPath` and `soundPaths` are present, `soundPaths` takes precedence

### Adding new hooks

Add an entry to `hooks-config.json` and re-run `install.sh` — the new hook is automatically registered in `settings.json`.

**Adding a simple hook** (like `Stop` or `Notification`):

```json
{
    "name": "PreToolUse",
    "hookEvent": "PreToolUse",
    "soundPath": "third_party/my_sound.mp3",
    "isEnable": true
}
```

**Adding a new PostToolUse matcher**:

```json
{
    "name": "PostToolUse_Read",
    "hookEvent": "PostToolUse",
    "matcher": "Read",
    "soundPath": "ffxiv_sounds/FFXIV_Confirm.mp3",
    "isEnable": true
}
```

After adding entries, re-run `install.sh` to apply.

## Adding Custom Sounds

Place any MP3 file in `sounds/third_party/` and set `soundPath` to `"third_party/filename.mp3"` in `hooks-config.json`. No script changes needed.

## Backup and Restore

`install.sh` automatically backs up the existing `settings.json` before each run (up to 5 backups retained).

To restore a previous state:

```bash
# Restore project-level settings
bash /path/to/claude-code-ffxiv-hooks/scripts/restore.sh --local

# Restore user-level settings
bash /path/to/claude-code-ffxiv-hooks/scripts/restore.sh --global
```

A numbered list of backups is shown. Enter a number and press Enter to restore (press Enter without input to restore the latest).

## Directory Structure

```
sounds/
├── ffxiv_sounds/        # FINAL FANTASY XIV sound effects
└── third_party/         # User-supplied sounds
scripts/
├── install.sh           # Installation script
├── restore.sh           # Backup restore script
├── play.sh              # SE playback script
└── play_bash_result.sh  # Plays SE based on Bash exit code
```

## License

### Scripts and configuration files

`scripts/` and `hooks-config.json` are released under the [MIT License](./LICENSE).

### FFXIV sound effects

Sound effects in `sounds/ffxiv_sounds/` are the property of **SQUARE ENIX CO., LTD.** and are not covered by the MIT License.

> © SQUARE ENIX

Please review the [FINAL FANTASY XIV Materials Usage License](http://support.jp.square-enix.com/rule.php?id=5381&la=0&tag=authc) before use. These sounds may only be used for **non-commercial, personal purposes**.

### Third-party sounds

Any sounds placed in `sounds/third_party/` are used at your own responsibility. Always verify the license of any sound you add.
