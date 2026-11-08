import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../theme"

PanelWindow {
    id: root

    property bool shown: false
    property real progress: shown ? 1 : 0

    readonly property int rowHeight: 48
    readonly property int maxRows: 6
    readonly property int emptyRows: 4
    readonly property int searchHeight: 48

    readonly property string term: input.text.trim().toLowerCase()
    readonly property bool searching: term !== ""

    readonly property var results: {
        const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay)

        if (!searching)
            return apps.sort((a, b) => a.name.localeCompare(b.name))

        const found = []
        for (const app of apps) {
            const s = score(app, term)
            if (s > 0)
                found.push({ app, s })
        }

        found.sort((a, b) => (b.s - a.s) || a.app.name.localeCompare(b.app.name))
        return found.map(x => x.app)
    }

    readonly property int visibleRows: Math.min(results.length, searching ? maxRows : emptyRows)

    function score(app, q) {
        const name = app.name.toLowerCase()
        if (name.startsWith(q))
            return 3
        if (name.includes(q))
            return 2
        const extra = ((app.genericName || "") + " " + (app.comment || "") + " " + (app.keywords || []).join(" ")).toLowerCase()
        return extra.includes(q) ? 1 : 0
    }

    function launch(entry) {
        if (!entry)
            return
        entry.execute()
        shown = false
    }

    function resetSelection() {
        list.currentIndex = 0
        list.positionViewAtBeginning()
    }

    onResultsChanged: Qt.callLater(resetSelection)

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: shown || progress > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "quickshell-launcher"
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
            input.text = ""
            resetSelection()
            input.forceActiveFocus()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.shown = false
    }

    Rectangle {
        id: card

        width: Math.min(520, root.width - 48)
        height: column.implicitHeight
        x: (root.width - width) / 2
        y: root.height * 0.2 - (1 - root.progress) * 8

        radius: Theme.radius.large
        color: Theme.colors.surface
        border.color: Theme.colors.border
        border.width: 1
        opacity: root.progress
        clip: true

        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: column
            width: parent.width

            Item {
                width: parent.width
                height: root.searchHeight

                TextInput {
                    id: input
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.xl
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.xl
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.colors.text
                    selectionColor: Theme.colors.accent
                    selectedTextColor: Theme.colors.accentText
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large + 1
                    clip: true
                    focus: true

                    cursorDelegate: Rectangle {
                        width: 2
                        radius: 1
                        color: Theme.colors.accent
                    }

                    Keys.onEscapePressed: root.shown = false
                    Keys.onReturnPressed: root.launch(root.results[list.currentIndex])
                    Keys.onEnterPressed: root.launch(root.results[list.currentIndex])
                    Keys.onDownPressed: list.incrementCurrentIndex()
                    Keys.onUpPressed: list.decrementCurrentIndex()
                    Keys.onTabPressed: list.incrementCurrentIndex()

                    Text {
                        anchors.fill: parent
                        visible: input.text === ""
                        text: "Pesquisar"
                        color: Theme.colors.textDisabled
                        font: input.font
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Item {
                width: parent.width
                height: 1
                visible: list.count > 0 || emptyState.visible

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.spacing.md
                    height: 1
                    color: Theme.colors.border
                }
            }

            Item {
                width: parent.width
                height: list.count > 0
                    ? root.visibleRows * root.rowHeight + Theme.spacing.sm * 2
                    : (emptyState.visible ? 56 : 0)

                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.sm
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: Theme.anim.instant
                    highlightMoveVelocity: -1
                    highlightResizeDuration: 0
                    keyNavigationEnabled: false

                    model: ScriptModel {
                        values: root.results
                    }

                    highlight: Rectangle {
                        radius: Theme.radius.medium
                        color: Theme.colors.pressed
                    }

                    delegate: LauncherItem {
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: root.rowHeight
                        entry: modelData

                        onClicked: root.launch(modelData)
                        onHovered: list.currentIndex = index
                    }
                }

                Text {
                    id: emptyState
                    anchors.centerIn: parent
                    visible: list.count === 0 && root.searching
                    text: "Nenhum resultado"
                    color: Theme.colors.textSecondary
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }
            }
        }
    }
}
