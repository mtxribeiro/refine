pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool wifiEnabled: true
    property string kind: "none"
    property string connection: ""
    property var networks: []
    property var saved: []
    property bool scanning: false
    property string connecting: ""
    property string failed: ""

    function isSaved(ssid) {
        return saved.includes(ssid)
    }

    function refresh() {
        statusProc.running = true
        radioProc.running = true
        savedProc.running = true
        scan(false)
    }

    function scan(rescan) {
        if (listProc.running)
            return

        scanning = rescan
        listProc.command = ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", rescan ? "yes" : "no"]
        listProc.running = true
    }

    function join(ssid, password) {
        failed = ""
        connecting = ssid
        connectProc.target = ssid
        connectProc.withPassword = password !== ""
        connectProc.command = password !== ""
            ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "device", "wifi", "connect", ssid]
        connectProc.running = true
    }

    function leave() {
        Quickshell.execDetached(["nmcli", "connection", "down", "id", connection])
        debounce.restart()
    }

    function setWifi(on) {
        wifiEnabled = on
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"])
        debounce.restart()
    }

    function parseStatus(text) {
        let found = { kind: "none", connection: "" }

        for (const line of text.split("\n")) {
            const p = line.split(":")
            if (p.length < 3 || p[1] !== "connected")
                continue

            if (p[0] === "ethernet") {
                found = { kind: "ethernet", connection: p.slice(2).join(":") }
                break
            }

            if (p[0] === "wifi" && found.kind === "none")
                found = { kind: "wifi", connection: p.slice(2).join(":") }
        }

        kind = found.kind
        connection = found.connection
    }

    function parseSaved(text) {
        const names = []

        for (const line of text.split("\n")) {
            const i = line.lastIndexOf(":")
            if (i < 0)
                continue

            if (line.slice(i + 1) === "802-11-wireless")
                names.push(line.slice(0, i).replace(/\\:/g, ":"))
        }

        saved = names
    }

    function parseNetworks(text) {
        const best = {}

        for (const line of text.split("\n")) {
            const p = line.replace(/\\:/g, "\u0001").split(":")
            if (p.length < 4)
                continue

            const ssid = p[1].replace(/\u0001/g, ":")
            if (ssid === "")
                continue

            const item = {
                ssid: ssid,
                signal: parseInt(p[2]) || 0,
                secure: p[3] !== "" && p[3] !== "--",
                active: p[0] === "*"
            }

            const prev = best[ssid]
            if (!prev || item.active || (!prev.active && item.signal > prev.signal))
                best[ssid] = item
        }

        const list = Object.values(best)
        list.sort((a, b) => (b.active - a.active) || (b.signal - a.signal))
        networks = list
    }

    Component.onCompleted: refresh()

    Process {
        id: statusProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: root.parseStatus(text)
        }
    }

    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: root.parseSaved(text)
        }
    }

    Process {
        id: listProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseNetworks(text)
                root.scanning = false
            }
        }
    }

    Process {
        id: connectProc

        property string target: ""
        property bool withPassword: false

        onExited: (exitCode, exitStatus) => {
            root.connecting = ""
            root.failed = exitCode === 0 ? "" : target

            if (exitCode !== 0 && withPassword) {
                forgetProc.command = ["nmcli", "connection", "delete", "id", target]
                forgetProc.running = true
            }

            root.refresh()
        }
    }

    Process {
        id: forgetProc
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: debounce.restart()
        }
    }

    Timer {
        id: debounce
        interval: 400
        onTriggered: root.refresh()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
