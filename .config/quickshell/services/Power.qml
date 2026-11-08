pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool hasBattery: device !== null && device.isPresent
    readonly property real percentage: hasBattery ? device.percentage : 0
    readonly property int percent: Math.round(percentage * 100)
    readonly property bool charging: hasBattery && device.state === UPowerDeviceState.Charging
    readonly property bool full: hasBattery && device.state === UPowerDeviceState.FullyCharged

    readonly property string icon: {
        if (!hasBattery)
            return "system-shutdown-symbolic"
        if (full)
            return "battery-level-100-charged-symbolic"

        const level = Math.round(percent / 10) * 10
        return "battery-level-" + level + (charging ? "-charging" : "") + "-symbolic"
    }

    readonly property string status: {
        if (!hasBattery)
            return ""
        if (full)
            return "Carga completa"

        const remaining = format(charging ? device.timeToFull : device.timeToEmpty)
        const base = charging ? "Carregando" : "Descarregando"
        return remaining === "" ? base : base + "  ·  " + remaining
    }

    function format(seconds) {
        if (!seconds || seconds <= 0)
            return ""

        const h = Math.floor(seconds / 3600)
        const m = Math.round((seconds % 3600) / 60)
        return h > 0 ? h + " h " + m + " min" : m + " min"
    }

    function lock() {
        Quickshell.execDetached(["loginctl", "lock-session"])
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"])
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"])
    }

    function shutdown() {
        Quickshell.execDetached(["systemctl", "poweroff"])
    }

    function logout() {
        Quickshell.execDetached(["niri", "msg", "action", "quit", "--skip-confirmation"])
    }
}
