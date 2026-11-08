pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property string active: ""
    property string screenName: ""
    property real anchorX: 0

    function isOpen(name, screen) {
        return active === name && screenName === screen.name
    }

    function toggle(name, item, screen) {
        if (isOpen(name, screen)) {
            close()
            return
        }

        anchorX = item.mapToItem(null, item.width / 2, 0).x
        screenName = screen.name
        active = name
    }

    function close() {
        active = ""
    }
}
