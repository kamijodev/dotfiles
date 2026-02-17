# Noctalia Shell プラグイン開発

カスタムプラグインを作成・修正する際のリファレンス。

## ディレクトリ構成

```
~/.config/noctalia/plugins/<plugin-id>/
├── manifest.json      # プラグイン定義（必須）
├── Main.qml           # メインロジック（必須）
├── BarWidget.qml      # バーウィジェット（任意）
├── Panel.qml          # パネルUI（任意）
├── DesktopWidget.qml  # デスクトップウィジェット（任意）
├── Settings.qml       # 設定UI（任意）
└── settings.json      # ランタイム設定（自動生成、chezmoi管理不要）
```

## manifest.json

```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "minNoctaliaVersion": "4.0.0",
  "author": "emacs",
  "license": "MIT",
  "description": "プラグインの説明",
  "entryPoints": {
    "main": "Main.qml",
    "barWidget": "BarWidget.qml",
    "panel": "Panel.qml",
    "settings": "Settings.qml"
  },
  "dependencies": { "plugins": [] },
  "metadata": {
    "defaultSettings": {
      "key": "value"
    }
  }
}
```

使用するエントリーポイントのみ記載する。`settings.json` はランタイム用なので chezmoi 管理不要。

## plugins.json 登録

`~/.config/noctalia/plugins.json` の `states` にエントリを追加:

```json
{
  "states": {
    "my-plugin": {
      "enabled": true
    }
  }
}
```

**注意**: カスタムプラグインには `sourceUrl` を設定しない。`sourceUrl` があると公式リポジトリのプラグイン扱いになり、存在しないプラグインページ (`https://noctalia.dev/plugins/<id>`) へのリンクが表示される。

## エントリーポイント別の実装パターン

### Main.qml

プラグインのコアロジック。常時ロードされる。

```qml
import QtQuick

Item {
    id: root
    property var pluginApi: null

    Component.onCompleted: {
        // 初期化
    }
}
```

- `pluginApi.pluginSettings` で設定の読み書き
- `pluginApi.saveSettings()` で永続化
- `pluginApi.manifest` でmanifest.jsonにアクセス

### BarWidget.qml

バーに表示するウィジェット。

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root
    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    implicitWidth: row.implicitWidth + Style.marginM * 2
    implicitHeight: Style.capsuleHeight

    // パネルを開く
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: pluginApi.openPanel(root.screen)
    }

    // 設定を開く
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: BarService.openPluginSettings(root.screen, pluginApi.manifest)
    }
}
```

### Panel.qml

バーウィジェットクリック等で表示されるパネル。

```qml
Item {
    id: root
    property var pluginApi: null
    property ShellScreen screen

    readonly property var geometryPlaceholder: root
    property real contentPreferredWidth: 400 * Style.uiScaleRatio
    property real contentPreferredHeight: 600 * Style.uiScaleRatio
    readonly property bool allowAttach: true
}
```

- `contentPreferredWidth` / `contentPreferredHeight` でパネルサイズを指定

### Settings.qml

設定UIはNPluginSettingsPopup内のNScrollView > Loaderに読み込まれる。

```qml
ColumnLayout {
    id: root
    property var pluginApi: null
    spacing: Style.marginL

    function saveSettings() {
        // pluginApi.pluginSettings に書き込み
        pluginApi.saveSettings()
    }

    // 設定UIの中身
}
```

**重要**: ルートは必ず `ColumnLayout` にする。`Item` をルートにすると `implicitHeight` が0になり、設定画面の要素が重なるバグが発生する。

`saveSettings()` 関数はPopupの「適用」ボタンから呼ばれる。

## IPC

プラグイン間や外部からの通信に `IpcHandler` を使用:

```qml
IpcHandler {
    target: "plugin:<plugin-id>"

    function myAction() { /* ... */ }
    function getData(): string {
        return JSON.stringify({ key: "value" });
    }
}
```

## FileView によるファイル監視

外部プロセスの出力を監視してUIに反映する場合:

```qml
import Quickshell.Io

FileView {
    id: dataFile
    path: "/tmp/my-data.json"
    watchChanges: true
    preload: true
    onFileChanged: loadData()
}
```

## 既存プラグイン参考先

| プラグイン | 特徴 |
|-----------|------|
| gcal-reminder | FileView監視、通知キャプチャ、フルスクリーンオーバーレイ（Variants + PanelWindow） |
| todo（公式） | Settings.qmlの実装例、ページ管理、カラーピッカー |

公式プラグインのソースは `/etc/xdg/quickshell/noctalia-shell/` 以下や `~/.config/noctalia/plugins/todo/` で確認可能。
