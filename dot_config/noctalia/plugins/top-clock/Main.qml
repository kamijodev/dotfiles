import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

Item {
    id: root
    property var pluginApi: null
    property string currentTime: ""

    readonly property color nixieAmber: "#FF8C00"
    readonly property color nixieGlow: Qt.rgba(1.0, 0.55, 0.0, 0.3)
    readonly property color nixieDim: Qt.rgba(1.0, 0.55, 0.0, 0.08)
    readonly property color tubeColor: "#080808"
    readonly property color frameColor: "#151515"
    readonly property color frameBorder: "#2a2a2a"

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            root.currentTime = Qt.formatTime(new Date(), "HH:mm:ss");
        }
    }

    Component.onCompleted: {
        currentTime = Qt.formatTime(new Date(), "HH:mm:ss");
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData

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

            width: frame.width
            height: frame.height

            Rectangle {
                id: frame
                width: meterRow.width + 14
                height: meterRow.height + 10
                anchors.centerIn: parent
                radius: 5
                color: root.frameColor
                border.color: root.frameBorder
                border.width: 1

                Row {
                    id: meterRow
                    anchors.centerIn: parent
                    spacing: 2

                    Repeater {
                        model: 8

                        delegate: Item {
                            required property int index
                            readonly property string ch: root.currentTime.charAt(index)
                            readonly property bool isColon: index === 2 || index === 5

                            width: isColon ? 10 : 24
                            height: 28

                            // Nixie tube
                            Rectangle {
                                anchors.fill: parent
                                visible: !parent.isColon
                                radius: 3
                                color: root.tubeColor
                                border.color: "#1a1a1a"
                                border.width: 1

                                // Glass reflection
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: 2
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
                                        GradientStop { position: 0.35; color: "transparent" }
                                        GradientStop { position: 1.0; color: "transparent" }
                                    }
                                }

                                // Unlit filament hint
                                Text {
                                    anchors.centerIn: parent
                                    text: "8"
                                    font.family: "Hack Nerd Font Mono"
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: root.nixieDim
                                }
                            }

                            // Glow layer
                            Text {
                                anchors.centerIn: parent
                                text: parent.ch
                                font.family: "Hack Nerd Font Mono"
                                font.pixelSize: parent.isColon ? 16 : 20
                                font.weight: Font.Bold
                                color: root.nixieGlow
                                style: Text.Outline
                                styleColor: Qt.rgba(1.0, 0.4, 0.0, 0.15)
                            }

                            // Digit
                            Text {
                                anchors.centerIn: parent
                                text: parent.ch
                                font.family: "Hack Nerd Font Mono"
                                font.pixelSize: parent.isColon ? 16 : 18
                                font.weight: Font.Bold
                                color: root.nixieAmber
                            }
                        }
                    }
                }
            }
        }
    }
}
