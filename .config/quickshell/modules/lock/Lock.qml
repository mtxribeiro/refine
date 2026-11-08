import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../theme"
import "../../services"

WlSessionLock {
    locked: Session.locked

    WlSessionLockSurface {
        color: Theme.colors.background

        LockScreen {
            anchors.fill: parent
        }
    }
}
