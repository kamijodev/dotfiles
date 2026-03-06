import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Item {
    id: barWidget
    property var pluginApi: null
    property var screen: null
    property string widgetId: ""
    property string section: ""

    readonly property var mainInst: pluginApi?.mainInstance
    readonly property var allWindows: mainInst?.allWindows || []
    readonly property var allWorkspaces: mainInst?.allWorkspaces || []

    readonly property int iconSize: pluginApi?.pluginSettings?.barIconSize ?? 16
    readonly property int tileSize: iconSize + 6

    // Gruvbox
    readonly property color gbYellow: "#d8a657"

    // Active workspace on this screen
    readonly property var activeWs: {
        var name = screen?.name || "";
        for (var i = 0; i < allWorkspaces.length; i++) {
            var ws = allWorkspaces[i];
            if (ws.output === name && ws.is_active) return ws;
        }
        return null;
    }

    // Windows on active workspace, sorted by column then tile
    readonly property var currentWindows: {
        if (!activeWs) return [];
        var wins = [];
        for (var i = 0; i < allWindows.length; i++) {
            var w = allWindows[i];
            if (w.workspace_id === activeWs.id && !w.is_floating) {
                wins.push({
                    id: w.id,
                    appId: w.app_id,
                    isFocused: w.is_focused,
                    col: w.layout.pos_in_scrolling_layout[0],
                    tile: w.layout.pos_in_scrolling_layout[1],
                    iconName: mainInst ? mainInst.resolveIcon(w.app_id) : "application-x-executable"
                });
            }
        }
        wins.sort(function(a, b) {
            if (a.col !== b.col) return a.col - b.col;
            return a.tile - b.tile;
        });
        return wins;
    }

    implicitWidth: capsule.implicitWidth
    implicitHeight: Style.capsuleHeight

    visible: currentWindows.length > 0

    Rectangle {
        id: capsule
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: row.implicitWidth + Style.marginM * 2
        implicitHeight: Style.capsuleHeight
        radius: Style.radiusM
        color: Style.capsuleColor

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 3

            Repeater {
                model: barWidget.currentWindows

                delegate: Rectangle {
                    required property var modelData
                    property var win: modelData

                    Layout.preferredWidth: barWidget.tileSize
                    Layout.preferredHeight: barWidget.tileSize

                    radius: Style.radiusXS
                    color: "transparent"
                    border.color: win.isFocused ? barWidget.gbYellow : "transparent"
                    border.width: win.isFocused ? 2 : 0

                    Image {
                        anchors.centerIn: parent
                        source: Quickshell.iconPath(win.iconName, "application-x-executable")
                        sourceSize.width: barWidget.iconSize
                        sourceSize.height: barWidget.iconSize
                        width: barWidget.iconSize
                        height: barWidget.iconSize
                    }
                }
            }
        }
    }
}
