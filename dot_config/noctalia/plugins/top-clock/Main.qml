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
    property bool tpInhibited: true
    property bool padInhibited: true

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
    readonly property color gbBgDim:   "#1b1b1b"
    readonly property color gbBg5:     "#5a524c"

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

    function truncTitle(t) {
        var w = 0;
        for (var i = 0; i < t.length; i++) {
            w += t.charCodeAt(i) > 0x7F ? 2 : 1;
            if (w > 16) return t.substring(0, i) + "...";
        }
        return t;
    }

    property real memTotal: 0
    property real memUsed: 0
    property real swapTotal: 0
    property real swapUsed: 0
    property real cpuUsage: 0
    property real cpuTemp: 0

    property var _prevCpuIdle: 0
    property var _prevCpuTotal: 0

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

    FileView {
        id: tpStateFile
        path: "/tmp/internal-tp-state"
        watchChanges: true
        preload: true
        onFileChanged: tpStateFile.reload()
        onLoaded: {
            var content = tpStateFile.text().trim();
            root.tpInhibited = (content === "1");
        }
    }

    FileView {
        id: padStateFile
        path: "/tmp/internal-pad-state"
        watchChanges: true
        preload: true
        onFileChanged: padStateFile.reload()
        onLoaded: {
            var content = padStateFile.text().trim();
            root.padInhibited = (content === "1");
        }
    }

    Process {
        id: kbdToggle
        command: ["pkexec", "/home/emacs/.local/bin/toggle-internal-kbd", "kbd"]
        onRunningChanged: {
            if (!running) kbdStateUpdate.running = true
        }
    }

    Process {
        id: tpToggle
        command: ["pkexec", "/home/emacs/.local/bin/toggle-internal-kbd", "tp"]
        onRunningChanged: {
            if (!running) tpStateUpdate.running = true
        }
    }

    Process {
        id: padToggle
        command: ["pkexec", "/home/emacs/.local/bin/toggle-internal-kbd", "pad"]
        onRunningChanged: {
            if (!running) padStateUpdate.running = true
        }
    }

    Process {
        id: kbdStateUpdate
        command: ["sh", "-c", "cat /sys/devices/platform/i8042/serio0/input/input*/inhibited > /tmp/internal-kbd-state"]
    }

    Process {
        id: tpStateUpdate
        command: ["sh", "-c", "cat /sys/devices/platform/i8042/serio1/input/input*/inhibited > /tmp/internal-tp-state"]
    }

    Process {
        id: padStateUpdate
        command: ["sh", "-c", "cat /sys/devices/pci0000:00/0000:00:15.3/i2c_designware.1/i2c-1/i2c-ELAN06D4:00/0018:04F3:32B5.*/input/input*/inhibited | head -1 > /tmp/internal-pad-state"]
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

    Process {
        id: memInfoRead
        command: ["cat", "/proc/meminfo"]
        property real _memTotal: 0
        property real _memAvail: 0
        property real _swapTotal: 0
        property real _swapFree: 0
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/);
                if (parts[0] === "MemTotal:") memInfoRead._memTotal = parseInt(parts[1]);
                else if (parts[0] === "MemAvailable:") memInfoRead._memAvail = parseInt(parts[1]);
                else if (parts[0] === "SwapTotal:") memInfoRead._swapTotal = parseInt(parts[1]);
                else if (parts[0] === "SwapFree:") memInfoRead._swapFree = parseInt(parts[1]);
            }
        }
        onRunningChanged: {
            if (!running) {
                root.memTotal = _memTotal / 1048576;
                root.memUsed = (_memTotal - _memAvail) / 1048576;
                root.swapTotal = _swapTotal / 1048576;
                root.swapUsed = (_swapTotal - _swapFree) / 1048576;
            }
        }
    }

    FileView {
        id: cpuTempFile
        path: "/sys/class/thermal/thermal_zone9/temp"
        watchChanges: false
        preload: true
        onLoaded: {
            var v = parseInt(cpuTempFile.text().trim());
            if (!isNaN(v)) root.cpuTemp = v / 1000;
        }
    }

    Process {
        id: cpuStatRead
        command: ["head", "-1", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/);
                if (parts[0] !== "cpu") return;
                var vals = [];
                for (var i = 1; i < parts.length; i++) vals.push(parseInt(parts[i]));
                var idle = vals[3] + (vals[4] || 0);
                var total = 0;
                for (var j = 0; j < vals.length; j++) total += vals[j];
                var dIdle = idle - root._prevCpuIdle;
                var dTotal = total - root._prevCpuTotal;
                if (root._prevCpuTotal > 0 && dTotal > 0) {
                    root.cpuUsage = (1 - dIdle / dTotal) * 100;
                }
                root._prevCpuIdle = idle;
                root._prevCpuTotal = total;
            }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 3000
        onTriggered: {
            memInfoRead.running = true;
            cpuStatRead.running = true;
            cpuTempFile.reload();
        }
        Component.onCompleted: {
            memInfoRead.running = true;
            cpuStatRead.running = true;
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

    Timer {
        running: true
        repeat: true
        interval: 5000
        onTriggered: {
            kbdStateUpdate.running = true;
            tpStateUpdate.running = true;
            padStateUpdate.running = true;
        }
    }

    Component.onCompleted: {
        var now = new Date();
        currentTime = Qt.formatTime(now, "HH:mm:ss");
        currentDate = Qt.formatDate(now, "MM/dd (ddd)");
        vpnCheck.running = true;
        kbdStateUpdate.running = true;
        tpStateUpdate.running = true;
        padStateUpdate.running = true;
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
                color: Qt.alpha(root.gbBgDim, 0.95)
                border.color: root.gbBg5
                border.width: Style.borderS + 1

                Row {
                    id: meterRow
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    Item {
                        width: kbdIcon.implicitWidth + 8
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: kbdIcon
                            anchors.centerIn: parent
                            text: root.kbdInhibited ? "󰌐" : "󰌌"
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 16
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

                    Item {
                        width: tpIcon.implicitWidth + 8
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: tpIcon
                            anchors.centerIn: parent
                            text: root.tpInhibited ? "󰍽" : "󰍾"
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 16
                            color: tpMouse.containsMouse
                                ? (root.tpInhibited ? root.gbFg : root.gbAqua)
                                : (root.tpInhibited ? root.gbGrey : root.gbGreen)
                        }

                        MouseArea {
                            id: tpMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tpToggle.running = true
                        }
                    }

                    Item {
                        width: padIcon.implicitWidth + 8
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: padIcon
                            anchors.centerIn: parent
                            text: root.padInhibited ? "󰟸" : "󰟹"
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 16
                            color: padMouse.containsMouse
                                ? (root.padInhibited ? root.gbFg : root.gbAqua)
                                : (root.padInhibited ? root.gbGrey : root.gbGreen)
                        }

                        MouseArea {
                            id: padMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: padToggle.running = true
                        }
                    }

                    Text {
                        text: root.currentDate
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.gbYellow
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.currentTime
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: root.vpnConnected
                        text: "VPN Connected"
                        font.family: "Maple Mono NF CN"
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
                            font.family: "Maple Mono NF CN"
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
                color: Qt.alpha(root.gbBgDim, 0.95)
                border.color: root.gbBg5
                border.width: Style.borderS + 1

                Row {
                    id: calRow
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    NIcon {
                        icon: "calendar"
                        pointSize: 12
                        color: root.gbRed
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: !root.hasCalendarInfo
                        text: "予定なし"
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.gbGrey
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: root.currentEvent !== null
                        text: root.currentEvent ? root.truncTitle(root.currentEvent.title) + " (" + root.currentEvent.start + "〜" + root.currentEvent.end + ")" : ""
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.gbYellow
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: root.currentEvent !== null && root.nextEvent !== null
                        text: "→"
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.gbGrey
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: root.nextEvent !== null
                        text: root.nextEvent ? root.truncTitle(root.nextEvent.title) + " (" + root.nextEvent.start + "〜" + root.nextEvent.end + ")" : ""
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
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

            visible: true

            WlrLayershell.namespace: "top-mem"
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

            width: memFrame.width + 2
            height: memFrame.height + 2

            Rectangle {
                id: memFrame
                width: memRow.width + Style.marginL * 2
                height: memRow.height + Style.marginM * 2
                anchors.centerIn: parent
                radius: Style.radiusXS
                color: Qt.alpha(root.gbBgDim, 0.95)
                border.color: root.gbBg5
                border.width: Style.borderS + 1

                Row {
                    id: memRow
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    Text {
                        text: "\ue266"
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 16
                        color: root.cpuUsage > 80 ? root.gbRed : root.cpuUsage > 50 ? root.gbYellow : root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.cpuUsage.toFixed(0) + "%"
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.cpuUsage > 80 ? root.gbRed : root.cpuUsage > 50 ? root.gbYellow : root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "\uf2c9"
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 16
                        color: root.cpuTemp > 80 ? root.gbRed : root.cpuTemp > 60 ? root.gbYellow : root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.cpuTemp.toFixed(0) + "°C"
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.cpuTemp > 80 ? root.gbRed : root.cpuTemp > 60 ? root.gbYellow : root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "󰍛"
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 18
                        color: root.memTotal > 0 && root.memUsed / root.memTotal > 0.8 ? root.gbRed : root.memTotal > 0 && root.memUsed / root.memTotal > 0.5 ? root.gbYellow : root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.memUsed.toFixed(1) + "/" + root.memTotal.toFixed(1) + " GiB"
                        font.family: "Maple Mono NF CN"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: root.memTotal > 0 && root.memUsed / root.memTotal > 0.8 ? root.gbRed : root.memTotal > 0 && root.memUsed / root.memTotal > 0.5 ? root.gbYellow : root.gbFg
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
