import Quickshell
import QtQuick
import "../../theme"
import "../../services"

Item {
    id: root

    required property var screen

    readonly property var list: Niri.forOutput(screen.name)

    implicitWidth: row.implicitWidth
    implicitHeight: 28

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => wheel.angleDelta.y > 0 ? Niri.focusUp() : Niri.focusDown()
    }

    Row {
        id: row

        Repeater {
            model: root.list.length

            delegate: Item {
                id: cell

                required property int index

                readonly property var ws: root.list[index] ?? ({})
                readonly property bool active: ws.is_active === true
                readonly property bool occupied: ws.active_window_id !== null && ws.active_window_id !== undefined

                width: dot.width + 6
                height: 28

                Rectangle {
                    id: dot
                    anchors.centerIn: parent
                    width: cell.active ? 20 : 8
                    height: 8
                    radius: 4
                    color: cell.active ? Theme.colors.accent : (cell.occupied ? Theme.colors.textSecondary : Theme.colors.borderStrong)

                    Behavior on width {
                        NumberAnimation {
                            duration: 110
                            easing.type: Theme.anim.easing
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 110
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Niri.focus(cell.ws.idx)
                }
            }
        }
    }
}
