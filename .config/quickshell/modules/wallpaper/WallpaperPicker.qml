import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../../theme"
import "../../components"

PanelWindow {
    id: root

    property bool shown: false
    property real progress: shown ? 1 : 0

    readonly property string script: Quickshell.env("HOME") + "/.config/niri/scripts/wallpaper.sh"
    readonly property string folder: Quickshell.env("HOME") + "/Imagens/Wallpapers"
    readonly property string pickFolder: Quickshell.env("HOME") + "/Imagens"
    readonly property string cache: Quickshell.env("HOME") + "/.cache/current-wallpaper"

    readonly property int columns: 3
    readonly property int cellWidth: Math.floor(grid.width / columns)
    readonly property int cellHeight: Math.round((cellWidth - Theme.spacing.sm * 2) * 9 / 16) + Theme.spacing.sm * 2

    property var files: []
    property string current: ""
    property bool loaded: false
    property bool gPending: false

    readonly property int total: files.length
    readonly property var focused: total > 0 && grid.currentIndex >= 0 && grid.currentIndex < total
        ? files[grid.currentIndex]
        : null

    function apply(entry) {
        if (!entry || applyProc.running)
            return
        applyProc.command = ["bash", root.script, entry.path]
        applyProc.running = true
        current = entry.path
    }

    function pick() {
        if (pickProc.running || addProc.running)
            return
        gPending = false
        shown = false
        pickProc.running = true
    }

    function focusCurrent() {
        const i = files.findIndex(f => f.path === current)
        grid.currentIndex = i >= 0 ? i : 0
        grid.positionViewAtIndex(grid.currentIndex, GridView.Contain)
        loaded = true
    }

    function handleKey(e) {
        const k = e.key
        const t = e.text
        e.accepted = true

        if (k === Qt.Key_Escape || t === "q") {
            shown = false
            return
        }
        if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) {
            apply(focused)
            return
        }
        if (k === Qt.Key_Right || k === Qt.Key_Tab || t === "l") {
            gPending = false
            grid.moveCurrentIndexRight()
            return
        }
        if (k === Qt.Key_Left || k === Qt.Key_Backtab || t === "h") {
            gPending = false
            grid.moveCurrentIndexLeft()
            return
        }
        if (k === Qt.Key_Down || t === "j") {
            gPending = false
            grid.moveCurrentIndexDown()
            return
        }
        if (k === Qt.Key_Up || t === "k") {
            gPending = false
            grid.moveCurrentIndexUp()
            return
        }
        if (k === Qt.Key_Home) {
            gPending = false
            grid.currentIndex = 0
            return
        }
        if (k === Qt.Key_End || t === "G") {
            gPending = false
            grid.currentIndex = Math.max(0, total - 1)
            return
        }
        if (t === "g") {
            if (gPending)
                grid.currentIndex = 0
            gPending = !gPending
            return
        }
        if (t === "o") {
            pick()
            return
        }

        e.accepted = false
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: shown || progress > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "quickshell-wallpapers"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Behavior on progress {
        NumberAnimation {
            duration: root.shown ? Theme.anim.normal : Theme.anim.instant
            easing.type: Theme.anim.easing
        }
    }

    onShownChanged: {
        if (shown) {
            loaded = false
            gPending = false
            listProc.running = true
            grid.forceActiveFocus()
        }
    }

    Process {
        id: listProc
        command: [
            "sh", "-c",
            "head -n1 \"$2\" 2>/dev/null; echo; echo ---; find \"$1\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort",
            "sh", root.folder, root.cache
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n")
                const sep = lines.indexOf("---")
                root.current = lines.slice(0, Math.max(sep, 0)).join("").trim()
                root.files = lines.slice(sep + 1)
                    .filter(l => l.trim() !== "")
                    .map(p => ({ path: p }))
                Qt.callLater(root.focusCurrent)
            }
        }
    }

    Process {
        id: applyProc
    }

    Process {
        id: pickProc
        command: [
            "sh", "-c",
            "dir=\"$1\"; if command -v zenity >/dev/null 2>&1; then zenity --file-selection --title=\"Adicionar wallpaper\" --filename=\"$dir/\" --file-filter=\"Imagens | *.jpg *.jpeg *.png *.webp *.JPG *.JPEG *.PNG *.WEBP\"; elif command -v kdialog >/dev/null 2>&1; then kdialog --getopenfilename \"$dir\" \"*.jpg *.jpeg *.png *.webp|Imagens\"; fi",
            "sh", root.pickFolder
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.split("\n")[0].trim()
                if (path !== "") {
                    addProc.command = [
                        "sh", "-c",
                        "dir=\"$1\"; src=\"$2\"; mkdir -p \"$dir\"; dest=\"$dir/$(basename \"$src\")\"; [ \"$src\" -ef \"$dest\" ] || cp -n \"$src\" \"$dest\"; bash \"$3\" \"$dest\"",
                        "sh", root.folder, path, root.script
                    ]
                    addProc.running = true
                } else {
                    root.shown = true
                }
            }
        }
    }

    Process {
        id: addProc

        onExited: root.shown = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.shown = false
    }

    Rectangle {
        id: card

        width: Math.min(720, root.width - 48)
        height: Math.min(540, root.height - 96)
        x: (root.width - width) / 2
        y: (root.height - height) / 2 + (1 - root.progress) * 8
        scale: 0.97 + 0.03 * root.progress
        opacity: root.progress

        radius: Theme.radius.large
        color: Theme.colors.surface
        border.color: Theme.colors.border
        border.width: 1
        clip: true

        MouseArea {
            anchors.fill: parent
        }

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.xl
                anchors.verticalCenter: parent.verticalCenter
                text: "Plano de fundo"
                color: Theme.colors.text
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                font.weight: Font.Medium
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.lg
                anchors.verticalCenter: parent.verticalCenter
                width: addRow.implicitWidth + Theme.spacing.lg * 2
                height: 32
                radius: Theme.radius.full
                color: Theme.colors.accent
                opacity: addArea.pressed ? 0.7 : (addArea.containsMouse ? 0.85 : 1)

                Behavior on opacity {
                    NumberAnimation { duration: Theme.anim.fast }
                }

                Row {
                    id: addRow
                    anchors.centerIn: parent
                    spacing: Theme.spacing.sm

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "list-add-symbolic"
                        size: 14
                        color: Theme.colors.accentText
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Adicionar"
                        color: Theme.colors.accentText
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: Font.Medium
                    }
                }

                MouseArea {
                    id: addArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pick()
                }
            }
        }

        Rectangle {
            id: divider
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.spacing.md
            anchors.rightMargin: Theme.spacing.md
            height: 1
            color: Theme.colors.border
        }

        Item {
            anchors.top: divider.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            GridView {
                id: grid
                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                clip: true
                cellWidth: root.cellWidth
                cellHeight: root.cellHeight
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationEnabled: false
                cacheBuffer: root.cellHeight * 2
                opacity: root.loaded ? 1 : 0

                Keys.onPressed: event => root.handleKey(event)

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.slow
                        easing.type: Theme.anim.easing
                    }
                }

                model: ScriptModel {
                    values: root.files
                }

                delegate: WallpaperItem {
                    required property var modelData
                    required property int index

                    width: grid.cellWidth
                    height: grid.cellHeight
                    entry: modelData
                    applied: modelData.path === root.current
                    focused: GridView.isCurrentItem

                    onClicked: {
                        grid.currentIndex = index
                        root.apply(modelData)
                    }

                    onHovered: grid.currentIndex = index
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.loaded && root.total === 0
                text: "Nenhum wallpaper encontrado. Use o botão Adicionar."
                color: Theme.colors.textSecondary
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
            }
        }
    }
}
