import QtQuick
import "../theme"

Item {
    id: root

    property string icon: ""
    property bool dim: false
    property int size: 32

    signal clicked()

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.full
        color: area.pressed ? Theme.colors.pressed : (area.containsMouse ? Theme.colors.hover : "transparent")
    }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        color: root.dim ? Theme.colors.textDisabled : Theme.colors.text
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
