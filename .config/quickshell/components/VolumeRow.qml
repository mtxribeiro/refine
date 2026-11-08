import QtQuick
import "../theme"

Column {
    id: root

    property string title: ""
    property string icon: ""
    property real value: 0
    property bool muted: false

    signal moved(real value)
    signal muteToggled()

    spacing: Theme.spacing.xs

    Text {
        width: parent.width
        text: root.title
        color: Theme.colors.textSecondary
        elide: Text.ElideRight
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.sm

        IconButton {
            id: button
            icon: root.icon
            dim: root.muted
            onClicked: root.muteToggled()
        }

        ValueSlider {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - button.width - percent.width - parent.spacing * 2
            value: root.value
            dimmed: root.muted
            onMoved: v => root.moved(v)
        }

        Text {
            id: percent
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            horizontalAlignment: Text.AlignRight
            text: Math.round(root.value * 100) + "%"
            color: Theme.colors.textSecondary
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
        }
    }
}
