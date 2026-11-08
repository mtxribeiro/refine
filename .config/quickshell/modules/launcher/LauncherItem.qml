import Quickshell
import QtQuick
import "../../theme"

Item {
    id: root

    required property var entry

    signal clicked()
    signal hovered()

    Image {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        sourceSize: Qt.size(64, 64)
        asynchronous: true
        source: Quickshell.iconPath(root.entry.icon, "application-x-executable")
    }

    Column {
        anchors.left: icon.right
        anchors.leftMargin: Theme.spacing.md
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            text: root.entry.name
            color: Theme.colors.text
            elide: Text.ElideRight
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal + 1
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.entry.genericName || root.entry.comment || ""
            color: Theme.colors.textSecondary
            elide: Text.ElideRight
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onPositionChanged: root.hovered()
    }
}
