import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

Item {
    id: root
    property var pluginApi: null
    property string currentTime: ""
    property bool vpnConnected: false
    property bool cameraEnabled: false
    property bool recording: false
    property int recordingSeconds: 0

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            root.currentTime = Qt.formatTime(new Date(), "HH:mm:ss");
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

    Process {
        id: cameraCheck
        command: ["lsmod"]
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("uvcvideo")) {
                    root.cameraEnabled = true;
                }
            }
        }
        onRunningChanged: {
            if (running) {
                root.cameraEnabled = false;
            }
        }
    }

    Process {
        id: cameraToggle
        command: root.cameraEnabled
            ? ["sudo", "modprobe", "-r", "uvcvideo"]
            : ["sudo", "modprobe", "uvcvideo"]
        onExited: cameraCheck.running = true
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
        currentTime = Qt.formatTime(new Date(), "HH:mm:ss");
        vpnCheck.running = true;
        cameraCheck.running = true;
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
                top: 8
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
                color: Color.mSurfaceVariant
                border.color: Color.mOutline
                border.width: Style.borderS

                Row {
                    id: meterRow
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    Text {
                        text: root.cameraEnabled ? "\u{F0100}" : "\u{F0101}"
                        font.family: "Maple Mono NF"
                        font.pixelSize: Style.fontSizeXL
                        color: root.cameraEnabled ? Color.mPrimary : Color.mOnSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: cameraToggle.running = true
                        }
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
                                    border.color: Color.mOutline
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
                                        color: Qt.alpha(Color.mPrimary, 0.08)
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.ch
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: parent.isColon ? 16 : 20
                                    font.weight: Font.Bold
                                    color: Qt.alpha(Color.mPrimary, 0.3)
                                    style: Text.Outline
                                    styleColor: Qt.alpha(Color.mPrimary, 0.1)
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.ch
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: parent.isColon ? 16 : 18
                                    font.weight: Font.Bold
                                    color: Color.mPrimary
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
                        color: Color.mPrimary
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
                            color: Color.mError
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
                            color: Color.mError
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
