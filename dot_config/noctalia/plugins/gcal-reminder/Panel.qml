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
    property real contentPreferredWidth: 400 * Style.uiScaleRatio
    property real contentPreferredHeight: 600 * Style.uiScaleRatio
    readonly property bool allowAttach: true

    readonly property var mainInstance: pluginApi?.mainInstance

    property var todayEvents: pluginApi?.pluginSettings?.todayEvents ?? []

    property int refreshTick: 0

    Timer {
        running: true
        repeat: true
        interval: 60000
        onTriggered: panelContainer.refreshTick++
    }

    function isInProgress(ev) {
        void panelContainer.refreshTick;
        var now = new Date();
        var nowMin = now.getHours() * 60 + now.getMinutes();
        var sp = ev.start.split(":");
        var startMin = parseInt(sp[0]) * 60 + parseInt(sp[1]);
        var ep = ev.end.split(":");
        var endMin = ep.length === 2 ? parseInt(ep[0]) * 60 + parseInt(ep[1]) : startMin + 60;
        return nowMin >= startMin && nowMin < endMin;
    }

    function isPast(ev) {
        void panelContainer.refreshTick;
        var now = new Date();
        var nowMin = now.getHours() * 60 + now.getMinutes();
        var ep = ev.end.split(":");
        var endMin = ep.length === 2 ? parseInt(ep[0]) * 60 + parseInt(ep[1]) : 0;
        return endMin > 0 && nowMin >= endMin;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.marginM
        spacing: Style.marginM

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIcon {
                icon: "calendar"
                color: Color.mPrimary
                Layout.preferredWidth: Style.fontSizeL
                Layout.preferredHeight: Style.fontSizeL
            }

            NText {
                text: "今日の予定"
                color: Color.mOnSurface
                pointSize: Style.fontSizeM
                font.bold: true
                Layout.fillWidth: true
            }

            NText {
                text: panelContainer.todayEvents.length + "件"
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
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
            contentHeight: eventColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: eventColumn
                width: parent.width
                spacing: Style.marginXS

                Item {
                    visible: panelContainer.todayEvents.length === 0
                    width: parent.width
                    height: 200

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Style.marginM

                        NIcon {
                            icon: "calendar"
                            color: Color.mOnSurfaceVariant
                            Layout.preferredWidth: Style.fontSizeXXL
                            Layout.preferredHeight: Style.fontSizeXXL
                            opacity: 0.4
                            Layout.alignment: Qt.AlignHCenter
                        }

                        NText {
                            text: "予定はありません"
                            color: Color.mOnSurfaceVariant
                            pointSize: Style.fontSizeS
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Repeater {
                    model: panelContainer.todayEvents

                    Rectangle {
                        id: card
                        width: eventColumn.width
                        height: cardLayout.implicitHeight + Style.marginS * 2
                        radius: Style.radiusS
                        color: panelContainer.isInProgress(card.modelData)
                            ? Qt.rgba(Color.mPrimary.r, Color.mPrimary.g, Color.mPrimary.b, 0.12)
                            : "transparent"
                        opacity: panelContainer.isPast(card.modelData) ? 0.45 : 1.0

                        required property var modelData
                        required property int index

                        RowLayout {
                            id: cardLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: Style.marginS
                                rightMargin: Style.marginS
                            }
                            spacing: Style.marginM

                            // Time column
                            ColumnLayout {
                                Layout.preferredWidth: 50
                                spacing: 0

                                NText {
                                    text: card.modelData.start
                                    pointSize: Style.fontSizeS
                                    font.bold: panelContainer.isInProgress(card.modelData)
                                    color: panelContainer.isInProgress(card.modelData)
                                        ? Color.mPrimary : Color.mOnSurface
                                }

                                NText {
                                    text: card.modelData.end
                                    pointSize: Style.fontSizeXS
                                    color: Color.mOnSurfaceVariant
                                }
                            }

                            // Divider
                            Rectangle {
                                Layout.preferredWidth: 3
                                Layout.fillHeight: true
                                Layout.topMargin: Style.marginXS
                                Layout.bottomMargin: Style.marginXS
                                radius: 1.5
                                color: panelContainer.isInProgress(card.modelData)
                                    ? Color.mPrimary : Color.mOutlineVariant
                            }

                            // Title
                            NText {
                                Layout.fillWidth: true
                                text: card.modelData.title
                                pointSize: Style.fontSizeS
                                font.bold: panelContainer.isInProgress(card.modelData)
                                color: panelContainer.isInProgress(card.modelData)
                                    ? Color.mPrimary : Color.mOnSurface
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }
}
