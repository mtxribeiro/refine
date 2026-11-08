import QtQuick
import "../theme"

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string trailing: ""
    property bool highlighted: false

    signal clicked()

    implicitWidth: 250
    implicitHeight: 38

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.medium
        color: root.highlighted ? Theme.colors.pressed : (area.containsMouse ? Theme.colors.hover : "transparent")
    }

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        name: root.icon
        color: Theme.colors.textSecondary
    }

    Column {
        anchors.left: glyph.right
        anchors.leftMargin: Theme.spacing.md
        anchors.right: end.left
        anchors.rightMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            text: root.title
            color: Theme.colors.text
            elide: Text.ElideRight
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.subtitle
            color: Theme.colors.textSecondary
            elide: Text.ElideRight
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }
    }

    Icon {
        id: end
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        name: root.trailing
        color: Theme.colors.textSecondary
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
