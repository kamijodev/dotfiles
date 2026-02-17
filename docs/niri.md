# niri + Noctalia Shell

Wayland スクロール型タイリング WM (niri) と統合シェル UI (Noctalia Shell) の設定。

## 設定ファイル

| ファイル | 用途 |
|---------|------|
| `~/.config/niri/cfg/autostart.kdl` | 起動時に実行するアプリ |
| `~/.config/niri/cfg/keybinds.kdl` | キーバインド |
| `~/.config/niri/cfg/misc.kdl` | 環境変数・各種設定 |
| `~/.config/niri/cfg/rules.kdl` | ウィンドウルール |
| `~/.config/noctalia/plugins.json` | Noctalia Shell プラグイン設定 |
| `~/.local/bin/niri-toggle-maximize` | 最大化トグルスクリプト |

## 自動起動

niri 起動時に以下が自動実行される:

1. **Polkit 認証エージェント** (`/usr/lib/polkit-kde-authentication-agent-1`)
2. **Noctalia Shell** (`qs -c noctalia-shell`) — バー・ランチャー・通知・クリップボード・ロック画面・壁紙を統合

## 環境変数

| 変数 | 値 | 用途 |
|------|-----|------|
| ELECTRON_OZONE_PLATFORM_HINT | auto | Electron Wayland 最適化 |
| QT_QPA_PLATFORM | wayland | Qt Wayland 対応 |
| QT_WAYLAND_DISABLE_WINDOWDECORATION | 1 | Qt 窓装飾無効化 |
| XDG_SESSION_TYPE | wayland | セッション種別 |
| XDG_CURRENT_DESKTOP | niri | デスクトップ名 |
| QT_QPA_PLATFORMTHEME | gtk3 | Qt/GTK テーマ統一 |
| GTK_IM_MODULE | fcitx | fcitx5 IME (GTK) |
| QT_IM_MODULE | fcitx | fcitx5 IME (Qt) |
| XMODIFIERS | @im=fcitx | fcitx5 IME (X11) |

## その他設定

- `prefer-no-csd` — クライアント側デコレーション無効化
- `screenshot-path null` — スクリーンショット自動保存なし
- `hotkey-overlay` スキップ — 起動時のホットキーオーバーレイ非表示
- `honor-xdg-activation-with-invalid-serial` — Noctalia 通知と窓アクティベーション許可

## キーバインド (Mod = Super)

### アプリケーション起動

| キー | 動作 |
|------|------|
| Mod+Return | Alacritty |
| Mod+T | WezTerm |
| Mod+Space / Mod+Ctrl+Return | Noctalia ランチャー |
| Mod+B | Google Chrome Canary |
| Mod+E | Nautilus（フローティング） |
| Mod+Alt+L | ロック画面 |
| Mod+Shift+Q | セッションメニュー |

### ウィンドウ操作

| キー | 動作 |
|------|------|
| Mod+Q | ウィンドウを閉じる |
| Mod+A / D | フォーカス左/右 |
| Mod+H / L | ウィンドウ移動 左/右 |
| Mod+K / J | ウィンドウ移動 上/下 |
| Mod+Home / End | 最初/最後のカラムにフォーカス |
| Mod+F | フローティング切り替え |
| Mod+R | 最大化トグル |
| Mod+Ctrl+F | カラムを利用可能幅まで拡張 |
| Mod+Ctrl+C | カラムを中央寄せ |
| Mod+Minus / Equal | カラム幅 ±10% |
| Mod+Shift+Minus / Equal | ウィンドウ高さ ±10% |

### ワークスペース

| キー | 動作 |
|------|------|
| Mod+W / S | ワークスペース上/下 |
| Mod+1～9 | ワークスペース 1～9 にフォーカス |
| Mod+Ctrl+1～9 | ウィンドウをワークスペース 1～9 に移動 |
| Mod+TAB | 前のワークスペースに戻る |
| Mod+WheelScroll | ワークスペース上下切り替え |

### モニター

| キー | 動作 |
|------|------|
| Mod+Shift+Left/Right/Up/Down | モニター間フォーカス |
| Mod+Shift+P | モニター電源 OFF |

### メディア

- XF86Audio* キー: 音量、ミュート、マイクミュート
- XF86Audio* キー: メディア 次/前/再生
- XF86MonBrightness* キー: 明るさ調整

### 特殊操作

| キー | 動作 |
|------|------|
| Mod+N | スクリーンショット（grim+slurp+satty） |
| Mod+M | 画面録画トグル（wl-screenrec、20分制限） |
| Mod+Shift+V | クリップボード履歴 |
| Mod+Shift+R | Noctalia Shell 再起動 |
| Mod+O | オーバービュー |
| Mod+Escape | キーボードショートカット無効化トグル |
| Ctrl+Alt+Delete | niri 終了 |

## ウィンドウルール

| 対象 | ルール |
|------|--------|
| 全ウィンドウ | コーナー半径 20px、ジオメトリクリップ |
| Nautilus | フローティングで開く |
| Satty | フローティングで開く |

### レイヤールール

- `noctalia-wallpaper*`: バックドロップ内に配置（他の窓の下に表示）

## Noctalia Shell プラグイン

プラグインソース: `noctalia-dev/noctalia-plugins` (GitHub)

| プラグイン | 用途 |
|-----------|------|
| gcal-reminder | Google Calendar 通知（詳細は [gcalcli.md](gcalcli.md)） |
| todo | Todo 管理 |
