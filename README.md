# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

## Setup

```bash
# chezmoiインストール
sh -c "$(curl -fsLS get.chezmoi.io)"

# dotfiles取得 & 適用
chezmoi init --apply kamijodev
```

## Contents

- nvim
- starship
- sheldon
- wezterm
- zsh
- git
- ssh
- Claude Code (settings, skills)

## Usage

### 設定ファイルを追加

```bash
chezmoi add ~/.config/foo/bar.toml
```

### 設定ファイルを編集

```bash
# chezmoi側を編集（推奨）
chezmoi edit ~/.config/nvim/init.lua

# 編集後に適用
chezmoi apply
```

または直接ファイルを編集後：

```bash
# 変更をchezmoiに取り込む
chezmoi add ~/.config/nvim/init.lua
```

### 差分確認

```bash
# ローカルとchezmoiの差分を確認
chezmoi diff
```

### 状態確認

```bash
# 管理中のファイル一覧
chezmoi managed

# chezmoiのソースディレクトリに移動
chezmoi cd
```

### 更新を取得

```bash
# リモートから最新を取得して適用
chezmoi update
```

## Template

マシン固有のパスは `{{ .chezmoi.homeDir }}` で動的に設定。

例: `dot_claude/settings.json.tmpl`
```json
{
  "trustedDirectories": [
    "{{ .chezmoi.homeDir }}/.config"
  ]
}
```

## Directory Structure

```
~/.local/share/chezmoi/
├── dot_claude/           → ~/.claude/
├── dot_config/           → ~/.config/
├── dot_gitconfig         → ~/.gitconfig
├── dot_zshenv            → ~/.zshenv
├── dot_zshrc             → ~/.zshrc
└── private_dot_ssh/      → ~/.ssh/
```

- `dot_` → `.`
- `private_` → パーミッション 0600
