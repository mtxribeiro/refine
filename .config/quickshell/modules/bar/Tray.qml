import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import "../../theme"
import "../../components"

Row {
    id: root

    property bool expanded: false
    property string menuId: ""
    readonly property int count: SystemTray.items.values.length

    visible: count > 0
    spacing: 0

    onCountChanged: {
        if (count === 0)
            expanded = false
    }

    onExpandedChanged: {
        if (!expanded)
            menuId = ""
    }

    Item {
        id: drawer
        visible: width > 0
        width: root.expanded ? icons.implicitWidth : 0
        height: 28
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.anim.fast
                easing.type: Theme.anim.easing
            }
        }

        Row {
            id: icons

            Repeater {
                model: SystemTray.items

                delegate: TrayIcon {
                    required property var modelData

                    item: modelData
                    menuOpen: root.menuId === modelData.id
                    onMenuRequested: root.menuId = modelData.id
                    onMenuDismissed: root.menuId = ""
                }
            }
        }
    }

    BarButton {
        icon: root.expanded ? "pan-end-symbolic" : "pan-start-symbolic"
        iconSize: 16
        implicitWidth: 20
        active: root.expanded
        onClicked: root.expanded = !root.expanded
    }
}
