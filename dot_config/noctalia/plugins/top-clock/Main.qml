import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null
    property string currentTime: ""
    property string currentDate: ""
    property bool vpnConnected: false
    property bool recording: false
    property int recordingSeconds: 0
    property var todayEvents: []
    property int calRefreshTick: 0
    property bool kbdInhibited: true

    // Gruvbox Material Dark palette
    readonly property color gbFg:      "#d4be98"
    readonly property color gbBg:      "#282828"
    readonly property color gbBg1:     "#32302f"
    readonly property color gbBg2:     "#45403d"
    readonly property color gbGrey:    "#928374"
    readonly property color gbRed:     "#ea6962"
    readonly property color gbOrange:  "#e78a4e"
    readonly property color gbYellow:  "#d8a657"
    readonly property color gbGreen:   "#a9b665"
    readonly property color gbAqua:    "#89b482"
    readonly property color gbBlue:    "#7daea3"
    readonly property color gbPurple:  "#d3869b"

    readonly property var currentEvent: {
        void root.calRefreshTick;
        var now = new Date();
        var nowMin = now.getHours() * 60 + now.getMinutes();
        for (var i = 0; i < todayEvents.length; i++) {
            var ev = todayEvents[i];
            if (ev.title === "稼働") continue;
            var sp = ev.start.split(":");
            var startMin = parseInt(sp[0]) * 60 + parseInt(sp[1]);
            var ep = ev.end.split(":");
            var endMin = ep.length === 2 ? parseInt(ep[0]) * 60 + parseInt(ep[1]) : startMin + 60;
            if (nowMin >= startMin && nowMin < endMin) return ev;
        }
        return null;
    }

    readonly property var nextEvent: {
        void root.calRefreshTick;
        var now = new Date();
        var nowMin = now.getHours() * 60 + now.getMinutes();
        var best = null;
        var bestDiff = Infinity;
        for (var i = 0; i < todayEvents.length; i++) {
            var ev = todayEvents[i];
            if (ev.title === "稼働") continue;
            var sp = ev.start.split(":");
            var startMin = parseInt(sp[0]) * 60 + parseInt(sp[1]);
            if (startMin > nowMin && startMin - nowMin < bestDiff) {
                bestDiff = startMin - nowMin;
                best = ev;
            }
        }
        return best;
    }

    readonly property bool hasCalendarInfo: currentEvent !== null || nextEvent !== null

    property string weztermCwd: ""

    FileView {
        id: kbdStateFile
        path: "/tmp/internal-kbd-state"
        watchChanges: true
        preload: true
        onFileChanged: kbdStateFile.reload()
        onLoaded: {
            var content = kbdStateFile.text().trim();
            root.kbdInhibited = (content === "1");
        }
    }

    Process {
        id: kbdToggle
        command: ["pkexec", "/home/emacs/.local/bin/toggle-internal-kbd"]
        onRunningChanged: {
            if (!running) kbdStateUpdate.running = true
        }
    }

    Process {
        id: kbdStateUpdate
        command: ["sh", "-c", "cat /sys/devices/platform/i8042/serio0/input/input3/inhibited > /tmp/internal-kbd-state"]
    }

    Process {
        id: kanataStart
        command: ["systemctl", "--user", "start", "kanata.service"]
    }

    Process {
        id: kanataStop
        command: ["systemctl", "--user", "stop", "kanata.service"]
    }

    onKbdInhibitedChanged: {
        if (kbdInhibited) {
            kanataStop.running = true;
        } else {
            kanataStart.running = true;
        }
    }

    FileView {
        id: cwdFile
        path: "/tmp/wezterm-cwd.txt"
        watchChanges: true
        preload: true
        onFileChanged: cwdFile.reload()
        onLoaded: {
            var content = cwdFile.text().trim();
            root.weztermCwd = content;
        }
    }

    FileView {
        id: todayFile
        path: "/tmp/gcal-today-events.json"
        watchChanges: true
        preload: true
        onFileChanged: todayFile.reload()
        onLoaded: {
            var content = todayFile.text();
            if (content) {
                try {
                    var data = JSON.parse(content);
                    if (Array.isArray(data)) root.todayEvents = data;
                } catch (e) {}
            }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            var now = new Date();
            root.currentTime = Qt.formatTime(now, "HH:mm:ss");
            root.currentDate = Qt.formatDate(now, "MM/dd (ddd)");
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 60000
        onTriggered: {
            root.calRefreshTick++;
            todayFile.reload();
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 5000
        onTriggered: vpnCheck.running = true
    }

    property bool _vpnFound: false

    Process {
        id: vpnCheck
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "connection", "show", "--active"]
        stdout: SplitParser {
            onRead: data => {
                if (data.indexOf("vpn:activated") !== -1) {
                    root._vpnFound = true;
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root._vpnFound = false;
            } else {
                root.vpnConnected = root._vpnFound;
            }
        }
    }

    property bool _recordingFound: false

    Process {
        id: recordingCheck
        command: ["sh", "-c", "[ -f /tmp/wl-screenrec.pid ] && kill -0 $(cat /tmp/wl-screenrec.pid) 2>/dev/null && echo recording"]
        stdout: SplitParser {
            onRead: data => {
                if (data === "recording") {
                    root._recordingFound = true;
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root._recordingFound = false;
            } else {
                root.recording = root._recordingFound;
            }
        }
    }

    Timer {
        running: root.recording
        repeat: true
        interval: 1000
        onTriggered: root.recordingSeconds += 1
    }

    Timer {
        running: true
        repeat: true
        interval: 2000
        onTriggered: recordingCheck.running = true
        Component.onCompleted: recordingCheck.running = true
    }

    onRecordingChanged: {
        if (!recording) {
            recordingSeconds = 0;
        }
    }

    Component.onCompleted: {
        var now = new Date();
        currentTime = Qt.formatTime(now, "HH:mm:ss");
        currentDate = Qt.formatDate(now, "MM/dd (ddd)");
        vpnCheck.running = true;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData

            focusable: true

            WlrLayershell.namespace: "top-clock"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
            }

            margins {
                top: 12
            }

            color: "transparent"

            width: frame.width + 2
            height: frame.height + 2

            Rectangle {
                id: frame
                width: meterRow.width + Style.marginL * 2
                height: meterRow.height + Style.marginM * 2
                anchors.centerIn: parent
                radius: Style.radiusXS
                color: Qt.alpha("#151515", 0.95)
                border.color: "#666666"
                border.width: Style.borderS + 1

                Row {
                    id: meterRow
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    Item {
                        width: kbdIcon.implicitWidth + 8
                        height: 28
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: kbdIcon
                            anchors.centerIn: parent
                            text: root.kbdInhibited ? "󰌐" : "󰌌"
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 18
                            color: kbdMouse.containsMouse
                                ? (root.kbdInhibited ? root.gbFg : root.gbAqua)
                                : (root.kbdInhibited ? root.gbGrey : root.gbGreen)
                        }

                        MouseArea {
                            id: kbdMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: kbdToggle.running = true
                        }
                    }

                    Text {
                        text: root.currentDate
                        font.family: "Maple Mono NF"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: root.gbYellow
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        spacing: 2

                        Repeater {
                            model: 8

                            delegate: Item {
                                required property int index
                                readonly property string ch: root.currentTime.charAt(index)
                                readonly property bool isColon: index === 2 || index === 5

                                width: isColon ? 10 : 24
                                height: 28

                                Rectangle {
                                    anchors.fill: parent
                                    visible: !parent.isColon
                                    radius: Style.radiusXXXS
                                    color: Color.mSurface
                                    border.color: "#666666"
                                    border.width: Style.borderS

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        radius: Style.radiusXXXS
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.03) }
                                            GradientStop { position: 0.35; color: "transparent" }
                                            GradientStop { position: 1.0; color: "transparent" }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "8"
                                        font.family: "Maple Mono NF"
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                        color: Qt.alpha(root.gbFg, 0.08)
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.ch
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: parent.isColon ? 16 : 20
                                    font.weight: Font.Bold
                                    color: Qt.alpha(root.gbFg, 0.3)
                                    style: Text.Outline
                                    styleColor: Qt.alpha(root.gbFg, 0.1)
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.ch
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: parent.isColon ? 16 : 18
                                    font.weight: Font.Bold
                                    color: root.gbFg
                                }
                            }
                        }
                    }

                    Text {
                        visible: root.vpnConnected
                        text: "VPN Connected"
                        font.family: "Maple Mono NF"
                        font.pixelSize: Style.fontSizeS
                        font.weight: Font.DemiBold
                        color: root.gbGreen
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        visible: root.recording
                        spacing: Style.marginXS
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: root.gbRed
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation on opacity {
                                running: root.recording
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                            }
                        }

                        Text {
                            text: {
                                var m = Math.floor(root.recordingSeconds / 60);
                                var s = root.recordingSeconds % 60;
                                return "REC " + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
                            }
                            font.family: "Maple Mono NF"
                            font.pixelSize: Style.fontSizeS
                            font.weight: Font.DemiBold
                            color: root.gbRed
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData

            visible: true

            WlrLayershell.namespace: "top-cal"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                left: true
            }

            margins {
                top: 12
                left: 8
            }

            color: "transparent"

            width: calFrame.width + 2
            height: calFrame.height + 2

            Rectangle {
                id: calFrame
                width: calRow.width + Style.marginL * 2
                height: calRow.height + Style.marginM * 2
                anchors.centerIn: parent
                radius: Style.radiusXS
                color: Qt.alpha("#151515", 0.95)
                border.color: "#666666"
                border.width: Style.borderS + 1

                Row {
                    id: calRow
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    NIcon {
                        icon: "calendar"
                        pointSize: 18
                        color: root.gbRed
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: !root.hasCalendarInfo
                        text: "予定なし"
                        font.family: "Maple Mono NF"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: root.gbGrey
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: root.currentEvent !== null
                        text: root.currentEvent ? root.currentEvent.title + " (" + root.currentEvent.start + "〜" + root.currentEvent.end + ")" : ""
                        font.family: "Maple Mono NF"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: root.gbYellow
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: root.currentEvent !== null && root.nextEvent !== null
                        text: "→"
                        font.family: "Maple Mono NF"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: root.gbGrey
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: root.nextEvent !== null
                        text: root.nextEvent ? root.nextEvent.title + " (" + root.nextEvent.start + "〜" + root.nextEvent.end + ")" : ""
                        font.family: "Maple Mono NF"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData

            visible: root.weztermCwd !== ""

            WlrLayershell.namespace: "top-cwd"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                right: true
            }

            margins {
                top: 12
                right: 8
            }

            color: "transparent"

            width: cwdFrame.width + 2
            height: cwdFrame.height + 2

            Rectangle {
                id: cwdFrame
                width: cwdRow.width + Style.marginL * 2
                height: cwdRow.height + Style.marginM * 2
                anchors.centerIn: parent
                radius: Style.radiusXS
                color: Qt.alpha("#151515", 0.95)
                border.color: "#666666"
                border.width: Style.borderS + 1

                Row {
                    id: cwdRow
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    NIcon {
                        icon: "folder"
                        pointSize: 18
                        color: root.gbAqua
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.weztermCwd.replace(/^\/home\/[^/]+\//, "~/")
                        font.family: "Maple Mono NF"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
