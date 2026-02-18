import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Services.System
import qs.Services.UI
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property var rawNotifications: []
    property int lastHistoryCount: 0
    property real initTimestamp: 0
    property int refreshTick: 0

    // Urgent notification for fullscreen alert
    property var urgentNotification: null
    // Suppressed event titles (no more fullscreen alerts for these)
    property var suppressedEvents: []

    // Today's calendar events
    property var todayEvents: []

    readonly property int count: rawNotifications.length

    Timer {
        running: true
        repeat: true
        interval: 60000
        onTriggered: {
            root.refreshTick++;
            todayFile.reload();
        }
    }

    Component.onCompleted: {
        initTimestamp = Date.now();
        initSettings();
        Qt.callLater(function() {
            lastHistoryCount = NotificationService.historyList.count;
        });
    }

    function loadTodayEvents() {
        var content = todayFile.text();
        if (content) {
            try {
                root.todayEvents = JSON.parse(content);
                pluginApi.pluginSettings.todayEvents = root.todayEvents;
                pluginApi.saveSettings();
            } catch (e) {}
        }
    }

    FileView {
        id: todayFile
        path: "/tmp/gcal-today-events.json"
        watchChanges: true
        preload: true
        onFileChanged: todayFile.reload()
        onLoaded: root.loadTodayEvents()
    }

    function initSettings() {
        var defaults = pluginApi.manifest.metadata.defaultSettings;
        var currentVersion = pluginApi.pluginSettings.settingsVersion || 0;
        var targetVersion = 1;

        if (currentVersion < targetVersion) {
            pluginApi.pluginSettings.notifications = [];
            pluginApi.pluginSettings.count = 0;
            pluginApi.pluginSettings.filterMode = defaults.filterMode;
            pluginApi.pluginSettings.filteredApps = defaults.filteredApps;
            pluginApi.pluginSettings.maxNotifications = defaults.maxNotifications;
            pluginApi.pluginSettings.settingsVersion = targetVersion;
        }

        pluginApi.saveSettings();
        rawNotifications = (pluginApi.pluginSettings.notifications || []).slice();
    }

    Connections {
        target: NotificationService.historyList

        function onCountChanged() {
            var currentCount = NotificationService.historyList.count;
            if (currentCount > root.lastHistoryCount && root.initTimestamp > 0) {
                var newCount = currentCount - root.lastHistoryCount;
                for (var i = 0; i < newCount; i++) {
                    root.captureNotification(NotificationService.historyList.get(i));
                }
            }
            root.lastHistoryCount = currentCount;
        }
    }

    function isUrgent(summary) {
        var text = summary.toLowerCase();
        if (text.indexOf("now") !== -1) return true;
        if (text.indexOf("@1m") !== -1) return true;
        if (text.indexOf("@3m") !== -1) return true;
        if (text.indexOf("@5m") !== -1) return true;
        return false;
    }

    function captureNotification(data) {
        var notifTime = data.timestamp instanceof Date
            ? data.timestamp.getTime()
            : Number(data.timestamp);

        if (notifTime < initTimestamp - 1000) return;

        if (!shouldCapture(data)) return;

        for (var i = 0; i < rawNotifications.length; i++) {
            if (rawNotifications[i].id === data.id) return;
        }

        var entry = {
            id: data.id || generateId(),
            summary: data.summary || "",
            body: data.body || "",
            appName: data.appName || "",
            urgency: data.urgency || 1,
            timestamp: notifTime,
            image: data.cachedImage || data.originalImage || ""
        };

        rawNotifications.unshift(entry);

        var max = pluginApi.pluginSettings.maxNotifications || 200;
        if (rawNotifications.length > max) {
            rawNotifications = rawNotifications.slice(0, max);
        }

        saveNotifications();

        if (isUrgent(entry.summary)) {
            var title = extractTitle(entry.summary);
            var suppressed = false;
            for (var j = 0; j < suppressedEvents.length; j++) {
                if (suppressedEvents[j] === title) {
                    suppressed = true;
                    break;
                }
            }
            if (!suppressed) {
                urgentNotification = entry;
            }
        }
    }

    function snoozeUrgent() {
        urgentNotification = null;
    }

    function dismissUrgent() {
        if (urgentNotification) {
            var title = extractTitle(urgentNotification.summary);
            var list = suppressedEvents.slice();
            list.push(title);
            suppressedEvents = list;
            dismissNotification(urgentNotification.id);
            urgentNotification = null;
        }
    }

    function shouldCapture(data) {
        var mode = pluginApi.pluginSettings.filterMode || "all";
        if (mode === "all") return true;

        var appName = data.appName || "";
        var apps = pluginApi.pluginSettings.filteredApps || [];
        for (var i = 0; i < apps.length; i++) {
            if (appName.toLowerCase().indexOf(apps[i].toLowerCase()) !== -1)
                return true;
        }
        return false;
    }

    function dismissNotification(notifId) {
        rawNotifications = rawNotifications.filter(function(n) {
            return n.id !== notifId;
        });
        if (urgentNotification && urgentNotification.id === notifId) {
            urgentNotification = null;
        }
        saveNotifications();
    }

    function dismissAll() {
        rawNotifications = [];
        urgentNotification = null;
        saveNotifications();
    }

    function saveNotifications() {
        pluginApi.pluginSettings.notifications = rawNotifications.slice();
        pluginApi.pluginSettings.count = rawNotifications.length;
        pluginApi.saveSettings();
    }

    function generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    }

    function timeAgo(timestamp) {
        void root.refreshTick;
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

    function getStartTime(summary) {
        var match = summary.match(/~(\d+:\d{2})/);
        if (match) {
            return match[1] + " 開始";
        }
        return "";
    }

    function extractTitle(summary) {
        return summary.replace(/\s*@\d+m\s*|\s*now\s*|\s*~\d+:\d{2}\s*/gi, "").trim();
    }

    // Fullscreen urgent alert
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: urgentOverlay

            required property ShellScreen modelData
            screen: modelData

            WlrLayershell.namespace: "gcal-urgent-" + (screen?.name || "unknown")
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            visible: root.urgentNotification !== null

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.75)

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.snoozeUrgent()
                }

                Rectangle {
                    id: urgentCard
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.6, 600)
                    height: urgentContent.implicitHeight + Style.marginXL * 4
                    radius: Style.radiusL
                    color: Color.mSurface
                    border.color: Color.mError
                    border.width: Style.borderL

                    ColumnLayout {
                        id: urgentContent
                        anchors.centerIn: parent
                        width: parent.width - Style.marginXL * 2
                        spacing: Style.marginL

                        // Time label
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: timeLabelRow.implicitWidth + Style.marginXL * 2
                            Layout.preferredHeight: timeLabelRow.implicitHeight + Style.marginL * 2
                            Layout.minimumWidth: 160
                            Layout.minimumHeight: 50
                            radius: Style.radiusM
                            color: Color.mError

                            RowLayout {
                                id: timeLabelRow
                                anchors.centerIn: parent

                                Text {
                                    text: root.urgentNotification
                                        ? root.getStartTime(root.urgentNotification.summary)
                                        : ""
                                    font.pointSize: Style.fontSizeXXL
                                    font.weight: Font.Bold
                                    color: Color.mOnError
                                }
                            }
                        }

                        // Event title
                        NText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: root.urgentNotification
                                ? root.extractTitle(root.urgentNotification.summary)
                                : ""
                            pointSize: Style.fontSizeXXXL
                            font.weight: Font.Bold
                            color: Color.mOnSurface
                            wrapMode: Text.WordWrap
                        }

                        // Buttons
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Style.marginL

                            // Snooze button
                            Rectangle {
                                width: snoozeRow.implicitWidth + Style.marginL * 2
                                height: snoozeRow.implicitHeight + Style.marginM * 2
                                radius: Style.iRadiusM
                                color: snoozeMouse.containsMouse
                                    ? Color.mPrimaryContainer : Color.mSurfaceVariant

                                RowLayout {
                                    id: snoozeRow
                                    anchors.centerIn: parent
                                    spacing: Style.marginS

                                    NIcon {
                                        icon: "close"
                                        pointSize: Style.fontSizeM
                                        color: Color.mOnSurface
                                    }

                                    NText {
                                        text: "閉じる"
                                        pointSize: Style.fontSizeM
                                        color: Color.mOnSurface
                                    }
                                }

                                MouseArea {
                                    id: snoozeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.snoozeUrgent()
                                }
                            }

                            // Dismiss button
                            Rectangle {
                                width: dismissRow.implicitWidth + Style.marginL * 2
                                height: dismissRow.implicitHeight + Style.marginM * 2
                                radius: Style.iRadiusM
                                color: dismissBtnMouse.containsMouse
                                    ? Color.mPrimaryContainer : Color.mSurfaceVariant

                                RowLayout {
                                    id: dismissRow
                                    anchors.centerIn: parent
                                    spacing: Style.marginS

                                    NIcon {
                                        icon: "eye-off"
                                        pointSize: Style.fontSizeM
                                        color: Color.mOnSurface
                                    }

                                    NText {
                                        text: "以降非表示"
                                        pointSize: Style.fontSizeM
                                        color: Color.mOnSurface
                                    }
                                }

                                MouseArea {
                                    id: dismissBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.dismissUrgent()
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    IpcHandler {
        target: "plugin:gcal-reminder"

        function togglePanel() {
            pluginApi.withCurrentScreen(function(screen) {
                pluginApi.togglePanel(screen);
            });
        }

        function dismiss(id: string) {
            root.dismissNotification(id);
        }

        function dismissAll() {
            root.dismissAll();
        }

        function snoozeUrgent() {
            root.snoozeUrgent();
        }

        function dismissUrgent() {
            root.dismissUrgent();
        }

        function getCount(): string {
            return JSON.stringify({ count: root.count });
        }

        function getNotifications(): string {
            return JSON.stringify(root.rawNotifications);
        }
    }
}
