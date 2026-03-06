# Window Map — Noctalia Shell プラグイン

niriのスクロール型タイリングで画面外のウィンドウ位置関係を把握するためのプラグイン。
バーウィジェットで現在のワークスペースのウィンドウをアイコン表示し、フォーカス移動時にオーバーレイで全体マップを表示する。

## 構成

```
~/.config/noctalia/plugins/window-map/
├── manifest.json      # プラグイン定義
├── Main.qml           # event-stream処理 + オーバーレイ
├── BarWidget.qml      # バーウィジェット（各画面のアクティブWSのウィンドウ表示）
└── Settings.qml       # 設定UI（アイコンサイズ変更）

~/.local/bin/
├── niri-window-map-data   # niri IPCから全データを1行JSON出力
└── niri-focus             # フォーカスアクション実行後にオーバーレイをトリガー
```

## 仕組み

### バーウィジェット（常時表示）

- `niri msg --json event-stream` を常時接続し、ウィンドウ・ワークスペースの状態をリアルタイム追跡
- 処理するイベント:
  - `WindowsChanged`: 初期ウィンドウ一覧
  - `WindowOpenedOrChanged`: ウィンドウの追加・プロパティ変更
  - `WindowClosed`: ウィンドウ削除
  - `WindowFocusChanged`: フォーカス変更
  - `WorkspacesChanged`: 初期ワークスペース一覧
  - `WorkspaceActivated`: ワークスペース切り替え
- 各画面のアクティブワークスペースのウィンドウをアイコンで横並び表示
- フォーカス中ウィンドウは黄色ボーダーでハイライト

### オーバーレイ（フォーカス移動時）

- `niri-focus` ラッパー経由でトリガー
- `niri-window-map-data` で全モニター・全ワークスペースのデータを取得
- `pos_in_scrolling_layout [column, tile]` に基づき空間配置を再現
- 全画面に半透明オーバーレイを表示、0.8秒後に自動非表示

### アイコン解決

`DesktopEntries.byId(appId)` → `heuristicLookup(appId)` → `"application-x-executable"` の順でフォールバック

## キーバインド

フォーカス系キーバインドは `niri-focus` ラッパー経由に変更済み:

- `Mod+A/D`: 左右カラム/モニター移動
- `Mod+W/S`: モニター上下
- `Mod+Up/Down`: ワークスペース上下
- `Mod+1-9`: ワークスペース直接移動
- `Mod+TAB`: 前のワークスペース
- `Mod+Home/End`: 最初/最後のカラム
- `Mod+Shift+矢印`: モニター間移動

`niri-focus` の中身:
```sh
#!/bin/sh
niri msg action "$@"
qs -c noctalia-shell ipc call plugin:window-map trigger
```

## 設定

プラグイン設定ページ（バーウィジェット右クリック → 設定）で変更可能:

| 設定 | デフォルト | 範囲 |
|------|-----------|------|
| バーのアイコンサイズ | 16px | 12-32px |
| オーバーレイのアイコンサイズ | 40px | 24-64px |

## IPC

手動テスト:
```sh
qs -c noctalia-shell ipc call plugin:window-map trigger
```

## 注意点

- IPC関数名に `show` は使えない（Qt組み込みの `QQuickItem::show()` と衝突）→ `trigger` を使用
- `IpcHandler` には `import Quickshell.Io` が必要
- event-stream切断時は2秒後に自動再接続
