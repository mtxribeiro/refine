import QtQuick
import "../../theme"
import "../../components"
import "../../services"

Item {
    id: root

    property string pending: ""

    function choose(network) {
        if (network.active) {
            Network.leave()
        } else if (!network.secure || Network.isSaved(network.ssid)) {
            Network.join(network.ssid, "")
        } else {
            pending = network.ssid
        }
    }

    function submit() {
        Network.join(pending, pass.text)
        pending = ""
    }

    function subtitleFor(network) {
        if (Network.connecting === network.ssid)
            return "Conectando…"
        if (Network.failed === network.ssid)
            return "Falha ao conectar"
        if (network.active)
            return "Conectado"
        return network.secure ? "Protegida" : "Aberta"
    }

    implicitWidth: 300
    implicitHeight: col.implicitHeight + Theme.spacing.md * 2

    onPendingChanged: {
        pass.text = ""
        if (pending !== "")
            pass.forceActiveFocus()
    }

    Component.onCompleted: Network.scan(true)

    Column {
        id: col
        x: Theme.spacing.md
        y: Theme.spacing.md
        width: parent.width - Theme.spacing.md * 2
        spacing: Theme.spacing.sm

        Item {
            width: parent.width
            height: 34

            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "Wi-Fi"
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal + 1
                    font.weight: Font.Medium
                }

                Text {
                    text: Network.kind === "ethernet"
                        ? "Cabo  ·  " + Network.connection
                        : (Network.kind === "wifi" ? Network.connection : "Desconectado")
                    color: Theme.colors.textSecondary
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                }
            }

            Toggle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: Network.wifiEnabled
                onToggled: Network.setWifi(!Network.wifiEnabled)
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.colors.border
        }

        Text {
            visible: !Network.wifiEnabled
            width: parent.width
            height: 44
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Wi-Fi desligado"
            color: Theme.colors.textSecondary
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
        }

        Text {
            visible: Network.wifiEnabled && Network.networks.length === 0
            width: parent.width
            height: 44
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Network.scanning ? "Buscando redes…" : "Nenhuma rede encontrada"
            color: Theme.colors.textSecondary
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
        }

        ListView {
            id: list
            visible: Network.wifiEnabled && count > 0
            width: parent.width
            height: visible ? Math.min(count, 6) * 38 : 0
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: Network.networks

            delegate: PanelButton {
                required property var modelData

                width: ListView.view.width
                icon: "network-wireless-symbolic"
                title: modelData.ssid
                subtitle: root.subtitleFor(modelData)
                trailing: modelData.active ? "object-select-symbolic" : (modelData.secure ? "channel-secure-symbolic" : "")
                highlighted: modelData.active
                onClicked: root.choose(modelData)
            }
        }

        Rectangle {
            visible: root.pending !== ""
            width: parent.width
            height: 34
            radius: Theme.radius.medium
            color: Theme.colors.background
            border.width: 1
            border.color: pass.activeFocus ? Theme.colors.borderStrong : Theme.colors.border

            TextInput {
                id: pass
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.md
                anchors.rightMargin: Theme.spacing.md
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: Theme.colors.text
                selectionColor: Theme.colors.accent
                selectedTextColor: Theme.colors.accentText
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                clip: true

                cursorDelegate: Rectangle {
                    width: 2
                    radius: 1
                    color: Theme.colors.accent
                }

                Keys.onReturnPressed: root.submit()
                Keys.onEnterPressed: root.submit()
                Keys.onEscapePressed: root.pending = ""

                Text {
                    anchors.fill: parent
                    visible: pass.text === ""
                    verticalAlignment: Text.AlignVCenter
                    text: "Senha de " + root.pending
                    color: Theme.colors.textDisabled
                    elide: Text.ElideRight
                    font: pass.font
                }
            }
        }
    }
}
