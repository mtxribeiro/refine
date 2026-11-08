import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import "../../theme"
import "../../components"
import "../../services"

PanelWindow {
    id: root

    required property var item

    property bool open: false
    property real anchorX: 0
    property var current: null
    property var stack: []
    property real progress: open ? 1 : 0

    signal dismissed()

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

    WlrLayershell.namespace: "quickshell-traymenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Behavior on progress {
        NumberAnimation {
            duration: root.open ? Theme.anim.normal : Theme.anim.instant
            easing.type: Theme.anim.easing
        }
    }

    onOpenChanged: {
        if (open) {
            stack = []
            current = item.menu
        }
    }

    Connections {
        target: Panels

        function onActiveChanged() {
            if (Panels.active !== "" && root.open)
                root.dismissed()
        }
    }

    Region {
        id: emptyMask
    }

    QsMenuOpener {
        id: opener
        menu: root.open ? root.current : null
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.dismissed()
    }

    Rectangle {
        id: card

        width: 220
        height: column.implicitHeight + Theme.spacing.sm * 2
        x: Math.max(8, Math.min(root.width - width - 8, root.anchorX - width / 2))
        y: Theme.spacing.sm - (1 - root.progress) * 8

        radius: Theme.radius.large
        color: Theme.colors.surface
        border.color: Theme.colors.border
        border.width: 1
        opacity: root.progress
        clip: true
        focus: true

        Keys.onEscapePressed: root.dismissed()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }

        Column {
            id: column
            x: Theme.spacing.sm
            y: Theme.spacing.sm
            width: card.width - Theme.spacing.sm * 2

            Item {
                visible: root.stack.length > 0
                width: column.width
                height: 30

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius.small
                    color: backArea.containsMouse ? Theme.colors.hover : "transparent"
                }

                Icon {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    name: "pan-start-symbolic"
                    size: 14
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.sm + 14 + Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Voltar"
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.current = root.stack[root.stack.length - 1]
                        root.stack = root.stack.slice(0, -1)
                    }
                }
            }

            Repeater {
                model: opener.children

                delegate: Item {
                    id: row

                    required property var modelData

                    readonly property bool hasIcon: modelData.icon !== ""
                    readonly property bool checked: modelData.buttonType !== QsMenuButtonType.None && modelData.checkState === Qt.Checked

                    width: column.width
                    height: modelData.isSeparator ? 9 : 30

                    Rectangle {
                        visible: row.modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacing.sm * 2
                        height: 1
                        color: Theme.colors.border
                    }

                    Rectangle {
                        visible: !row.modelData.isSeparator
                        anchors.fill: parent
                        radius: Theme.radius.small
                        color: area.containsMouse && row.modelData.enabled ? Theme.colors.hover : "transparent"
                    }

                    IconImage {
                        visible: row.hasIcon && !row.modelData.isSeparator
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 16
                        source: row.modelData.icon
                        opacity: row.modelData.enabled ? 1 : 0.5
                    }

                    Text {
                        visible: !row.modelData.isSeparator
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.sm + (row.hasIcon ? 16 + Theme.spacing.sm : 0)
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.sm + 14 + Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.text
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: row.modelData.enabled ? Theme.colors.text : Theme.colors.textDisabled
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                    }

                    Icon {
                        visible: !row.modelData.isSeparator && (row.modelData.hasChildren || row.checked)
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        name: row.modelData.hasChildren ? "pan-end-symbolic" : "object-select-symbolic"
                        size: 14
                        color: row.modelData.enabled ? Theme.colors.text : Theme.colors.textDisabled
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        enabled: !row.modelData.isSeparator
                        hoverEnabled: true
                        cursorShape: row.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            if (!row.modelData.enabled)
                                return

                            if (row.modelData.hasChildren) {
                                root.stack = root.stack.concat([root.current])
                                root.current = row.modelData
                            } else {
                                row.modelData.triggered()
                                root.dismissed()
                            }
                        }
                    }
                }
            }
        }
    }
}
