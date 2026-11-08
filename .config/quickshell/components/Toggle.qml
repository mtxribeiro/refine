import QtQuick
import "../theme"

Item {
    id: root

    property bool checked: false

    signal toggled()

    implicitWidth: 40
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.colors.accent : Theme.colors.surfaceHigh

        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.instant
            }
        }
    }

    Rectangle {
        y: 3
        x: root.checked ? root.width - width - 3 : 3
        width: 16
        height: 16
        radius: 8
        color: root.checked ? Theme.colors.accentText : Theme.colors.textSecondary

        Behavior on x {
            NumberAnimation {
                duration: Theme.anim.instant
                easing.type: Theme.anim.easing
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
