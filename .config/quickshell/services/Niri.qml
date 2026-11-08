pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var workspaces: []

    function forOutput(name) {
        return workspaces
            .filter(w => w.output === name)
            .sort((a, b) => a.idx - b.idx)
    }

    function focus(idx) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)])
    }

    function focusUp() {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace-up"])
    }

    function focusDown() {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace-down"])
    }

    function refresh() {
        if (!listProc.running)
            listProc.running = true
    }

    Component.onCompleted: refresh()

    Process {
        id: listProc
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspaces = JSON.parse(text)
                } catch (e) {
                }
            }
        }
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: data => {
                if (data.indexOf("Workspace") >= 0)
                    debounce.restart()
            }
        }
    }

    Timer {
        id: debounce
        interval: 40
        onTriggered: root.refresh()
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
