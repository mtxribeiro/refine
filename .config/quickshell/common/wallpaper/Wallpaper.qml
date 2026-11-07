import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import "../common"

Scope {
    id: root

    property bool open: false
    property string dir: Quickshell.env("HOME") + "/Imagens/Wallpapers"

    function apply(path) {
        setter.command = [Quickshell.env("HOME") + "/.config/niri/scripts/wallpaper.sh", path]
        setter.running = true
        open = false
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            root.open = !root.open
        }
    }

    Process {
        id: setter
    }

    FolderListModel {
        id: files
        folder: "file://" + root.dir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        caseSensitive: false
        showDirs: false
    }

    LazyLoader {
        active: root.open

        PanelWindow {
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "wallpaper"

            MouseArea {
                anchors.fill: parent
                onClicked: root.open = false
            }

            Rectangle {
                y: 100
                anchors.horizontalCenter: parent.horizontalCenter
                width: 4 * Theme.cardWidth + 3 * Theme.gap + 2 * Theme.pad
                height: Theme.cardHeight + 2 * Theme.pad
                color: Theme.bg
                radius: Theme.radius
                border.width: 1
                border.color: Theme.outline

                MouseArea {
                    anchors.fill: parent
                }

                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.margins: Theme.pad
                    orientation: ListView.Horizontal
                    spacing: Theme.gap
                    clip: true
                    model: files
                    focus: true
                    keyNavigationEnabled: true
                    keyNavigationWraps: true
                    highlightMoveDuration: 0

                    Component.onCompleted: forceActiveFocus()

                    Keys.onEscapePressed: root.open = false
                    Keys.onReturnPressed: root.apply(files.get(currentIndex, "filePath"))
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_H || event.key === Qt.Key_Backtab) {
                            decrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_L || event.key === Qt.Key_Tab) {
                            incrementCurrentIndex()
                            event.accepted = true
                        }
                    }

                    delegate: Item {
                        id: card
                        required property int index
                        required property url fileUrl
                        required property string filePath
                        readonly property bool selected: ListView.isCurrentItem

                        width: Theme.cardWidth
                        height: Theme.cardHeight

                        Image {
                            id: img
                            anchors.fill: parent
                            source: card.fileUrl
                            sourceSize.width: Theme.cardWidth * 2
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }

                        Item {
                            id: mask
                            anchors.fill: parent
                            layer.enabled: true
                            visible: false

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.cardRadius
                                color: "black"
                            }
                        }

                        MultiEffect {
                            anchors.fill: parent
                            source: img
                            maskEnabled: true
                            maskSource: mask
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.cardRadius
                            color: Theme.dim
                            visible: !card.selected
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.cardRadius
                            color: "transparent"
                            border.width: 2
                            border.color: Theme.accent
                            visible: card.selected
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = card.index
                            onClicked: root.apply(card.filePath)
                        }
                    }
                }
            }
        }
    }
}
