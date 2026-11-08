import QtQuick
import "../../theme"
import "../../components"
import "../../services"

Item {
    id: root

    readonly property var actions: [
        { id: "lock", icon: "system-lock-screen-symbolic", title: "Bloquear" },
        { id: "suspend", icon: "weather-clear-night-symbolic", title: "Suspender" },
        { id: "reboot", icon: "system-reboot-symbolic", title: "Reiniciar" },
        { id: "shutdown", icon: "system-shutdown-symbolic", title: "Desligar" },
        { id: "logout", icon: "system-log-out-symbolic", title: "Encerrar sessão" }
    ]

    implicitWidth: 260
    implicitHeight: col.implicitHeight + Theme.spacing.md * 2

    Column {
        id: col
        x: Theme.spacing.md
        y: Theme.spacing.md
        width: parent.width - Theme.spacing.md * 2
        spacing: Theme.spacing.sm

        Column {
            visible: Power.hasBattery
            width: parent.width
            spacing: Theme.spacing.xs

            Text {
                text: Power.percent + "%"
                color: Theme.colors.text
                font.family: Theme.font.family
                font.pixelSize: 24
                font.weight: Font.Medium
            }

            Text {
                text: Power.status
                color: Theme.colors.textSecondary
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
            }

            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: Theme.colors.surfaceHigh

                Rectangle {
                    width: parent.width * Power.percentage
                    height: parent.height
                    radius: parent.radius
                    color: Theme.colors.accent
                }
            }
        }

        Rectangle {
            visible: Power.hasBattery
            width: parent.width
            height: 1
            color: Theme.colors.border
        }

        Column {
            width: parent.width

            Repeater {
                model: root.actions

                delegate: PanelButton {
                    required property var modelData

                    width: col.width
                    icon: modelData.icon
                    title: modelData.title

                    onClicked: {
                        Panels.close()

                        if (modelData.id === "lock")
                            Session.lock()
                        else
                            Power[modelData.id]()
                    }
                }
            }
        }
    }
}
