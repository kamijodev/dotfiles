# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

## Environment

| | |
|---|---|
| OS | [CachyOS](https://cachyos.org/) (Arch Linux ベース) |
| Window Manager | [niri](https://github.com/YaLTeR/niri) (Wayland スクロール型タイリング WM) |
| Desktop Shell | [Noctalia Shell](https://github.com/nicefacer/noctalia) (Quickshell ベースのデスクトップシェル) |
| Input Method | fcitx5 (Mozc) |
| Terminal | WezTerm |
| Login Shell | Zsh |

## Setup

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply kamijodev
```

## Package Restore

```bash
sudo pacman -S --needed - < pkglist-pacman.txt
paru -S --needed - < pkglist-aur.txt
```

## Post-Install

chezmoi apply 後に必要な手動セットアップ:

- **ydotool**: `sudo usermod -aG input $USER` + udev ルール追加 + 再起動 → [docs/clipboard-autopaste.md](docs/clipboard-autopaste.md)
- **gcalcli**: GCP OAuth 設定 + `gcalcli init` + タイマー有効化 → [docs/gcalcli.md](docs/gcalcli.md)
- **wtype symlink**: `sudo ln -s ~/.local/bin/wtype /usr/local/bin/wtype`

## Usage

```bash
chezmoi add ~/.config/foo    # 設定ファイルを追加
chezmoi edit ~/.config/foo   # 編集
chezmoi apply                # 適用
chezmoi update               # リモートから更新
chezmoi diff                 # 差分確認
chezmoi cd                   # ソースディレクトリに移動
```

## Naming

- `dot_` → `.`
- `private_` → パーミッション 0600
- `executable_` → 実行権限付き

## Docs

詳細なドキュメントは [`docs/`](docs/) を参照。

| ドキュメント | 内容 |
|-------------|------|
| [audio.md](docs/audio.md) | オーディオ設定 |
| [clipboard.md](docs/clipboard.md) | クリップボード管理 (cliphist) |
| [clipboard-autopaste.md](docs/clipboard-autopaste.md) | クリップボード自動貼り付け (wtype→ydotool) |
| [fcitx5.md](docs/fcitx5.md) | 日本語入力 (fcitx5 + Mozc) |
| [gcalcli.md](docs/gcalcli.md) | Google Calendar 通知 |
| [neovim-codediff.md](docs/neovim-codediff.md) | Neovim コード差分 |
| [screenshot-recording.md](docs/screenshot-recording.md) | スクリーンショット・録画 |
| [url-dispatcher.md](docs/url-dispatcher.md) | URL ディスパッチャー |
