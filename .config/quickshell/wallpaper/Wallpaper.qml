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
                    readonly property real step: Theme.cardWidth + Theme.gap
                    // 5+ wallpapers: sobra um escondido a esquerda e a volta e invisivel
                    // ate 4: todos cabem na tela, a volta usa fade
                    readonly property bool big: count > 4

                    // target cresce/diminui sem limite; scrollPos anima ate ele
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

                            // posicao relativa ao selecionado (0 = primeira posicao visivel)
                            readonly property real rel: {
                                const c = carousel.count
                                if (c < 2)
                                    return 0
                                const d = card.index - carousel.scrollPos
                                if (carousel.big)
                                    return (((d + 1) % c) + c) % c - 1   // de -1 a c-1
                                return ((d % c) + c) % c                  // de 0 a c
                            }

                            // ate 4 wallpapers: fade na entrada pela direita
                            opacity: carousel.big ? 1 : Math.max(0, Math.min(1, carousel.count - rel))
                            visible: opacity > 0 && rel > -1.5 && rel < 5

                            x: rel * carousel.step
                            width: Theme.cardWidth
                            height: Theme.cardHeight

                            Image {
                                id: img
                                anchors.fill: parent
                                source: card.visible ? card.fileUrl : ""
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
