import QtQuick
import "../theme"

Item {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false
    property bool dim: false
    property int iconSize: 14

    property color tint: dim
        ? Theme.colors.textDisabled
        : (area.containsMouse ? Theme.colors.textSecondary : Theme.colors.text)

    signal clicked()
    signal scrolled(real delta)

    implicitWidth: row.implicitWidth + (label !== "" ? Theme.spacing.md : Theme.spacing.sm - 2) * 2
    implicitHeight: 28

    Behavior on tint {
        ColorAnimation { duration: Theme.anim.fast }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing.sm

        Icon {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: root.iconSize
            color: root.tint
        }

        Text {
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.tint
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }
}
