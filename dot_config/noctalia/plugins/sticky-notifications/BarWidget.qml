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

    readonly property int notifCount: {
        var val = pluginApi?.pluginSettings?.count;
        return (val !== undefined && val !== null) ? Number(val) : 0;
    }

    readonly property string latestSummary: {
        var notifs = pluginApi?.pluginSettings?.notifications;
        if (!notifs || notifs.length === 0) return "";
        var n = notifs[0];
        return n.summary || n.body || "";
    }

    implicitWidth: row.implicitWidth + Style.marginM * 2
    implicitHeight: Style.capsuleHeight

    Rectangle {
        anchors.fill: parent
        radius: Style.radiusM
        color: Style.capsuleColor

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Style.marginS

            NIcon {
                icon: "bell"
                color: root.notifCount > 0 ? Color.mPrimary : Color.mOnSurfaceVariant
                Layout.preferredWidth: Style.fontSizeM
                Layout.preferredHeight: Style.fontSizeM
            }

            NText {
                visible: root.notifCount > 0
                text: root.notifCount.toString()
                color: Color.mPrimary
                pointSize: Style.fontSizeS
            }

            NText {
                visible: root.latestSummary !== ""
                text: root.latestSummary
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
                elide: Text.ElideRight
                Layout.maximumWidth: 200 * Style.uiScaleRatio
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: pluginApi.openPanel(root.screen)
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: BarService.openPluginSettings(root.screen, pluginApi.manifest)
    }
}
