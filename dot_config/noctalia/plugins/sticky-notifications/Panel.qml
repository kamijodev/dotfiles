import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Widgets

Item {
    id: panelContainer

    property var pluginApi: null
    property ShellScreen screen

    readonly property var geometryPlaceholder: panelContainer
    property real contentPreferredWidth: 500 * Style.uiScaleRatio
    property real contentPreferredHeight: 600 * Style.uiScaleRatio
    readonly property bool allowAttach: true

    readonly property var mainInstance: pluginApi?.mainInstance

    property var notifications: []

    property int refreshTick: 0

    Binding {
        target: panelContainer
        property: "notifications"
        value: pluginApi?.pluginSettings?.notifications ?? []
        when: pluginApi?.pluginSettings?.notifications !== undefined
        restoreMode: Binding.RestoreNone
    }

    Timer {
        running: true
        repeat: true
        interval: 60000
        onTriggered: panelContainer.refreshTick++
    }

    function timeAgo(timestamp) {
        void panelContainer.refreshTick;
        var now = Date.now();
        var diff = now - timestamp;
        var seconds = Math.floor(diff / 1000);
        var minutes = Math.floor(seconds / 60);
        var hours = Math.floor(minutes / 60);
        var days = Math.floor(hours / 24);

        if (days > 0) return days + "日前";
        if (hours > 0) return hours + "時間前";
        if (minutes > 0) return minutes + "分前";
        return "たった今";
    }

    function urgencyColor(urgency) {
        switch (urgency) {
            case 2: return Color.mError;
            case 1: return Color.mPrimary;
            default: return Color.mOnSurfaceVariant;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.marginM
        spacing: Style.marginM

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIcon {
                icon: "bell"
                color: Color.mPrimary
                Layout.preferredWidth: Style.fontSizeL
                Layout.preferredHeight: Style.fontSizeL
            }

            NText {
                text: "固定通知"
                color: Color.mOnSurface
                pointSize: Style.fontSizeM
                font.bold: true
                Layout.fillWidth: true
            }

            Rectangle {
                visible: panelContainer.notifications.length > 0
                width: clearRow.implicitWidth + Style.marginM * 2
                height: clearRow.implicitHeight + Style.marginS * 2
                radius: Style.iRadiusS
                color: mouseAreaClear.containsMouse
                    ? Qt.rgba(Color.mError.r, Color.mError.g, Color.mError.b, 0.2)
                    : "transparent"

                RowLayout {
                    id: clearRow
                    anchors.centerIn: parent
                    spacing: Style.marginXS

                    NIcon {
                        icon: "delete"
                        color: Color.mError
                        Layout.preferredWidth: Style.fontSizeS
                        Layout.preferredHeight: Style.fontSizeS
                    }

                    NText {
                        text: "すべてクリア"
                        color: Color.mError
                        pointSize: Style.fontSizeXS
                    }
                }

                MouseArea {
                    id: mouseAreaClear
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (mainInstance) mainInstance.dismissAll();
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Color.mOutlineVariant
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: notifColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: notifColumn
                width: parent.width
                spacing: Style.marginS

                Item {
                    visible: panelContainer.notifications.length === 0
                    width: parent.width
                    height: 200

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Style.marginM

                        NIcon {
                            icon: "bell"
                            color: Color.mOnSurfaceVariant
                            Layout.preferredWidth: Style.fontSizeXXL
                            Layout.preferredHeight: Style.fontSizeXXL
                            opacity: 0.4
                            Layout.alignment: Qt.AlignHCenter
                        }

                        NText {
                            text: "通知はありません"
                            color: Color.mOnSurfaceVariant
                            pointSize: Style.fontSizeS
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Repeater {
                    model: panelContainer.notifications

                    Rectangle {
                        id: card
                        width: notifColumn.width
                        height: cardLayout.implicitHeight + Style.marginM * 2
                        radius: Style.radiusM
                        color: Style.capsuleColor

                        required property var modelData
                        required property int index

                        ColumnLayout {
                            id: cardLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: Style.marginM
                            }
                            spacing: Style.marginXS

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Style.marginS

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: panelContainer.urgencyColor(card.modelData.urgency)
                                }

                                NText {
                                    text: card.modelData.appName
                                    pointSize: Style.fontSizeXS
                                    color: Color.mOnSurfaceVariant
                                }

                                Item { Layout.fillWidth: true }

                                NText {
                                    text: panelContainer.timeAgo(card.modelData.timestamp)
                                    pointSize: Style.fontSizeXS
                                    color: Color.mOnSurfaceVariant
                                }

                                Rectangle {
                                    width: Style.fontSizeM + Style.marginS
                                    height: Style.fontSizeM + Style.marginS
                                    radius: Style.iRadiusXS
                                    color: dismissArea.containsMouse
                                        ? Qt.rgba(Color.mOnSurface.r, Color.mOnSurface.g, Color.mOnSurface.b, 0.1)
                                        : "transparent"

                                    NIcon {
                                        anchors.centerIn: parent
                                        icon: "close"
                                        color: Color.mOnSurfaceVariant
                                        width: Style.fontSizeXS
                                        height: Style.fontSizeXS
                                    }

                                    MouseArea {
                                        id: dismissArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (mainInstance) mainInstance.dismissNotification(card.modelData.id);
                                        }
                                    }
                                }
                            }

                            NText {
                                visible: card.modelData.summary !== ""
                                text: card.modelData.summary
                                pointSize: Style.fontSizeS
                                color: Color.mOnSurface
                                font.bold: true
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            NText {
                                visible: card.modelData.body !== ""
                                text: card.modelData.body
                                pointSize: Style.fontSizeXS
                                color: Color.mOnSurfaceVariant
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                maximumLineCount: 4
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
