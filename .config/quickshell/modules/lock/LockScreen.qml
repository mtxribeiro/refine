import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import "../../theme"
import "../../services"

Item {
    id: root

    readonly property var days: ["Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado"]
    readonly property var months: ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]

    property string wallpaper: ""

    function pad(n) {
        return String(n).padStart(2, "0")
    }

    Process {
        id: wallpaperProc
        running: true
        command: ["sh", "-c", "cat \"$HOME/.cache/current-wallpaper\" 2>/dev/null || echo \"$HOME/Imagens/Wallpapers/default.jpg\""]

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim()
                if (path !== "")
                    root.wallpaper = path.startsWith("/") ? "file://" + path : path
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.background
    }

    Image {
        id: wallpaperImage
        anchors.fill: parent
        source: root.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaperImage
        visible: wallpaperImage.status === Image.Ready
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 0.62
        blurMax: 44
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.overlay
        opacity: 0.5
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Connections {
        target: Session

        function onBusyChanged() {
            if (!Session.busy) {
                input.text = ""
                input.forceActiveFocus()
            }
        }

        function onFailedChanged() {
            if (Session.failed)
                shake.restart()
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.2
        width: parent.width
        spacing: Theme.spacing.sm

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.pad(clock.date.getHours()) + ":" + root.pad(clock.date.getMinutes())
            color: Theme.colors.text
            renderType: Text.NativeRendering
            font.family: Theme.font.family
            font.pixelSize: Math.round(root.height * 0.1)
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.days[clock.date.getDay()] + ", " + clock.date.getDate() + " de " + root.months[clock.date.getMonth()]
            color: Theme.colors.textSecondary
            renderType: Text.NativeRendering
            font.family: Theme.font.family
            font.pixelSize: Math.round(root.height * 0.026)
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.74
        width: 264
        spacing: Theme.spacing.md

        Rectangle {
            id: field

            property real reveal: input.text !== "" || Session.busy || Session.failed ? 1 : 0

            width: parent.width
            height: 48
            radius: Theme.radius.full
            color: Theme.colors.hover
            border.width: 1
            border.color: Session.failed ? Theme.colors.borderStrong : Theme.colors.border
            opacity: reveal

            transform: Translate {
                id: shakeOffset
                x: 0
                y: (1 - field.reveal) * 6
            }

            Behavior on reveal {
                NumberAnimation {
                    duration: Theme.anim.normal
                    easing.type: Theme.anim.easing
                }
            }

            Behavior on border.color {
                ColorAnimation { duration: Theme.anim.fast }
            }

            SequentialAnimation {
                id: shake
                NumberAnimation { target: shakeOffset; property: "x"; to: -10; duration: 50 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 10; duration: 70 }
                NumberAnimation { target: shakeOffset; property: "x"; to: -6; duration: 60 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 6; duration: 60 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 50 }
            }

            TextInput {
                id: input
                anchors.fill: parent
                echoMode: TextInput.Password
                enabled: !Session.busy
                opacity: 0
                focus: true

                cursorDelegate: Item {}

                Keys.onReturnPressed: Session.submit(text)
                Keys.onEnterPressed: Session.submit(text)
                Keys.onEscapePressed: text = ""

                Component.onCompleted: forceActiveFocus()
            }

            Item {
                id: dots
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.xl
                anchors.rightMargin: Theme.spacing.xl
                clip: true
                opacity: Session.busy ? 0.5 : 1

                readonly property int count: input.text.length
                readonly property int step: 16
                readonly property int size: 8

                Repeater {
                    model: 32

                    delegate: Rectangle {
                        id: dot

                        required property int index

                        width: dots.size
                        height: dots.size
                        radius: dots.size / 2
                        color: Theme.colors.text
                        opacity: index < dots.count ? 1 : 0
                        x: dots.width / 2 + (index - (dots.count - 1) / 2) * dots.step - dots.size / 2
                        y: (dots.height - dots.size) / 2

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.anim.slow
                                easing.type: Theme.anim.easing
                            }
                        }

                        Behavior on x {
                            NumberAnimation {
                                duration: Theme.anim.slow
                                easing.type: Theme.anim.easing
                            }
                        }
                    }
                }
            }
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            opacity: Session.failed ? 1 : 0
            text: "Senha incorreta"
            color: Theme.colors.textSecondary
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.fast }
            }
        }
    }
}
