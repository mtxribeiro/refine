import QtQuick
import QtQuick.Effects
import "../../theme"
import "../../components"

Item {
    id: root

    required property var entry
    property bool applied: false
    property bool focused: false

    signal clicked()
    signal hovered()

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.medium + Theme.spacing.sm
        color: root.focused ? Theme.colors.hover : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.anim.fast }
        }
    }

    Item {
        id: thumb
        anchors.fill: parent
        anchors.margins: Theme.spacing.sm

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius.medium
            color: Theme.colors.surfaceVariant
        }

        Rectangle {
            id: mask
            anchors.fill: parent
            radius: Theme.radius.medium
            visible: false
            layer.enabled: true
        }

        Image {
            id: img
            anchors.fill: parent
            source: "file://" + root.entry.path
            sourceSize: Qt.size(432, 243)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: img
            maskEnabled: true
            maskSource: mask
            opacity: img.status === Image.Ready ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.slow
                    easing.type: Theme.anim.easing
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: Theme.radius.medium + 3
            color: "transparent"
            border.width: 2
            border.color: Theme.colors.accent
            opacity: root.applied ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.normal
                    easing.type: Theme.anim.easing
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: Theme.spacing.sm
            anchors.bottomMargin: Theme.spacing.sm
            width: 22
            height: 22
            radius: width / 2
            color: Theme.colors.accent
            opacity: root.applied ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.normal
                    easing.type: Theme.anim.easing
                }
            }

            Icon {
                anchors.centerIn: parent
                name: "object-select-symbolic"
                size: 12
                color: Theme.colors.accentText
            }
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
