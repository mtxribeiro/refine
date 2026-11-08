import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import "../../theme"
import "../../services"

Item {
    id: root

    required property var item

    property bool menuOpen: false
    property real menuX: 0

    signal menuRequested()
    signal menuDismissed()

    implicitWidth: 26
    implicitHeight: 28

    function toggleMenu() {
        if (menuOpen) {
            menuDismissed()
            return
        }

        Panels.close()
        menuX = mapToItem(null, width / 2, 0).x
        menuRequested()
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: 16
        source: root.item.icon
        opacity: area.containsMouse ? 0.65 : 1

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }
    }

    TrayMenu {
        item: root.item
        screen: root.QsWindow.window ? root.QsWindow.window.screen : null
        open: root.menuOpen
        anchorX: root.menuX
        onDismissed: root.menuDismissed()
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                if (root.item.onlyMenu && root.item.hasMenu)
                    root.toggleMenu()
                else
                    root.item.activate()
            } else if (mouse.button === Qt.MiddleButton) {
                root.item.secondaryActivate()
            } else if (root.item.hasMenu) {
                root.toggleMenu()
            }
        }
    }
}
