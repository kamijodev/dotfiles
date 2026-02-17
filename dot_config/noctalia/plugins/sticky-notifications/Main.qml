import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.System
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property var rawNotifications: []
    property int lastHistoryCount: 0
    property real initTimestamp: 0

    readonly property int count: rawNotifications.length

    Component.onCompleted: {
        initTimestamp = Date.now();
        initSettings();
        Qt.callLater(function() {
            lastHistoryCount = NotificationService.historyList.count;
        });
    }

    function initSettings() {
        var defaults = pluginApi.manifest.metadata.defaultSettings;
        if (!pluginApi.pluginSettings.notifications)
            pluginApi.pluginSettings.notifications = defaults.notifications;
        if (pluginApi.pluginSettings.count === undefined)
            pluginApi.pluginSettings.count = defaults.count;
        if (!pluginApi.pluginSettings.filterMode)
            pluginApi.pluginSettings.filterMode = defaults.filterMode;
        if (!pluginApi.pluginSettings.filteredApps)
            pluginApi.pluginSettings.filteredApps = defaults.filteredApps;
        if (!pluginApi.pluginSettings.maxNotifications)
            pluginApi.pluginSettings.maxNotifications = defaults.maxNotifications;

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

    function captureNotification(data) {
        var notifTime = data.timestamp instanceof Date
            ? data.timestamp.getTime()
            : Number(data.timestamp);

        if (notifTime < initTimestamp - 1000) return;

        if (!shouldCapture(data.appName)) return;

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
    }

    function shouldCapture(appName) {
        var mode = pluginApi.pluginSettings.filterMode || "all";
        if (mode === "all") return true;
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
        saveNotifications();
    }

    function dismissAll() {
        rawNotifications = [];
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

    IpcHandler {
        target: "plugin:sticky-notifications"

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

        function getCount(): string {
            return JSON.stringify({ count: root.count });
        }

        function getNotifications(): string {
            return JSON.stringify(root.rawNotifications);
        }
    }
}
