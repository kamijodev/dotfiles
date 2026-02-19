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

    property int refreshTick: 0

    Timer {
        running: true
        repeat: true
        interval: 60000
        onTriggered: root.refreshTick++
    }

    readonly property var todayEvents: pluginApi?.pluginSettings?.todayEvents ?? []
    readonly property bool authError: pluginApi?.pluginSettings?.authError ?? false

    readonly property var displayEvent: {
        void root.refreshTick;
        var now = new Date();
        var nowMin = now.getHours() * 60 + now.getMinutes();
        var currentEvent = null;
        var nextEvent = null;
        var nextDiff = Infinity;

        for (var i = 0; i < todayEvents.length; i++) {
            var ev = todayEvents[i];
            if (ev.title === "稼働") continue;
            var sp = ev.start.split(":");
            var startMin = parseInt(sp[0]) * 60 + parseInt(sp[1]);
            var ep = ev.end.split(":");
            var endMin = ep.length === 2 ? parseInt(ep[0]) * 60 + parseInt(ep[1]) : startMin + 60;

            if (nowMin >= startMin && nowMin < endMin) {
                currentEvent = ev;
            }
            if (startMin > nowMin && startMin - nowMin < nextDiff) {
                nextDiff = startMin - nowMin;
                nextEvent = ev;
            }
        }
        return currentEvent || nextEvent;
    }

    readonly property bool isCurrentlyInProgress: {
        void root.refreshTick;
        if (!displayEvent) return false;
        var now = new Date();
        var nowMin = now.getHours() * 60 + now.getMinutes();
        var sp = displayEvent.start.split(":");
        var startMin = parseInt(sp[0]) * 60 + parseInt(sp[1]);
        var ep = displayEvent.end.split(":");
        var endMin = ep.length === 2 ? parseInt(ep[0]) * 60 + parseInt(ep[1]) : startMin + 60;
        return nowMin >= startMin && nowMin < endMin;
    }

    readonly property string displayText: {
        if (!displayEvent) return "";
        if (isCurrentlyInProgress) {
            return displayEvent.title + " (〜" + displayEvent.end + ")";
        }
        return displayEvent.start + " " + displayEvent.title;
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
                icon: root.authError ? "alert-circle" : "calendar"
                color: root.authError ? Color.mError : (root.displayEvent ? Color.mPrimary : Color.mOnSurfaceVariant)
                Layout.preferredWidth: Style.fontSizeM
                Layout.preferredHeight: Style.fontSizeM
            }

            NText {
                visible: root.authError || root.displayText !== ""
                text: root.authError ? "認証切れ" : root.displayText
                color: root.authError ? Color.mError : (root.isCurrentlyInProgress ? Color.mPrimary : Color.mOnSurfaceVariant)
                pointSize: Style.fontSizeXS
                elide: Text.ElideRight
                Layout.maximumWidth: 250 * Style.uiScaleRatio
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
