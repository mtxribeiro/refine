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
    readonly property string dir: Quickshell.env("HOME") + "/Imagens/Wallpapers"

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

                Item {
                    id: carousel
                    anchors.fill: parent
                    anchors.margins: Theme.pad
                    clip: true
                    focus: true

                    readonly property int count: files.count
                    readonly property real step: Theme.cardWidth + Theme.gap
                    readonly property bool big: count > 4
                    readonly property int selected: count > 0 ? ((target % count) + count) % count : 0

                    property int target: 0
                    property real scrollPos: target

                    Behavior on scrollPos {
                        enabled: carousel.big

                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    function move(delta) {
                        if (count > 0)
                            target += delta
                    }

                    Component.onCompleted: forceActiveFocus()

                    Keys.onEscapePressed: root.open = false
                    Keys.onReturnPressed: {
                        if (count > 0)
                            root.apply(files.get(selected, "filePath"))
                    }
                    Keys.onPressed: event => {
                        switch (event.key) {
                        case Qt.Key_H:
                        case Qt.Key_Left:
                        case Qt.Key_Backtab:
                            move(-1)
                            event.accepted = true
                            break
                        case Qt.Key_L:
                        case Qt.Key_Right:
                        case Qt.Key_Tab:
                            move(1)
                            event.accepted = true
                            break
                        }
                    }

                    Repeater {
                        model: files

                        delegate: Item {
                            id: card
                            required property int index
                            required property url fileUrl
                            required property string filePath

                            readonly property bool isSelected: index === carousel.selected
                            readonly property real rel: {
                                if (!carousel.big)
                                    return index
                                const c = carousel.count
                                return ((((index - carousel.scrollPos + 1) % c) + c) % c) - 1
                            }

                            x: rel * carousel.step
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

                            Rectangle {
                                id: mask
                                anchors.fill: parent
                                radius: Theme.cardRadius
                                color: "black"
                                layer.enabled: true
                                visible: false
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
                                color: card.isSelected ? "transparent" : Theme.dim
                                border.width: card.isSelected ? 1 : 0
                                border.color: Theme.accent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.apply(card.filePath)
                            }
                        }
                    }
                }
            }
        }
    }
}
