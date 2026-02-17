# シェル環境

zsh + starship + sheldon による統合シェル環境。Gruvbox Material カラースキームで統一。

## 設定ファイル

| ファイル | 用途 |
|---------|------|
| `~/.zshrc` | インタラクティブシェル設定 |
| `~/.zshenv` | 環境変数（全 zsh プロセス） |
| `~/.config/sheldon/plugins.toml` | プラグイン管理 |
| `~/.config/starship.toml` | プロンプトテーマ |
| `~/.config/zsh/check-tools.zsh` | ツールインストール状態チェック |

## zsh 設定

### .zshenv

- Cargo (Rust) 環境変数の読み込み

### .zshrc

- 補完の初期化（compinit）
- PATH: `~/.local/bin`、asdf shims ディレクトリ
- starship 初期化
- sheldon 初期化
- check-tools.zsh の読み込み
- 履歴: `~/.zsh_history`、サイズ 10000、追記モード
- Ctrl+D で終了しない（IGNORE_EOF）

## sheldon プラグイン

| プラグイン | 用途 |
|-----------|------|
| zsh-history-substring-search | 履歴のサブストリング検索 |
| zsh-autosuggestions | コマンド自動サジェスト |
| zsh-syntax-highlighting | コマンドのシンタックスハイライト |

## starship プロンプト

Gruvbox Material カラーで統一されたプロンプト。表示順:

```
[時刻] Ram [メモリ%] (venv) パス > ブランチ ステータス >
```

| セグメント | 色 | 表示内容 |
|-----------|-----|---------|
| 時刻 | 赤 (#ea6962) | 現在時刻 |
| メモリ | 緑 (#a9b665) | RAM 使用率 |
| Python 仮想環境 | 黄 (#d8a657) | venv 名 |
| ディレクトリ | 青緑 (#7daea3) | カレントパス |
| Git ブランチ | オレンジ (#e78a4e) | ブランチ名 |
| Git ステータス | オレンジ (#e78a4e) | 変更状態 |

## check-tools.zsh

シェル起動時に必要なツールのインストール状態をチェックし、不足があれば通知する。

**チェック対象:**
- pacman: neovim, jq, libnotify, alacritty, wezterm, nautilus, grim, slurp, satty, wl-clipboard, websocat, aws-cli-v2
- AUR: google-chrome-canary, wl-screenrec, lotion-bin
- pip: gcalcli
- その他: claude (Claude Code CLI)

新しいツールを追加した場合はこのファイルにチェックを追加する。
