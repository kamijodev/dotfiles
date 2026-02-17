# デスクトップ環境

- **OS**: CachyOS (Arch系) / Kernel: linux-cachyos
- **WM**: niri (Wayland スクロール型タイリング)
- **Shell UI**: Noctalia Shell (バー・ランチャー・通知・クリップボード・ロック画面・壁紙を統合)
- **Terminal**: WezTerm (メイン) / Alacritty (サブ)
- **Shell**: zsh + starship + sheldon
- **Editor**: Neovim (LazyVim)
- **Browser**: Google Chrome Canary
- **IME**: fcitx5 + Mozc (テーマ: Ori dark)
- **Audio**: PipeWire + WirePlumber
- **Font**: Hack Nerd Font / **Theme**: Gruvbox Material
- **Dotfiles**: chezmoi管理
- **ランタイム管理**: asdf
- **パッケージ**: pacman + paru (AUR)

## 主要キーバインド (Mod = Super)

| キー | 動作 |
|------|------|
| Mod+Return | Alacritty |
| Mod+T | WezTerm |
| Mod+Space | アプリランチャー |
| Mod+B | Chrome Canary |
| Mod+E | Nautilus (フローティング) |
| Mod+Q | ウィンドウを閉じる |
| Mod+A/D | フォーカス左/右 |
| Mod+W/S | ワークスペース上/下 |
| Mod+H/L | ウィンドウ移動 左/右 |
| Mod+K/J | ウィンドウ移動 上/下 |
| Mod+F | フローティング切替 |
| Mod+R | 最大化トグル |
| Mod+N | スクリーンショット (grim+slurp+satty) |
| Mod+M | 画面録画トグル (wl-screenrec) |
| Mod+Shift+V | クリップボード履歴 |
| Mod+Shift+R | Noctalia Shell 再起動 |
| Mod+O | オーバービュー |

## Noctalia Shell プラグイン開発

プラグインの作成・修正時は `~/.local/share/chezmoi/docs/noctalia-plugin-dev.md` を参照すること。

## カスタムサービス

- **Google Calendar 通知**: gcalcli + systemd timer (1分毎) → `gcalcli-notify` で `notify-send -a 'Google Calendar'` + サウンド再生
- **gcal-reminder プラグイン**: Noctalia Shell プラグイン。Google Calendar 通知をキャプチャし手動で閉じるまで保持。@3m以内でフルスクリーンアラート表示（バーウィジェット + パネル）
