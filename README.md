# claude-code-ffxiv-hooks

Claude Code のhookイベントに応じて、FINAL FANTASY XIV のサウンドエフェクトを再生するセットアップリポジトリです。

## 概要

Claude Code が各種操作を完了した際に、FFXIVのSEが鳴ります。

| Hook | デフォルトSE | 発生条件 |
|------|------------|----------|
| `Stop` | Quest Complete | Claudeが1ターンの応答を完了し、**ユーザーの入力待ち**になったとき。毎ターン必ず発火する |
| `SubagentStop` | Guildleve Complete | `Agent` ツールで起動した**サブエージェントが完了**したとき |
| `Notification` | Incoming Tell 1 | Claude が通知を送信するとき。ただし**ターミナルにフォーカスがある場合は抑制**される。席を外しているときなど、フォーカスが外れている状態でのみ実際に発火する |
| `PostToolUse` (Bash 成功) | Confirm | Bash ツールの実行が**終了コード 0** で正常終了したとき |
| `PostToolUse` (Bash 失敗) | Error | Bash ツールの実行が**終了コード 非0** でエラー終了したとき |
| `PostToolUse` (Edit/Write/MultiEdit) | Obtain Item | ファイルの**編集・作成ツール**が完了したとき。1ターン中に複数ファイルを編集すると複数回発火する |

デフォルトでは **Notification のみ有効**です。`hooks-config.json` で各hookの有効/無効を切り替えられます。

## 必要なもの

- [Claude Code](https://claude.ai/code)
- `jq`
- `bash`
- 以下いずれかのオーディオプレーヤー（優先順）:
  - `paplay`（推奨）: PipeWire / PulseAudio 環境に同梱
  - `mpv`: `sudo pacman -S mpv` / `sudo apt install mpv`
  - `ffplay`: `sudo pacman -S ffmpeg` / `sudo apt install ffmpeg`
  - `aplay`: ALSA 環境に同梱（音量調整非対応）

## インストール

リポジトリをクローンします。

```bash
git clone https://github.com/RyoK73/claude-code-ffxiv-hooks.git
cd claude-code-ffxiv-hooks
```

### プロジェクトレベルにインストール（特定プロジェクトのみ）

hookを適用したいプロジェクトのルートで実行します。

```bash
bash /path/to/claude-code-ffxiv-hooks/scripts/install.sh --local
```

`.claude/settings.json` にhookが書き込まれます。既存の設定がある場合は自動でバックアップされます。

### ユーザーレベルにインストール（全プロジェクト共通）

`~/.claude/settings.json` に書き込むため、ターミナルで直接実行してください。

```bash
bash /path/to/claude-code-ffxiv-hooks/scripts/install.sh --global
```

## 設定: hooks-config.json

リポジトリルートの `hooks-config.json` を編集することで、**install.sh の再実行なし**にSEの設定を変更できます。

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

| フィールド | 説明 |
|---|---|
| `player` | `"auto"` / `"paplay"` / `"mpv"` / `"ffplay"` / `"aplay"` |
| `volume` | 音量（0〜100）。`aplay` は非対応 |
| `hooks[].name` | hookの識別子（変更不可） |
| `hooks[].soundPath` | `sounds/` からの相対パス |
| `hooks[].isEnable` | `true` で有効、`false` で無効 |

## サードパーティSEの追加

`sounds/third_party/` に任意のMP3ファイルを配置し、`hooks-config.json` の `soundPath` に `"third_party/ファイル名.mp3"` と指定するだけで使用できます。

## バックアップと復元

`install.sh` は実行のたびに既存の `settings.json` をバックアップします（最大5件保持）。

元の状態に戻すには `restore.sh` を使用します。

```bash
# プロジェクトレベルを復元
bash /path/to/claude-code-ffxiv-hooks/scripts/restore.sh --local

# ユーザーレベルを復元
bash /path/to/claude-code-ffxiv-hooks/scripts/restore.sh --global
```

実行するとバックアップ一覧が表示されます。番号を選択してEnterを押すと復元されます（選択なしで最新を復元）。

## ディレクトリ構成

```
sounds/
├── ffxiv_sounds/   # FINAL FANTASY XIV のサウンドエフェクト
└── third_party/    # サードパーティ製サウンド（各自で追加）
scripts/
├── install.sh      # インストールスクリプト
├── restore.sh      # バックアップ復元スクリプト
├── play.sh         # SE再生スクリプト
└── play_bash_result.sh  # Bash結果に応じたSE再生
```

## ライセンス

### スクリプト・設定ファイル

`scripts/` および `hooks-config.json` は [MIT License](./LICENSE) のもとで公開しています。

### FFXIV サウンドエフェクトについて

`sounds/ffxiv_sounds/` に含まれるサウンドエフェクトは **SQUARE ENIX CO., LTD.** の著作物です。MITライセンスの適用範囲外となります。

> © SQUARE ENIX

ご利用の際は[ファイナルファンタジーXIV 著作物利用ルール](http://support.jp.square-enix.com/rule.php?id=5381&la=0&tag=authc)を必ずご確認ください。**非営利・個人利用の範囲内**でのみご使用いただけます。商用・営利目的での利用は禁止されています。

### サードパーティ製サウンドについて

`sounds/third_party/` に配置するサウンドは各自の責任のもとご利用ください。利用するサウンドのライセンスを必ずご確認ください。
