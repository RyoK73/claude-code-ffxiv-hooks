# claude-code-ffxiv-hooks

Claude Code のhookイベントに応じて、FINAL FANTASY XIV のサウンドエフェクトを再生するセットアップリポジトリです。

## 概要

Claude Code が各種操作を完了した際に、FFXIVのSEが鳴ります。

| Hook | 再生されるSE | タイミング |
|------|------------|----------|
| `Stop` | Quest Complete | Claudeがタスクを完了したとき |
| `SubagentStop` | Guildleve Complete | サブエージェントが完了したとき |
| `Notification` | Incoming Tell 1 | 入力待ちなどの通知が来たとき |
| `PostToolUse` (Bash 成功) | Confirm | シェルコマンドが正常終了したとき |
| `PostToolUse` (Bash 失敗) | Error | シェルコマンドがエラー終了したとき |
| `PostToolUse` (Edit/Write/MultiEdit) | Obtain Item | ファイルが編集・作成されたとき |

## 必要なもの

- [Claude Code](https://claude.ai/code)
- `paplay`（PulseAudio / PipeWire）
- `jq`
- `bash`

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

`.claude/settings.json` にhookが追記されます。

### ユーザーレベルにインストール（全プロジェクト共通）

`~/.claude/settings.json` に書き込むため、ターミナルで直接実行してください。

```bash
bash /path/to/claude-code-ffxiv-hooks/scripts/install.sh --global
```

## ライセンス

### スクリプト・設定ファイル

`scripts/` および `settings.json` は [MIT License](./LICENSE) のもとで公開しています。

### サウンドエフェクトについて

`sounds/` に含まれるサウンドエフェクトは **SQUARE ENIX CO., LTD.** の著作物です。MITライセンスの適用範囲外となります。

> © SQUARE ENIX

ご利用の際は[ファイナルファンタジーXIV 著作物利用ルール](http://support.jp.square-enix.com/rule.php?id=5381&la=0&tag=authc)を必ずご確認ください。**非営利・個人利用の範囲内**でのみご使用いただけます。商用・営利目的での利用は禁止されています。
