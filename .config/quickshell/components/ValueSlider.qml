import QtQuick
import "../theme"

Item {
    id: root

    property real value: 0
    property bool dimmed: false

    readonly property real ratio: Math.max(0, Math.min(1, value))

    signal moved(real value)

    implicitWidth: 200
    implicitHeight: 28

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.colors.surfaceHigh

        Rectangle {
            width: handle.x + handle.width / 2
            height: parent.height
            radius: parent.radius
            color: root.dimmed ? Theme.colors.textDisabled : Theme.colors.accent
        }
    }

    Rectangle {
        id: handle
        anchors.verticalCenter: parent.verticalCenter
        x: (root.width - width) * root.ratio
        width: 16
        height: 16
        radius: 8
        color: root.dimmed ? Theme.colors.textDisabled : Theme.colors.accent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function apply(mouseX) {
            root.moved(Math.max(0, Math.min(1, (mouseX - handle.width / 2) / (root.width - handle.width))))
        }

        onPressed: mouse => apply(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                apply(mouse.x)
        }
        onWheel: wheel => root.moved(root.ratio + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
    }
}
