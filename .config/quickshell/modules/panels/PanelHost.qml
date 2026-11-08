import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../theme"
import "../../services"

PanelWindow {
    id: root

    required property var modelData

    readonly property bool open: Panels.active !== "" && Panels.screenName === modelData.name
    readonly property bool shown: open || progress > 0
    readonly property var files: ({
        calendar: "CalendarPanel.qml",
        audio: "AudioPanel.qml",
        network: "NetworkPanel.qml",
        power: "PowerPanel.qml"
    })

    property string shownName: ""
    property real progress: open ? 1 : 0

    screen: modelData
    visible: true
    mask: open ? null : emptyMask
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    margins.top: Theme.bar.height

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.namespace: "quickshell-panels"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Behavior on progress {
        NumberAnimation {
            duration: root.open ? Theme.anim.normal : Theme.anim.instant
            easing.type: Theme.anim.easing
        }
    }

    onOpenChanged: {
        if (open)
            shownName = Panels.active
    }

    Connections {
        target: Panels

        function onActiveChanged() {
            if (root.open)
                root.shownName = Panels.active
        }
    }

    Region {
        id: emptyMask
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Panels.close()
    }

    Rectangle {
        id: card

        width: loader.item ? loader.item.implicitWidth : 0
        height: loader.item ? loader.item.implicitHeight : 0
        x: Math.max(8, Math.min(root.width - width - 8, Panels.anchorX - width / 2))
        y: Theme.spacing.sm - (1 - root.progress) * 8

        radius: Theme.radius.large
        color: Theme.colors.surface
        border.color: Theme.colors.border
        border.width: 1
        opacity: root.progress
        clip: true
        focus: true

        Keys.onEscapePressed: Panels.close()

        Behavior on x {
            enabled: root.progress === 1

            NumberAnimation {
                duration: Theme.anim.instant
                easing.type: Theme.anim.easing
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Loader {
            id: loader
            anchors.fill: parent
            active: root.shown
            source: root.files[root.shownName] ?? ""
        }
    }
}
