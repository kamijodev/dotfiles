import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null

    property int barIconSize: pluginApi?.pluginSettings?.barIconSize ?? 16
    property int overlayIconSize: pluginApi?.pluginSettings?.overlayIconSize ?? 40

    function saveSettings() {
        pluginApi.pluginSettings.barIconSize = barIconSize;
        pluginApi.pluginSettings.overlayIconSize = overlayIconSize;
        pluginApi.saveSettings();
    }

    spacing: Style.marginL

    // Bar icon size
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        RowLayout {
            spacing: Style.marginS

            NText {
                text: "バーのアイコンサイズ"
                color: Color.mOnSurface
                pointSize: Style.fontSizeS
                font.bold: true
            }

            NText {
                text: root.barIconSize + "px"
                color: Color.mPrimary
                pointSize: Style.fontSizeS
            }
        }

        Slider {
            Layout.fillWidth: true
            from: 12
            to: 32
            stepSize: 2
            value: root.barIconSize
            onMoved: root.barIconSize = Math.round(value)
        }
    }

    // Overlay icon size
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        RowLayout {
            spacing: Style.marginS

            NText {
                text: "オーバーレイのアイコンサイズ"
                color: Color.mOnSurface
                pointSize: Style.fontSizeS
                font.bold: true
            }

            NText {
                text: root.overlayIconSize + "px"
                color: Color.mPrimary
                pointSize: Style.fontSizeS
            }
        }

        Slider {
            Layout.fillWidth: true
            from: 24
            to: 64
            stepSize: 4
            value: root.overlayIconSize
            onMoved: root.overlayIconSize = Math.round(value)
        }
    }

    Item { Layout.fillHeight: true }
}
