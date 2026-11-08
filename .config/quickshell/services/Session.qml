pragma Singleton

import Quickshell
import Quickshell.Services.Pam
import QtQuick

Singleton {
    id: root

    property bool locked: false
    property bool busy: false
    property bool failed: false
    property string pending: ""

    function lock() {
        failed = false
        locked = true
    }

    function unlock() {
        locked = false
    }

    function submit(password) {
        if (busy || password === "")
            return

        pending = password
        failed = false
        busy = true
        pam.start()
    }

    PamContext {
        id: pam
        config: "password.conf"
        configDirectory: Quickshell.shellPath("pam")

        onPamMessage: {
            if (responseRequired)
                respond(root.pending)
        }

        onCompleted: result => {
            root.pending = ""
            root.failed = result !== PamResult.Success
            root.busy = false

            if (result === PamResult.Success)
                root.locked = false
        }

        onError: {
            root.pending = ""
            root.failed = true
            root.busy = false
        }
    }
}
