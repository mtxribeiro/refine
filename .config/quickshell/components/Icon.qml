import Quickshell
import QtQuick
import QtQuick.Effects
import "../theme"

Item {
    id: root

    property string name: ""
    property color color: Theme.colors.text
    property int size: 16

    implicitWidth: size
    implicitHeight: size

    Image {
        id: image
        anchors.fill: parent
        visible: false
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        source: root.name !== "" ? Quickshell.iconPath(root.name, true) : ""
    }

    MultiEffect {
        anchors.fill: parent
        source: image
        visible: image.status === Image.Ready
        brightness: 1
        colorization: 1
        colorizationColor: root.color
    }
}
