import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null

    property string filterMode: pluginApi?.pluginSettings?.filterMode ?? "all"
    property var filteredApps: (pluginApi?.pluginSettings?.filteredApps ?? []).slice()
    property int maxNotifications: pluginApi?.pluginSettings?.maxNotifications ?? 200

    property string newAppName: ""

    function saveSettings() {
        pluginApi.pluginSettings.filterMode = filterMode;
        pluginApi.pluginSettings.filteredApps = filteredApps.slice();
        pluginApi.pluginSettings.maxNotifications = maxNotifications;
        pluginApi.saveSettings();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.marginM
        spacing: Style.marginL

        // Filter mode
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NText {
                text: "キャプチャ対象"
                color: Color.mOnSurface
                pointSize: Style.fontSizeS
                font.bold: true
            }

            RowLayout {
                spacing: Style.marginM

                Rectangle {
                    width: allModeRow.implicitWidth + Style.marginM * 2
                    height: allModeRow.implicitHeight + Style.marginS * 2
                    radius: Style.radiusS
                    color: root.filterMode === "all" ? Color.mPrimaryContainer : Style.capsuleColor
                    border.color: root.filterMode === "all" ? Color.mPrimary : Color.mOutlineVariant
                    border.width: 1

                    RowLayout {
                        id: allModeRow
                        anchors.centerIn: parent
                        spacing: Style.marginXS

                        NText {
                            text: "すべての通知"
                            color: root.filterMode === "all" ? Color.mOnPrimaryContainer : Color.mOnSurface
                            pointSize: Style.fontSizeXS
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.filterMode = "all"
                    }
                }

                Rectangle {
                    width: filterModeRow.implicitWidth + Style.marginM * 2
                    height: filterModeRow.implicitHeight + Style.marginS * 2
                    radius: Style.radiusS
                    color: root.filterMode === "filter" ? Color.mPrimaryContainer : Style.capsuleColor
                    border.color: root.filterMode === "filter" ? Color.mPrimary : Color.mOutlineVariant
                    border.width: 1

                    RowLayout {
                        id: filterModeRow
                        anchors.centerIn: parent
                        spacing: Style.marginXS

                        NText {
                            text: "指定アプリのみ"
                            color: root.filterMode === "filter" ? Color.mOnPrimaryContainer : Color.mOnSurface
                            pointSize: Style.fontSizeXS
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.filterMode = "filter"
                    }
                }
            }
        }

        // App filter list
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS
            visible: root.filterMode === "filter"

            NText {
                text: "対象アプリ一覧"
                color: Color.mOnSurface
                pointSize: Style.fontSizeS
                font.bold: true
            }

            // Add new app
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: Style.radiusS
                    color: Style.capsuleColor
                    border.color: Color.mOutlineVariant
                    border.width: 1

                    TextInput {
                        id: appInput
                        anchors {
                            fill: parent
                            leftMargin: Style.marginS
                            rightMargin: Style.marginS
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        color: Color.mOnSurface
                        font.pointSize: Style.fontSizeXS
                        clip: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "アプリ名を入力..."
                            color: Color.mOnSurfaceVariant
                            font.pointSize: Style.fontSizeXS
                            visible: !appInput.text && !appInput.activeFocus
                        }

                        onAccepted: addApp()
                    }
                }

                Rectangle {
                    width: 36
                    height: 36
                    radius: Style.radiusS
                    color: addArea.containsMouse ? Color.mPrimaryContainer : Style.capsuleColor

                    NIcon {
                        anchors.centerIn: parent
                        icon: "plus"
                        color: Color.mPrimary
                        width: Style.fontSizeIconS
                        height: Style.fontSizeIconS
                    }

                    MouseArea {
                        id: addArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: addApp()
                    }
                }
            }

            // App list
            Column {
                Layout.fillWidth: true
                spacing: Style.marginXS

                Repeater {
                    model: root.filteredApps

                    Rectangle {
                        width: parent.width
                        height: appRow.implicitHeight + Style.marginS * 2
                        radius: Style.radiusS
                        color: Style.capsuleColor

                        required property string modelData
                        required property int index

                        RowLayout {
                            id: appRow
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: Style.marginS
                            }
                            spacing: Style.marginS

                            NText {
                                text: modelData
                                color: Color.mOnSurface
                                pointSize: Style.fontSizeXS
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: Style.fontSizeIconS + Style.marginS
                                height: Style.fontSizeIconS + Style.marginS
                                radius: Style.radiusS
                                color: removeArea.containsMouse
                                    ? Qt.rgba(Color.mError.r, Color.mError.g, Color.mError.b, 0.2)
                                    : "transparent"

                                NIcon {
                                    anchors.centerIn: parent
                                    icon: "close"
                                    color: Color.mError
                                    width: Style.fontSizeIconXS
                                    height: Style.fontSizeIconXS
                                }

                                MouseArea {
                                    id: removeArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: removeApp(index)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Max notifications
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            RowLayout {
                spacing: Style.marginS

                NText {
                    text: "最大保持数"
                    color: Color.mOnSurface
                    pointSize: Style.fontSizeS
                    font.bold: true
                }

                NText {
                    text: root.maxNotifications.toString()
                    color: Color.mPrimary
                    pointSize: Style.fontSizeS
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 50
                to: 500
                stepSize: 50
                value: root.maxNotifications
                onMoved: root.maxNotifications = Math.round(value)
            }
        }

        Item { Layout.fillHeight: true }
    }

    function addApp() {
        var name = appInput.text.trim();
        if (name === "") return;
        if (filteredApps.indexOf(name) !== -1) return;
        var apps = filteredApps.slice();
        apps.push(name);
        filteredApps = apps;
        appInput.text = "";
    }

    function removeApp(index) {
        var apps = filteredApps.slice();
        apps.splice(index, 1);
        filteredApps = apps;
    }
}
