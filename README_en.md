# claude-code-ffxiv-hooks

English | [日本語](./README.md)

Plays FINAL FANTASY XIV sound effects in response to Claude Code hook events.

## Overview

FFXIV SEs play when Claude Code completes various operations.

| Hook | Default SE | Trigger |
|------|-----------|---------|
| `Stop` | Quest Complete | Claude completes a turn's response and **waits for user input**. Fires every turn. |
| `SubagentStop` | Guildleve Complete | A subagent finishes |
| `Notification` | Incoming Tell 1 | When Claude sends a notification. **Suppressed if the terminal has focus** — only fires when focus is away (e.g., you've stepped away from your desk). |
| `PostToolUse` (Bash success) | Confirm | Shell command exits with 0 |
| `PostToolUse` (Bash failure) | Error | Shell command exits non-zero |
| `PostToolUse` (Edit/Write/MultiEdit) | Obtain Item | When a **file edit/create tool** completes. Fires once per file — multiple edits in one turn trigger it multiple times. |

By default, **Stop and Notification are enabled**. Toggle hooks in `hooks-config.json`.

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
      "soundPath": "ffxiv_sounds/FFXIV_Incoming_Tell_1.mp3",
      "isEnable": true
    }
  ]
}
```

| Field | Description |
|---|---|
| `player` | `"auto"` / `"paplay"` / `"mpv"` / `"ffplay"` / `"aplay"` |
| `volume` | Volume level (0–100). Not supported by `aplay` |
| `hooks[].name` | Hook identifier (do not change) |
| `hooks[].soundPath` | Path relative to `sounds/` |
| `hooks[].isEnable` | `true` to enable, `false` to disable |

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
