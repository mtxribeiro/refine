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

                Item {
                    id: carousel
                    anchors.fill: parent
                    anchors.margins: Theme.pad
                    clip: true
                    focus: true

                    readonly property int count: files.count
                    // com 5+ wallpapers o carrossel gira; com menos, ficam parados
                    readonly property bool loops: count > 4
                    readonly property real step: Theme.cardWidth + Theme.gap

                    // target cresce/diminui sem limite; selected e o indice real
                    property int target: 0
                    property real scrollPos: target
                    readonly property int selected: count > 0 ? ((target % count) + count) % count : 0

                    Behavior on scrollPos {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    function next() {
                        if (count > 0) target += 1
                    }

                    function prev() {
                        if (count > 0) target -= 1
                    }

                    Component.onCompleted: forceActiveFocus()

                    Keys.onEscapePressed: root.open = false
                    Keys.onReturnPressed: {
                        if (count > 0) root.apply(files.get(selected, "filePath"))
                    }
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_H || event.key === Qt.Key_Backtab || event.key === Qt.Key_Left) {
                            prev()
                            event.accepted = true
                        } else if (event.key === Qt.Key_L || event.key === Qt.Key_Tab || event.key === Qt.Key_Right) {
                            next()
                            event.accepted = true
                        }
                    }

                    Repeater {
                        model: files

                        delegate: Item {
                            id: card
                            required property int index
                            required property url fileUrl
                            required property string filePath

                            readonly property bool isSelected: card.index === carousel.selected

                            // posicao relativa: de -1 (escondido a esquerda) ate count-2
                            readonly property real loopRel: carousel.count > 0
                                ? (((card.index - carousel.scrollPos + 1) % carousel.count + carousel.count) % carousel.count) - 1
                                : 0
                            readonly property real rel: carousel.loops ? loopRel : card.index
                            readonly property bool shown: rel > -1.5 && rel < 5

                            x: rel * carousel.step
                            width: Theme.cardWidth
                            height: Theme.cardHeight
                            visible: shown

                            Image {
                                id: img
                                anchors.fill: parent
                                source: card.shown ? card.fileUrl : ""
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
                                visible: !card.isSelected
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.cardRadius
                                color: "transparent"
                                border.width: 1
                                border.color: Theme.accent
                                visible: card.isSelected
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
