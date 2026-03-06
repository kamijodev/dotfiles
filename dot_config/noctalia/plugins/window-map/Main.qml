import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null

    // Shared state (event-stream driven, used by BarWidget)
    property var allWindows: []
    property var allWorkspaces: []

    // Overlay state
    property var mapModel: []
    property bool overlayVisible: false
    property bool pendingRefresh: false

    readonly property int iconSize: pluginApi?.pluginSettings?.overlayIconSize ?? 40
    readonly property int iconGap: 6
    readonly property int sectionPad: 14

    // Gruvbox Material Dark
    readonly property color gbFg:     "#d4be98"
    readonly property color gbBg:     "#282828"
    readonly property color gbBg1:    "#32302f"
    readonly property color gbYellow: "#d8a657"
    readonly property color gbAqua:   "#89b482"
    readonly property color gbGrey:   "#928374"

    // === Event Stream (real-time updates for bar widget) ===

    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => root.handleEvent(data)
        }

        onRunningChanged: {
            if (!running) restartTimer.start();
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        onTriggered: eventStream.running = true
    }

    function handleEvent(line) {
        try {
            var ev = JSON.parse(line);
            if (ev.WindowsChanged) {
                allWindows = ev.WindowsChanged.windows;
            } else if (ev.WindowOpenedOrChanged) {
                var w = ev.WindowOpenedOrChanged.window;
                var arr = allWindows.slice();
                var found = false;
                for (var i = 0; i < arr.length; i++) {
                    if (arr[i].id === w.id) {
                        arr[i] = w;
                        found = true;
                        break;
                    }
                }
                if (!found) arr.push(w);
                allWindows = arr;
            } else if (ev.WindowClosed) {
                var closedId = ev.WindowClosed.id;
                allWindows = allWindows.filter(function(x) { return x.id !== closedId; });
            } else if (ev.WorkspacesChanged) {
                allWorkspaces = ev.WorkspacesChanged.workspaces;
            } else if (ev.WindowFocusChanged) {
                var focusedId = ev.WindowFocusChanged.id;
                var arr = allWindows.slice();
                for (var i = 0; i < arr.length; i++) {
                    var copy = Object.assign({}, arr[i]);
                    copy.is_focused = (copy.id === focusedId);
                    arr[i] = copy;
                }
                allWindows = arr;
            } else if (ev.WorkspaceActivated) {
                var activatedId = ev.WorkspaceActivated.id;
                var isFocused = ev.WorkspaceActivated.focused;
                var arr = allWorkspaces.slice();
                for (var i = 0; i < arr.length; i++) {
                    var copy = Object.assign({}, arr[i]);
                    if (copy.id === activatedId) {
                        copy.is_active = true;
                        copy.is_focused = isFocused;
                    } else if (copy.output === arr.find(function(x) { return x.id === activatedId; })?.output) {
                        copy.is_active = false;
                        if (isFocused) copy.is_focused = false;
                    } else if (isFocused) {
                        copy.is_focused = false;
                    }
                    arr[i] = copy;
                }
                allWorkspaces = arr;
            }
        } catch (e) {}
    }

    function resolveIcon(appId) {
        var entry = DesktopEntries.byId(appId);
        if (!entry) entry = DesktopEntries.heuristicLookup(appId);
        return (entry && entry.icon) ? entry.icon : "application-x-executable";
    }

    // === Overlay (triggered by IPC from niri-focus) ===

    IpcHandler {
        target: "plugin:window-map"
        function trigger() {
            root.refreshOverlay();
        }
    }

    Process {
        id: dataProcess
        command: ["/home/emacs/.local/bin/niri-window-map-data"]
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                dataProcess.buffer += data + "\n";
            }
        }

        onRunningChanged: {
            if (!running) {
                if (buffer.length > 0) {
                    try {
                        var raw = JSON.parse(buffer);
                        root.mapModel = root.buildMap(raw);
                        if (root.mapModel.length > 0) {
                            root.overlayVisible = true;
                            hideTimer.restart();
                        }
                    } catch (e) {
                        console.error("window-map: parse error:", e);
                    }
                }
                buffer = "";
                if (root.pendingRefresh) {
                    root.pendingRefresh = false;
                    dataProcess.running = true;
                }
            }
        }
    }

    function refreshOverlay() {
        hideTimer.restart();
        if (dataProcess.running) {
            pendingRefresh = true;
            return;
        }
        dataProcess.running = true;
    }

    Timer {
        id: hideTimer
        interval: 800
        onTriggered: root.overlayVisible = false
    }

    function buildMap(data) {
        var windows = [];
        for (var i = 0; i < data.windows.length; i++) {
            if (!data.windows[i].is_floating) windows.push(data.windows[i]);
        }

        var outputMap = {};
        for (var i = 0; i < data.workspaces.length; i++) {
            var ws = data.workspaces[i];
            var out = data.outputs[ws.output];
            if (!out || !out.logical) continue;

            if (!outputMap[ws.output]) {
                outputMap[ws.output] = {
                    name: ws.output,
                    x: out.logical.x,
                    y: out.logical.y,
                    realWidth: out.logical.width,
                    workspaces: []
                };
            }
            outputMap[ws.output].workspaces.push({
                id: ws.id, idx: ws.idx,
                isActive: ws.is_active, isFocused: ws.is_focused,
                columns: {}
            });
        }

        for (var i = 0; i < windows.length; i++) {
            var w = windows[i];
            var pos = w.layout.pos_in_scrolling_layout;
            for (var oName in outputMap) {
                for (var j = 0; j < outputMap[oName].workspaces.length; j++) {
                    var wsObj = outputMap[oName].workspaces[j];
                    if (wsObj.id === w.workspace_id) {
                        if (!wsObj.columns[pos[0]]) wsObj.columns[pos[0]] = [];
                        wsObj.columns[pos[0]].push({
                            id: w.id,
                            appId: w.app_id,
                            title: w.title,
                            isFocused: w.is_focused,
                            iconName: resolveIcon(w.app_id),
                            tileIndex: pos[1]
                        });
                    }
                }
            }
        }

        var result = [];
        for (var oName in outputMap) {
            var o = outputMap[oName];
            for (var j = 0; j < o.workspaces.length; j++) {
                var wsObj = o.workspaces[j];
                var cols = [];
                var keys = Object.keys(wsObj.columns).sort(function(a, b) { return +a - +b; });
                for (var k = 0; k < keys.length; k++) {
                    var tiles = wsObj.columns[keys[k]];
                    tiles.sort(function(a, b) { return a.tileIndex - b.tileIndex; });
                    cols.push(tiles);
                }
                wsObj.columns = cols;
                wsObj.hasWindows = cols.length > 0;
            }
            o.workspaces = o.workspaces.filter(function(ws) {
                return ws.hasWindows || ws.isActive;
            });
            o.workspaces.sort(function(a, b) { return a.idx - b.idx; });
            if (o.workspaces.length > 0) result.push(o);
        }

        result.sort(function(a, b) {
            if (Math.abs(a.y - b.y) > 100) return a.y - b.y;
            return a.x - b.x;
        });
        return result;
    }

    // === Overlay Windows ===

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData
            visible: root.overlayVisible
            color: "transparent"

            WlrLayershell.namespace: "window-map-" + (screen?.name || "x")
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors { top: true; bottom: true; left: true; right: true }

            Rectangle {
                anchors.fill: parent
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.overlayVisible = false
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: cardCol.width + root.sectionPad * 2
                    height: cardCol.height + root.sectionPad * 2
                    radius: Style.radiusL
                    color: Qt.alpha(root.gbBg, 0.95)
                    border.color: Qt.alpha(root.gbGrey, 0.3)
                    border.width: 1

                    Column {
                        id: cardCol
                        anchors.centerIn: parent
                        spacing: root.sectionPad

                        Repeater {
                            model: root.mapModel

                            delegate: Rectangle {
                                id: monDel
                                required property var modelData
                                property var mon: modelData

                                width: monInner.width + root.sectionPad * 2
                                height: monInner.height + root.sectionPad * 2
                                radius: Style.radiusM
                                color: Qt.alpha(root.gbBg1, 0.7)
                                border.color: Qt.alpha(root.gbGrey, 0.15)
                                border.width: 1

                                Column {
                                    id: monInner
                                    anchors.centerIn: parent
                                    spacing: root.iconGap

                                    Text {
                                        text: monDel.mon.name
                                        color: root.gbGrey
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                    }

                                    Repeater {
                                        model: monDel.mon.workspaces

                                        delegate: Column {
                                            id: wsDel
                                            required property var modelData
                                            required property int index
                                            property var ws: modelData

                                            spacing: 4

                                            Rectangle {
                                                width: wsRow.width > 0 ? wsRow.width : 40
                                                height: 1
                                                color: Qt.alpha(root.gbGrey, 0.2)
                                                visible: wsDel.index > 0
                                            }

                                            Text {
                                                text: "WS " + wsDel.ws.idx
                                                color: wsDel.ws.isFocused
                                                    ? root.gbYellow
                                                    : wsDel.ws.isActive
                                                        ? root.gbAqua
                                                        : Qt.alpha(root.gbGrey, 0.5)
                                                font.pixelSize: 10
                                                visible: monDel.mon.workspaces.length > 1
                                            }

                                            Row {
                                                id: wsRow
                                                spacing: root.iconGap

                                                Repeater {
                                                    model: wsDel.ws.columns

                                                    delegate: Column {
                                                        id: colDel
                                                        required property var modelData
                                                        property var tiles: modelData
                                                        spacing: root.iconGap

                                                        Repeater {
                                                            model: colDel.tiles

                                                            delegate: Rectangle {
                                                                required property var modelData
                                                                property var tile: modelData

                                                                width: root.iconSize + 10
                                                                height: root.iconSize + 10
                                                                radius: Style.radiusS
                                                                color: tile.isFocused
                                                                    ? Qt.alpha(root.gbYellow, 0.15)
                                                                    : "transparent"
                                                                border.color: tile.isFocused
                                                                    ? root.gbYellow
                                                                    : "transparent"
                                                                border.width: tile.isFocused ? 2 : 0

                                                                Image {
                                                                    anchors.centerIn: parent
                                                                    source: Quickshell.iconPath(tile.iconName, "application-x-executable")
                                                                    sourceSize.width: root.iconSize
                                                                    sourceSize.height: root.iconSize
                                                                    width: root.iconSize
                                                                    height: root.iconSize
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                Text {
                                                    text: "(empty)"
                                                    color: Qt.alpha(root.gbGrey, 0.3)
                                                    font.pixelSize: 10
                                                    visible: wsDel.ws.columns.length === 0
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
