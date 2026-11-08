import QtQuick
import "../theme"

Rectangle {
    id: root

    default property alias content: holder.data
    property int padding: Theme.spacing.sm

    implicitWidth: holder.childrenRect.width + padding * 2
    implicitHeight: Theme.bar.height
    radius: Theme.radius.large
    color: Theme.colors.surface
    border.color: Theme.colors.border
    border.width: 1

    Item {
        id: holder
        x: root.padding
        width: root.width - root.padding * 2
        height: root.height
    }
}
