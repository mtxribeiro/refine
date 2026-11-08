import Quickshell
import QtQuick
import "../../theme"
import "../../components"
import "../../services"

PanelWindow {
    id: root

    required property var modelData

    screen: modelData
    color: Theme.colors.surface
    implicitHeight: Theme.bar.height

    anchors {
        top: true
        left: true
        right: true
    }

    Workspaces {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        screen: root.screen
    }

    Clock {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        active: Panels.isOpen("calendar", root.screen)
        onClicked: Panels.toggle("calendar", clock, root.screen)
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.xs
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Tray {}

        BarButton {
            id: audio
            icon: Audio.icon
            dim: Audio.muted
            active: Panels.isOpen("audio", root.screen)
            onClicked: Panels.toggle("audio", audio, root.screen)
            onScrolled: delta => Audio.setVolume(Audio.volume + (delta > 0 ? 0.05 : -0.05))
        }

        BarButton {
            id: network
            icon: Network.kind === "ethernet"
                ? "network-wired-symbolic"
                : (Network.kind === "wifi" ? "network-wireless-symbolic" : "network-offline-symbolic")
            iconSize: 13
            dim: Network.kind === "none"
            active: Panels.isOpen("network", root.screen)
            onClicked: Panels.toggle("network", network, root.screen)
        }

        BarButton {
            id: power
            icon: Power.icon
            label: Power.hasBattery ? Power.percent + "%" : ""
            active: Panels.isOpen("power", root.screen)
            onClicked: Panels.toggle("power", power, root.screen)
        }
    }
}
